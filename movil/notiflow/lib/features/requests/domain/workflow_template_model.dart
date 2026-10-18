class WorkflowTemplate {
  final String id;
  final String nombre;
  final String formularioId;
  final String tipoSolicitud;

  const WorkflowTemplate({
    required this.id,
    required this.nombre,
    required this.formularioId,
    required this.tipoSolicitud,
  });

  factory WorkflowTemplate.fromJson(Map<String, dynamic> json) {
    return WorkflowTemplate(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      formularioId: json['formularioId'] ?? '',
      tipoSolicitud: json['tipoSolicitud'] ?? '',
    );
  }
}

class FormFieldModel {
  final String id;
  final String nombre;
  final String etiqueta;
  final String tipo;
  final bool requerido;
  final String valorDefault;

  const FormFieldModel({
    required this.id,
    required this.nombre,
    required this.etiqueta,
    required this.tipo,
    required this.requerido,
    required this.valorDefault,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      etiqueta: json['etiqueta'] ?? '',
      tipo: json['tipo'] ?? 'TEXT',
      requerido: json['requerido'] ?? false,
      valorDefault: json['valorDefault'] ?? '',
    );
  }
}

class FormModel {
  final String id;
  final String nombre;
  final List<FormFieldModel> campos;

  const FormModel({
    required this.id,
    required this.nombre,
    required this.campos,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> camposJson = json['campos'] ?? [];
    return FormModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      campos: camposJson.map((c) => FormFieldModel.fromJson(c)).toList(),
    );
  }
}
