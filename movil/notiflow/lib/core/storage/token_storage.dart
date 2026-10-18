import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyToken = 'jwt_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyRolId = 'rol_id';
  static const String _keyDeptId = 'dept_id';
  static const String _keyNombre = 'nombre';

  Future<void> saveSession({
    required String token,
    required String userId,
    required String username,
    required String rolId,
    String? departamentoId,
    required String nombre,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyRolId, rolId);
    if (departamentoId != null) {
      await prefs.setString(_keyDeptId, departamentoId);
    } else {
      await prefs.remove(_keyDeptId);
    }
    await prefs.setString(_keyNombre, nombre);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<String?> getRolId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRolId);
  }

  Future<String?> getDepartamentoId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeptId);
  }

  Future<String?> getNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNombre);
  }

  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRolId);
    await prefs.remove(_keyDeptId);
    await prefs.remove(_keyNombre);
  }
}
