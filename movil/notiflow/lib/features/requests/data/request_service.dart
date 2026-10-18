import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/request_model.dart';
import '../domain/request_step_model.dart';
import '../domain/workflow_template_model.dart';

class RequestService {
  final TokenStorage _tokenStorage = TokenStorage();

  // Mapear plantilla a nombre legible
  String _mapTemplateName(String templateId) {
    if (templateId == 'WF_SOLICITUD_SERVICIO') {
      return 'Solicitud de Servicio';
    } else if (templateId == 'WF_RECLAMO_CLIENTE') {
      return 'Reclamo de Cliente';
    }
    return 'Trámite Administrativo';
  }

  // Traducir estado a texto amigable
  String _translateStatus(String status) {
    switch (status) {
      case 'EN_PROCESO':
        return 'En Revision';
      case 'COMPLETADO':
        return 'Finalizado';
      case 'RECHAZADO':
        return 'Rechazado';
      case 'NUEVO':
        return 'Nuevo';
      default:
        return status;
    }
  }

  // Calcular progreso dinámico
  double _calculateProgress(String status, List<dynamic>? history) {
    if (status == 'COMPLETADO' || status == 'RECHAZADO') {
      return 1.0;
    }
    final historyLength = history?.length ?? 0;
    double progress = historyLength > 0 ? (historyLength / (historyLength + 2)) : 0.15;
    return progress > 0.9 ? 0.9 : progress;
  }

  // Obtener descripción de los datos del formulario
  String _extractDescription(Map<String, dynamic>? form) {
    if (form == null) return 'Sin descripción disponible.';
    return form['descripcionSolicitud'] ?? form['detalle'] ?? 'Trámite registrado en el sistema.';
  }

