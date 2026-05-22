import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final http.Client client;
  static const String _baseUrl = 'https://dummyjson.com';

  AuthService({required this.client});

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String message = data['message'] ?? 'Credenciais inválidas. Verifique seu usuário e senha.';
        throw Exception(message);
      } else {
        throw Exception('Erro no servidor ao realizar autenticação (${response.statusCode}).');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Falha de rede ou de conexão: $e');
    }
  }
}
