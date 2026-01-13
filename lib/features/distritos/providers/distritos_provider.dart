import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../auth/presentation/providers/auth_token_provider.dart';

final distritosProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final token = ref.read(authSessionProvider).token;
  if (token == null || token.trim().isEmpty) {
    throw Exception("Sesión expirada");
  }

  final resp = await DioClient.dio.get(
    "/api/distrito",
    options: Options(
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
      responseType: ResponseType.json,
    ),
  );

  final raw = resp.data is String ? jsonDecode(resp.data) : resp.data;
  final data = (raw is Map<String, dynamic>) ? raw["data"] : raw;

  if (data is! List) {
    throw Exception("Respuesta inesperada del servidor");
  }

  return data.cast<Map<String, dynamic>>();
});