  Future<List<RequestModel>> getClientRequests() async {
    final token = await _tokenStorage.getToken();
    final loggedInUserId = await _tokenStorage.getUserId() ?? '';
    if (token == null) return [];

    // Mapear el ID del usuario al clienteId de MongoDB (removiendo el prefijo)
    final clienteIdFilter = loggedInUserId.replaceAll('USER_CLIENTE_', '');

    final url = Uri.parse('${ApiClient.baseUrl}/workflow/instancias');
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
          
          // Filtrar por el cliente logueado
          final filteredList = data.where((inst) => inst['clienteId'] == clienteIdFilter).toList();

          return filteredList.map((json) {
            final status = json['estadoActual'] ?? '';
            final history = json['historialResumen'] as List<dynamic>?;
            final form = json['datosFormulario'] as Map<String, dynamic>?;

            return RequestModel(
              id: json['id'] ?? '',
              code: json['codigo'] ?? '',
              title: _mapTemplateName(json['templateId'] ?? ''),
              status: _translateStatus(status),
              startDate: json['createdAt'] != null 
                  ? DateTime.parse(json['createdAt']) 
                  : DateTime.now(),
              currentOffice: json['nodoActual'] != null 
                  ? (json['nodoActual']['nombre'] ?? 'Trámite') 
                  : 'Finalizado',
              progress: _calculateProgress(status, history),
              description: _extractDescription(form),
              responsible: json['responsableActualId'] ?? 'Sistema',
              isFinished: status == 'COMPLETADO' || status == 'RECHAZADO',
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener trámites: $e');
      return [];
    }
  }

  Future<RequestModel> getRequestById(String id) async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw Exception('No autenticado');

    final url = Uri.parse('${ApiClient.baseUrl}/workflow/instancias/$id');
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
        final json = responseBody['data'];
        final status = json['estadoActual'] ?? '';
        final history = json['historialResumen'] as List<dynamic>?;
        final form = json['datosFormulario'] as Map<String, dynamic>?;

        return RequestModel(
          id: json['id'] ?? '',
          code: json['codigo'] ?? '',
          title: _mapTemplateName(json['templateId'] ?? ''),
          status: _translateStatus(status),
          startDate: json['createdAt'] != null 
              ? DateTime.parse(json['createdAt']) 
              : DateTime.now(),
          currentOffice: json['nodoActual'] != null 
              ? (json['nodoActual']['nombre'] ?? 'Trámite') 
              : 'Finalizado',
          progress: _calculateProgress(status, history),
          description: _extractDescription(form),
          responsible: json['responsableActualId'] ?? 'Sistema',
          isFinished: status == 'COMPLETADO' || status == 'RECHAZADO',
        );
      }
    }
    throw Exception('Error al obtener el detalle del trámite');
  }

  Future<List<RequestStepModel>> getRequestSteps(String requestId) async {
    final token = await _tokenStorage.getToken();
    if (token == null) return [];

    final url = Uri.parse('${ApiClient.baseUrl}/workflow/instancias/$requestId');
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
          final json = responseBody['data'];
          final status = json['estadoActual'] ?? '';
          final List<dynamic>? history = json['historialResumen'] as List<dynamic>?;
          final Map<String, dynamic>? nodoActual = json['nodoActual'] as Map<String, dynamic>?;

          List<RequestStepModel> steps = [];

          // 1. Agregar pasos completados de la bitácora
          if (history != null) {
            for (var entry in history) {
              steps.add(RequestStepModel(
                title: entry['nodoNombre'] ?? 'Inicio del Trámite',
                status: 'Completado',
                isCompleted: true,
                isCurrent: false,
                date: entry['fecha'] != null ? DateTime.parse(entry['fecha']) : null,
                responsible: entry['usuarioId'] != null 
                    ? entry['usuarioId'].toString().replaceAll('USER_CLIENTE_', '').replaceAll('USER_', '') 
                    : 'Sistema',
              ));
            }
          }

          // 2. Agregar paso actual activo si está en proceso
          if (status == 'EN_PROCESO' && nodoActual != null) {
            steps.add(RequestStepModel(
              title: nodoActual['nombre'] ?? 'Revisión',
              status: 'En curso',
              isCompleted: false,
              isCurrent: true,
              date: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
              responsible: json['responsableActualId'] != null 
                  ? json['responsableActualId'].toString().replaceAll('USER_CLIENTE_', '').replaceAll('USER_', '') 
                  : 'Asignando funcionario...',
            ));
          }

          // 3. Agregar paso final de cierre
          if (status == 'COMPLETADO') {
            steps.add(RequestStepModel(
              title: 'Trámite Completado',
              status: 'Completado',
              isCompleted: true,
              isCurrent: false,
              date: json['finishedAt'] != null ? DateTime.parse(json['finishedAt']) : null,
            ));
          } else if (status == 'RECHAZADO') {
            steps.add(RequestStepModel(
              title: 'Trámite Rechazado',
              status: 'Rechazado',
              isCompleted: false,
              isCurrent: false,
              date: json['finishedAt'] != null ? DateTime.parse(json['finishedAt']) : null,
            ));
          } else {
            steps.add(const RequestStepModel(
              title: 'Fin del Proceso',
              status: 'Pendiente',
              isCompleted: false,
              isCurrent: false,
            ));
          }

          return steps;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener seguimiento: $e');
      return [];
    }
  }

  Future<List<WorkflowTemplate>> getTemplates() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return [];

    final url = Uri.parse('${ApiClient.baseUrl}/workflow/templates');
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
          return data.map((json) => WorkflowTemplate.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener plantillas de trámite: $e');
      return [];
    }
  }

  Future<FormModel?> getFormById(String formId) async {
    final token = await _tokenStorage.getToken();
    if (token == null) return null;

    final url = Uri.parse('${ApiClient.baseUrl}/formularios/$formId');
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
          return FormModel.fromJson(responseBody['data'] ?? {});
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener formulario $formId: $e');
      return null;
    }
  }

  Future<RequestModel?> createRequest({
    required String templateId,
    required String clienteId,
    required Map<String, dynamic> datosFormulario,
    String prioridad = 'NORMAL',
  }) async {
    final token = await _tokenStorage.getToken();
    if (token == null) return null;

    final url = Uri.parse('${ApiClient.baseUrl}/workflow/instancias');
    try {
      final bodyMap = {
        'templateId': templateId,
        'clienteId': clienteId,
        'prioridad': prioridad,
        'datosFormulario': datosFormulario,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseBody['success'] == true) {
          final json = responseBody['data'];
          final status = json['estadoActual'] ?? '';
          final history = json['historialResumen'] as List<dynamic>?;
          final form = json['datosFormulario'] as Map<String, dynamic>?;

          return RequestModel(
            id: json['id'] ?? '',
            code: json['codigo'] ?? '',
            title: _mapTemplateName(json['templateId'] ?? ''),
            status: _translateStatus(status),
            startDate: json['createdAt'] != null 
                ? DateTime.parse(json['createdAt']) 
                : DateTime.now(),
            currentOffice: json['nodoActual'] != null 
                ? (json['nodoActual']['nombre'] ?? 'Trámite') 
                : 'Finalizado',
            progress: _calculateProgress(status, history),
            description: _extractDescription(form),
            responsible: json['responsableActualId'] ?? 'Sistema',
            isFinished: status == 'COMPLETADO' || status == 'RECHAZADO',
          );
        }
      }

      try {
        final Map<String, dynamic> responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseBody['message'] != null) {
          throw Exception(responseBody['message']);
        }
      } catch (err) {
        if (err is Exception) rethrow;
      }

      throw Exception('Código de respuesta del servidor: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error al crear trámite: $e');
      rethrow;
    }
  }
}
