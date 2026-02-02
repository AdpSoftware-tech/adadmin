import 'dart:convert';
import 'package:http/http.dart' as http;

class IglesiaService {
  final String baseUrl;
  final Future<String?> Function() tokenGetter;

  IglesiaService({required this.baseUrl, required this.tokenGetter});

  Future<Map<String, String>> _headers() async {
    final token = await tokenGetter();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<List<dynamic>> getIglesias() async {
    final uri = Uri.parse("$baseUrl/api/iglesia");
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode >= 400) {
      throw Exception("Error GET iglesias: ${res.body}");
    }
    final body = jsonDecode(res.body);
    return (body["data"] as List? ?? []);
  }

  Future<void> deleteIglesia(String id) async {
    final uri = Uri.parse("$baseUrl/api/iglesia/$id");
    final res = await http.delete(uri, headers: await _headers());
    if (res.statusCode >= 400) {
      throw Exception("Error DELETE iglesia: ${res.body}");
    }
  }

  Future<Map<String, dynamic>> updateIglesia(
    String id,
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse("$baseUrl/api/iglesia/$id");
    final res = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode >= 400) {
      throw Exception("Error PUT iglesia: ${res.body}");
    }
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> createIglesia(Map<String, dynamic> data) async {
    final uri = Uri.parse("$baseUrl/api/iglesia");
    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode >= 400) {
      throw Exception("Error POST iglesia: ${res.body}");
    }
    return jsonDecode(res.body);
  }
}
