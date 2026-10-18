class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.documentNumber,
    this.phone,
  });

  final String id;
  final String fullName;
  final String email;
  final String? documentNumber;
  final String? phone;
}
