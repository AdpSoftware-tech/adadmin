import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/iglesia_service.dart';
import '../models/iglesia_models.dart';
import '../../auth/presentation/providers/auth_token_provider.dart';

// ⚠️ Ajusta esto a tu forma real de obtener token y baseUrl
final baseUrlProvider = Provider<String>((ref) => "http://localhost:3000");
final tokenGetterProvider = Provider<Future<String?> Function()>((ref) {
  return () async {
    final session = ref.read(authSessionProvider);
    return session.token;
  };
});

final iglesiaServiceProvider = Provider<IglesiaService>((ref) {
  return IglesiaService(
    baseUrl: ref.watch(baseUrlProvider),
    tokenGetter: ref.watch(tokenGetterProvider),
  );
});

final iglesiasProvider = FutureProvider<List<Iglesia>>((ref) async {
  final svc = ref.watch(iglesiaServiceProvider);
  final raw = await svc.getIglesias();
  return raw.map((e) => Iglesia.fromJson(e as Map<String, dynamic>)).toList();
});
