import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();
  static const String baseUrl = 'http://18.218.73.94/api';

  static Future<Map<String, dynamic>> loginAluno(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/aluno/login');

    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));

    if (resp.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(resp.body);
      final token = body['token'] as String?;
      if (token != null) return {'token': token, 'body': body};
      return {'error': 'Resposta inválida do servidor'};
    }
    
    try {
      final Map<String, dynamic> body = jsonDecode(resp.body);
      if (body.containsKey('message')) return {'error': body['message'].toString()};
    } catch (_) {}

    return {'error': 'Erro ao autenticar (status ${resp.statusCode})'};
  }

  static const _kJwtKey = 'jwt_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kJwtKey, token);
  }

  static Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kJwtKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kJwtKey);
  }

  static Future<Map<String, dynamic>?> meAluno(String token) async {
    final url = Uri.parse('$baseUrl/auth/aluno/me');
    final resp = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (resp.statusCode == 200) return jsonDecode(resp.body) as Map<String, dynamic>;
    return null;
  }

  static Future<bool> registerFcm(String? tokenJwt, String fcmToken) async {
    final token = tokenJwt ?? await readToken();
    final url = Uri.parse('$baseUrl/push/register');
    final resp = await http.post(url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'hashPush': fcmToken}),
    );
    return resp.statusCode == 200 || resp.statusCode == 201;
  }
}
