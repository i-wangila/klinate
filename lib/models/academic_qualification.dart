class AcademicQualification {
  final String id;
  String title; // Dr., Prof., Mr., Mrs., etc.
  String educationLevel; // Certificate, Diploma, Bachelor's, Master's, PhD, N/A
  String specialization; // General Practitioner, Pathology, Cardiology, etc.
  String? institution; // University/Institution name (optional)
  int? yearCompleted; // Year of completion (optional)
  String? fieldOfStudy; // Field of study (optional)

  AcademicQualification({
    String? id,
    required this.title,
    required this.educationLevel,
    required this.specialization,
    this.institution,
    this.yearCompleted,
    this.fieldOfStudy,
  }) : id = id ?? 'qual_${DateTime.now().millisecondsSinceEpoch}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'educationLevel': educationLevel,
      'specialization': specialization,
      'institution': institution,
      'yearCompleted': yearCompleted,
      'fieldOfStudy': fieldOfStudy,
    };
  }

  factory AcademicQualification.fromJson(Map<String, dynamic> json) {
    return AcademicQualification(
      id: json['id'],
      title: json['title'] ?? '',
      educationLevel: json['educationLevel'] ?? '',
      specialization: json['specialization'] ?? '',
      institution: json['institution'],
      yearCompleted: json['yearCompleted'],
      fieldOfStudy: json['fieldOfStudy'],
    );
  }

  String get displayName {
    final parts = <String>[];
    if (title.isNotEmpty) parts.add(title);
    if (educationLevel != 'N/A') parts.add(educationLevel);
    if (specialization != 'General Practitioner' && specialization != 'N/A') {
      parts.add('in $specialization');
    } else if (specialization == 'General Practitioner') {
      parts.add('- $specialization');
    }
    if (institution != null && institution!.isNotEmpty) {
      parts.add('from $institution');
    }
    return parts.join(' ');
  }
}
