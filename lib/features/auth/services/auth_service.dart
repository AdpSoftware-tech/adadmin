import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:3000/api", // 👈 base de tu API
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post(
      "/auth/login", // 👈 queda: http://localhost:3000/api/auth/login
      data: {"email": email, "password": password},
    );

    final token = response.data["token"] as String;

    // Guardamos token
    await storage.write(key: "token", value: token);

    // Decodificamos el JWT para sacar el rol y otros datos
    final payload = JwtDecoder.decode(token);
    final rol = payload["rol"] as String?;
    final referenciaId = payload["referenciaId"];

    return {
      "token": token,
      "rol": rol,
      "payload": payload,
      "referenciaId": referenciaId,
    };
  }
}
