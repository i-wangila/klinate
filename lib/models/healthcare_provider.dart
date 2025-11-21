class HealthcareProvider {
  final String id;
  final String name;
  final String type;
  final String specialization;
  final double rating;
  final int reviewCount;
  final String location;
  final String phone;
  final String email;
  final List<String> services;
  final bool isAvailable;
  final String openingHours;
  final String bio;
  final List<String> qualifications;
  final List<String> certifications;
  final int experienceYears;
  final List<String> languages;
  final double consultationFee;
  final String profileImageUrl;
  final List<String> workingDays;
  final Map<String, String> timeSlots;
  bool isFavorite;

  HealthcareProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.phone,
    required this.email,
    required this.services,
    required this.isAvailable,
    required this.openingHours,
    required this.bio,
    required this.qualifications,
    required this.certifications,
    required this.experienceYears,
    required this.languages,
    required this.consultationFee,
    required this.profileImageUrl,
    required this.workingDays,
    required this.timeSlots,
    this.isFavorite = false,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'specialization': specialization,
      'rating': rating,
      'reviewCount': reviewCount,
      'location': location,
      'phone': phone,
      'email': email,
      'services': services,
      'isAvailable': isAvailable,
      'openingHours': openingHours,
      'bio': bio,
      'qualifications': qualifications,
      'certifications': certifications,
      'experienceYears': experienceYears,
      'languages': languages,
      'consultationFee': consultationFee,
      'profileImageUrl': profileImageUrl,
      'workingDays': workingDays,
      'timeSlots': timeSlots,
      'isFavorite': isFavorite,
    };
  }

  // Create from JSON
  factory HealthcareProvider.fromJson(Map<String, dynamic> json) {
    return HealthcareProvider(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      specialization: json['specialization'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      location: json['location'],
      phone: json['phone'],
      email: json['email'],
      services: List<String>.from(json['services']),
      isAvailable: json['isAvailable'],
      openingHours: json['openingHours'],
      bio: json['bio'],
      qualifications: List<String>.from(json['qualifications']),
      certifications: List<String>.from(json['certifications']),
      experienceYears: json['experienceYears'],
      languages: List<String>.from(json['languages']),
      consultationFee: json['consultationFee'].toDouble(),
      profileImageUrl: json['profileImageUrl'],
      workingDays: List<String>.from(json['workingDays']),
      timeSlots: Map<String, String>.from(json['timeSlots']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Copy with method for editing
  HealthcareProvider copyWith({
    String? id,
    String? name,
    String? type,
    String? specialization,
    double? rating,
    int? reviewCount,
    String? location,
    String? phone,
    String? email,
    List<String>? services,
    bool? isAvailable,
    String? openingHours,
    String? bio,
    List<String>? qualifications,
    List<String>? certifications,
    int? experienceYears,
    List<String>? languages,
    double? consultationFee,
    String? profileImageUrl,
    List<String>? workingDays,
    Map<String, String>? timeSlots,
    bool? isFavorite,
  }) {
    return HealthcareProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      specialization: specialization ?? this.specialization,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      services: services ?? this.services,
      isAvailable: isAvailable ?? this.isAvailable,
      openingHours: openingHours ?? this.openingHours,
      bio: bio ?? this.bio,
      qualifications: qualifications ?? this.qualifications,
      certifications: certifications ?? this.certifications,
      experienceYears: experienceYears ?? this.experienceYears,
      languages: languages ?? this.languages,
      consultationFee: consultationFee ?? this.consultationFee,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      workingDays: workingDays ?? this.workingDays,
      timeSlots: timeSlots ?? this.timeSlots,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
