import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DashboardService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000/api', // 👈 ajusta si usas otro host
    ),
  );

  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> getDashboardGlobal() async {
    // Leemos el token que guardaste al hacer login
    final token = await _storage.read(key: 'token');

    final response = await _dio.get(
      '/dashboard/global',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    // Aseguramos que sea un Map<String, dynamic>
    return Map<String, dynamic>.from(response.data as Map);
  }
}
