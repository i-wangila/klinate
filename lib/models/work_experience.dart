class WorkExperience {
  final String id;
  String jobTitle;
  String organization;
  String? location;
  DateTime startDate;
  DateTime? endDate; // null means current position
  String? description;
  bool isCurrentPosition;

  WorkExperience({
    String? id,
    required this.jobTitle,
    required this.organization,
    this.location,
    required this.startDate,
    this.endDate,
    this.description,
    this.isCurrentPosition = false,
  }) : id = id ?? 'exp_${DateTime.now().millisecondsSinceEpoch}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobTitle': jobTitle,
      'organization': organization,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'isCurrentPosition': isCurrentPosition,
    };
  }

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      id: json['id'],
      jobTitle: json['jobTitle'] ?? '',
      organization: json['organization'] ?? '',
      location: json['location'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      description: json['description'],
      isCurrentPosition: json['isCurrentPosition'] ?? false,
    );
  }

  String get duration {
    final start = '${_monthName(startDate.month)} ${startDate.year}';
    final end = isCurrentPosition
        ? 'Present'
        : endDate != null
        ? '${_monthName(endDate!.month)} ${endDate!.year}'
        : 'Present';
    return '$start - $end';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  int get totalMonths {
    final end = endDate ?? DateTime.now();
    return (end.year - startDate.year) * 12 + (end.month - startDate.month);
  }

  String get durationText {
    final months = totalMonths;
    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years > 0 && remainingMonths > 0) {
      return '$years yr${years > 1 ? 's' : ''} $remainingMonths mo${remainingMonths > 1 ? 's' : ''}';
    } else if (years > 0) {
      return '$years yr${years > 1 ? 's' : ''}';
    } else {
      return '$remainingMonths mo${remainingMonths > 1 ? 's' : ''}';
    }
  }
}
