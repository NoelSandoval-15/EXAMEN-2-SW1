class RequestStepModel {
  const RequestStepModel({
    required this.title,
    required this.status,
    required this.isCompleted,
    required this.isCurrent,
    this.date,
    this.responsible,
  });

  final String title;
  final String status;
  final bool isCompleted;
  final bool isCurrent;
  final DateTime? date;
  final String? responsible;
}
