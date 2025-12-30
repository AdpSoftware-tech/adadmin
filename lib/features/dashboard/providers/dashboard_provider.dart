import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dashboard_service.dart';

/// Provider que llama al backend y devuelve el JSON del dashboard global
final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = DashboardService();
  return await service.getDashboardGlobal();
});
