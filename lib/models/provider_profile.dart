import 'user_profile.dart';
import 'academic_qualification.dart';
import 'work_experience.dart';

enum ProviderStatus {
  pending, // Awaiting verification
  approved, // Verified and active
  rejected, // Verification failed
  suspended, // Temporarily disabled
}

enum AvailabilityStatus { available, busy, offline }

class ProviderProfile {
  final String id;
  final String userId; // Links to UserProfile
  UserRole providerType;
  ProviderStatus status;
  AvailabilityStatus availabilityStatus;

  // Professional Information
  String? specialization;
  List<String> servicesOffered;
  String? servicesDescription; // Detailed description of services
  List<String> profileImages; // Profile/premises images for display
  String? licenseNumber;
  String? registrationId;
  int? experienceYears;
  String? bio;
  List<WorkExperience> workExperience; // Work history (LinkedIn-style)
  List<AcademicQualification> academicQualifications; // Academic qualifications
  List<String> qualifications;
  List<String> certifications; // Certifications & Accreditations
  List<String> languages;
  List<String> insuranceAccepted; // Insurance providers accepted
  List<String> paymentMethods; // Payment methods accepted

  // Pricing
  double? consultationFee;
  double? servicePricing;
  String? currency;

  // Availability
  List<String> workingDays;
  Map<String, String> workingHours; // day: hours
  bool acceptingNewPatients;

  // Ratings & Reviews
  double rating;
  int totalReviews;
  int totalPatients;
  int totalAppointments;

  // Verification
  List<String> verificationDocuments;
  DateTime? verifiedAt;
  String? rejectionReason;

  // Metadata
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? lastActiveAt;

  ProviderProfile({
    String? id,
    required this.userId,
    required this.providerType,
    this.status = ProviderStatus.pending,
    this.availabilityStatus = AvailabilityStatus.available,
    this.specialization,
    this.servicesOffered = const [],
    this.servicesDescription,
    this.profileImages = const [],
    this.licenseNumber,
    this.registrationId,
    this.experienceYears,
    this.bio,
    this.workExperience = const [],
    this.academicQualifications = const [],
    this.qualifications = const [],
    this.certifications = const [],
    this.languages = const [],
    this.insuranceAccepted = const [],
    this.paymentMethods = const [],
    this.consultationFee,
    this.servicePricing,
    this.currency = 'KES',
    this.workingDays = const [],
    Map<String, String>? workingHours,
    this.acceptingNewPatients = true,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalPatients = 0,
    this.totalAppointments = 0,
    this.verificationDocuments = const [],
    this.verifiedAt,
    this.rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastActiveAt,
  }) : id = id ?? 'provider_${DateTime.now().millisecondsSinceEpoch}',
       workingHours = workingHours ?? {},
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  bool get isVerified => status == ProviderStatus.approved;
  bool get isPending => status == ProviderStatus.pending;
  bool get isRejected => status == ProviderStatus.rejected;
  bool get isSuspended => status == ProviderStatus.suspended;

  bool get isAvailable => availabilityStatus == AvailabilityStatus.available;
  bool get isBusy => availabilityStatus == AvailabilityStatus.busy;
  bool get isOffline => availabilityStatus == AvailabilityStatus.offline;

