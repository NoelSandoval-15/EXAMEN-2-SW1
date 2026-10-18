class RequestModel {
  const RequestModel({
    required this.id,
    required this.code,
    required this.title,
    required this.status,
    required this.startDate,
    required this.currentOffice,
    required this.progress,
    required this.description,
    required this.responsible,
    this.isFinished = false,
  });

  final String id;
  final String code;
  final String title;
  final String status;
  final DateTime startDate;
  final String currentOffice;
  final double progress;
  final String description;
  final String responsible;
  final bool isFinished;
}
