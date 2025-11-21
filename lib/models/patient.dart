class Patient {
  final String id;
  final String name;
  final String gender;
  final int age;
  final String? profileImageUrl;
  final String reasonForIntervention;
  final List<String> programs;
  final DateTime appointmentDate;
  final String providerId;
  final String providerName;

  Patient({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    this.profileImageUrl,
    required this.reasonForIntervention,
    required this.programs,
    required this.appointmentDate,
    required this.providerId,
    required this.providerName,
  });

  String get genderInitial => gender.substring(0, 1).toUpperCase();

  String get displayName => name;

  String get ageGenderInfo => '$gender, $age years';
}
