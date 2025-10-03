import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();
  static const String baseUrl = 'http://18.218.73.94/api';

  static Future<Map<String, dynamic>> loginAluno(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/aluno/login');
    try {
      final resp = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'password': password}))
          .timeout(const Duration(seconds: 10));

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
    } on http.ClientException catch (e) {
      return {'error': 'Falha de rede: ${e.toString()}'};
    } on Exception catch (e) {
      return {'error': 'Erro de conexão: ${e.toString()}'};
    }
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
    try {
      final resp = await http.get(url, headers: {'Authorization': 'Bearer $token'}).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getMe() async {
    final token = await readToken();
    if (token == null) return null;
    return meAluno(token);
  }

  static Future<bool> registerFcm(String? tokenJwt, String fcmToken) async {
    final token = tokenJwt ?? await readToken();
    final url = Uri.parse('$baseUrl/push/register');
    try {
      final resp = await http
          .post(url,
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
              body: jsonEncode({'hashPush': fcmToken}))
          .timeout(const Duration(seconds: 10));
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getPushList() async {
    final token = await readToken();
    if (token == null) return {'error': 'Token não encontrado'};

    final url = Uri.parse('$baseUrl/push');
    try {
      final resp = await http.get(url, headers: {'Authorization': 'Bearer $token'}).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        return {'data': decoded};
      }

      try {
        final Map<String, dynamic> body = jsonDecode(resp.body);
        if (body.containsKey('message')) return {'error': body['message'].toString()};
      } catch (_) {}

      return {'error': 'Falha ao buscar notificações (status ${resp.statusCode})'};
    } on http.ClientException catch (e) {
      return {'error': 'Falha de rede: ${e.toString()}'};
    } on Exception catch (e) {
      return {'error': 'Erro de conexão: ${e.toString()}'};
    }
  }

  static Future<bool> markPushAsRead(int idPushToSend) async {
    final token = await readToken();
    if (token == null) return false;

    final endpoints = [
      Uri.parse('$baseUrl/push/mark-read/$idPushToSend'),
      Uri.parse('$baseUrl/push_to_send/$idPushToSend/mark-read'),
      Uri.parse('$baseUrl/push_to_send/$idPushToSend'),
    ];

    for (final url in endpoints) {
      try {
        final resp = await http.post(url, headers: {'Authorization': 'Bearer $token'}).timeout(const Duration(seconds: 10));
        if (resp.statusCode == 200 || resp.statusCode == 204) return true;
       
        if (resp.statusCode == 404) continue;
      } catch (_) {
  
      }
      try {
        final resp = await http.patch(url,
                headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
                body: jsonEncode({'enviado': true}))
            .timeout(const Duration(seconds: 10));
        if (resp.statusCode == 200 || resp.statusCode == 204) return true;
      } catch (_) {}
    }

    return false;
  }
}