  bool get isInstitution => providerType.isInstitution;
  bool get isIndividual => providerType.isIndividual;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerType': providerType.toString(),
      'status': status.toString(),
      'availabilityStatus': availabilityStatus.toString(),
      'specialization': specialization,
      'servicesOffered': servicesOffered,
      'servicesDescription': servicesDescription,
      'profileImages': profileImages,
      'licenseNumber': licenseNumber,
      'registrationId': registrationId,
      'experienceYears': experienceYears,
      'bio': bio,
      'academicQualifications': academicQualifications
          .map((q) => q.toJson())
          .toList(),
      'qualifications': qualifications,
      'certifications': certifications,
      'languages': languages,
      'insuranceAccepted': insuranceAccepted,
      'paymentMethods': paymentMethods,
      'consultationFee': consultationFee,
      'servicePricing': servicePricing,
      'currency': currency,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'acceptingNewPatients': acceptingNewPatients,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalPatients': totalPatients,
      'totalAppointments': totalAppointments,
      'verificationDocuments': verificationDocuments,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'],
      userId: json['userId'] ?? '',
      providerType: UserRole.values.firstWhere(
        (e) => e.toString() == json['providerType'],
        orElse: () => UserRole.doctor,
      ),
      status: ProviderStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ProviderStatus.pending,
      ),
      availabilityStatus: AvailabilityStatus.values.firstWhere(
        (e) => e.toString() == json['availabilityStatus'],
        orElse: () => AvailabilityStatus.available,
      ),
      specialization: json['specialization'],
      servicesOffered: List<String>.from(json['servicesOffered'] ?? []),
      servicesDescription: json['servicesDescription'],
      profileImages: List<String>.from(json['profileImages'] ?? []),
      licenseNumber: json['licenseNumber'],
      registrationId: json['registrationId'],
      experienceYears: json['experienceYears'],
      bio: json['bio'],
      academicQualifications:
          (json['academicQualifications'] as List<dynamic>?)
              ?.map((q) => AcademicQualification.fromJson(q))
              .toList() ??
          [],
      qualifications: List<String>.from(json['qualifications'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      insuranceAccepted: List<String>.from(json['insuranceAccepted'] ?? []),
      paymentMethods: List<String>.from(json['paymentMethods'] ?? []),
      consultationFee: json['consultationFee']?.toDouble(),
      servicePricing: json['servicePricing']?.toDouble(),
      currency: json['currency'] ?? 'KES',
      workingDays: List<String>.from(json['workingDays'] ?? []),
      workingHours: Map<String, String>.from(json['workingHours'] ?? {}),
      acceptingNewPatients: json['acceptingNewPatients'] ?? true,
      rating: json['rating']?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      totalPatients: json['totalPatients'] ?? 0,
      totalAppointments: json['totalAppointments'] ?? 0,
      verificationDocuments: List<String>.from(
        json['verificationDocuments'] ?? [],
      ),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      rejectionReason: json['rejectionReason'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'])
          : null,
    );
  }

  ProviderProfile copyWith({
    String? id,
    String? userId,
    UserRole? providerType,
    ProviderStatus? status,
    AvailabilityStatus? availabilityStatus,
    String? specialization,
    List<String>? servicesOffered,
    String? licenseNumber,
    String? registrationId,
    int? experienceYears,
    String? bio,
    List<AcademicQualification>? academicQualifications,
    List<String>? qualifications,
    List<String>? certifications,
    List<String>? languages,
    List<String>? insuranceAccepted,
    List<String>? paymentMethods,
    double? consultationFee,
    double? servicePricing,
    String? currency,
    List<String>? workingDays,
    Map<String, String>? workingHours,
    bool? acceptingNewPatients,
    double? rating,
    int? totalReviews,
    int? totalPatients,
    int? totalAppointments,
    List<String>? verificationDocuments,
    DateTime? verifiedAt,
    String? rejectionReason,
    DateTime? lastActiveAt,
  }) {
    return ProviderProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerType: providerType ?? this.providerType,
      status: status ?? this.status,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      specialization: specialization ?? this.specialization,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      registrationId: registrationId ?? this.registrationId,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      academicQualifications:
          academicQualifications ?? this.academicQualifications,
      qualifications: qualifications ?? this.qualifications,
      certifications: certifications ?? this.certifications,
      languages: languages ?? this.languages,
      insuranceAccepted: insuranceAccepted ?? this.insuranceAccepted,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      consultationFee: consultationFee ?? this.consultationFee,
      servicePricing: servicePricing ?? this.servicePricing,
      currency: currency ?? this.currency,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      acceptingNewPatients: acceptingNewPatients ?? this.acceptingNewPatients,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalPatients: totalPatients ?? this.totalPatients,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      verificationDocuments:
          verificationDocuments ?? this.verificationDocuments,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
