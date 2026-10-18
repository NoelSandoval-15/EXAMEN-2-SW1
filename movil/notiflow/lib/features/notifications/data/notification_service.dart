import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/notification_model.dart';

class NotificationService {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<List<NotificationModel>> getClientNotifications() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return [];

    final url = Uri.parse('${ApiClient.baseUrl}/notificaciones');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseBody['success'] == true) {
          final List<dynamic> data = responseBody['data'] ?? [];
          return data.map((json) {
            return NotificationModel(
              id: json['id'] ?? '',
              title: json['titulo'] ?? '',
              message: json['mensaje'] ?? '',
              createdAt: json['createdAt'] != null 
                  ? DateTime.parse(json['createdAt']) 
                  : DateTime.now(),
              isRead: json['leida'] ?? false,
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error al cargar notificaciones: $e');
      return [];
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    final token = await _tokenStorage.getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiClient.baseUrl}/notificaciones/$notificationId/leer');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        return responseBody['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al marcar notificación como leída: $e');
      return false;
    }
  }
}
