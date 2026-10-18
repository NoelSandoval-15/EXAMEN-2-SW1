import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/client_user.dart';

class AuthService {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<ClientUser?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiClient.baseUrl}/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (responseBody['success'] == true) {
          final data = responseBody['data'];
          final String token = data['token'];
          final String userId = data['userId'] ?? '';
          final String username = data['username'] ?? '';
          final String rolId = data['rolId'] ?? '';
          final String? departamentoId = data['departamentoId'];
          final String nombre = data['nombre'] ?? '';

          // Save the full session in SharedPreferences
          await _tokenStorage.saveSession(
            token: token,
            userId: userId,
            username: username,
            rolId: rolId,
            departamentoId: departamentoId,
            nombre: nombre,
          );

          return ClientUser(
            id: userId,
            name: nombre,
            email: username,
          );
        } else {
          throw Exception(responseBody['message'] ?? 'Error de autenticación');
        }
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        try {
          final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
          throw Exception(responseBody['message'] ?? 'Credenciales incorrectas');
        } catch (_) {
          throw Exception('Usuario o contraseña incorrectos');
        }
      } else {
        throw Exception('Error en el servidor: Código ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: No se pudo conectar con el servidor ($e)');
    }
  }
}
