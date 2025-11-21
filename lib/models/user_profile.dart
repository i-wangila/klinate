enum UserRole {
  patient,
  doctor,
  nurse,
  therapist,
  nutritionist,
  homecare,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.nurse:
        return 'Nurse';
      case UserRole.therapist:
        return 'Therapist';
      case UserRole.nutritionist:
        return 'Nutritionist';
      case UserRole.homecare:
        return 'Home Care Provider';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  bool get isProvider {
    return this != UserRole.patient && this != UserRole.admin;
  }

  bool get isAdmin {
    return this == UserRole.admin;
  }

  bool get isInstitution {
    return false; // No institutions anymore, only individual providers
  }

  bool get isIndividual {
    return isProvider;
  }
}

class UserProfile {
  final String id;
  String name;
  String email;
  String phone;
  String? password;
  String? profilePicturePath;
  List<UserRole> roles; // Multiple roles support
  UserRole currentRole; // Active role
  bool isOnline;
  String dateOfBirth;
  String gender;
  String address;
  String emergencyContact;
  String bloodType;
  String? weight;
  String? height;
  List<String> allergies;
  List<String> medications;
  List<String> medicalConditions;
  DateTime createdAt;
  DateTime updatedAt;

  UserProfile({
    String? id,
    required this.name,
    required this.email,
    required this.phone,
    this.password,
    this.profilePicturePath,
    List<UserRole>? roles,
    UserRole? currentRole,
    this.isOnline = false,
    this.dateOfBirth = '',
    this.gender = '',
    this.address = '',
    this.emergencyContact = '',
    this.bloodType = '',
    this.weight,
    this.height,
    this.allergies = const [],
    this.medications = const [],
    this.medicalConditions = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
       roles = roles ?? [UserRole.patient],
       currentRole = currentRole ?? UserRole.patient,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  bool hasRole(UserRole role) => roles.contains(role);

  bool get isPatient => currentRole == UserRole.patient;
  bool get isProvider => currentRole.isProvider;
  bool get isAdmin => currentRole.isAdmin;
  bool get isInstitution => currentRole.isInstitution;
  bool get isIndividual => currentRole.isIndividual;

  bool get hasMultipleRoles => roles.length > 1;

  List<UserRole> get providerRoles =>
      roles.where((role) => role.isProvider).toList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'profilePicturePath': profilePicturePath,
      'roles': roles.map((r) => r.toString()).toList(),
      'currentRole': currentRole.toString(),
      'isOnline': isOnline,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'emergencyContact': emergencyContact,
      'bloodType': bloodType,
      'weight': weight,
      'height': height,
      'allergies': allergies,
      'medications': medications,
      'medicalConditions': medicalConditions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'],
      profilePicturePath: json['profilePicturePath'],
      roles:
          (json['roles'] as List?)
              ?.map(
                (r) => UserRole.values.firstWhere(
                  (e) => e.toString() == r,
                  orElse: () => UserRole.patient,
                ),
              )
              .toList() ??
          [UserRole.patient],
      currentRole: UserRole.values.firstWhere(
        (e) => e.toString() == json['currentRole'],
        orElse: () => UserRole.patient,
      ),
      isOnline: json['isOnline'] ?? false,
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      bloodType: json['bloodType'] ?? '',
      weight: json['weight'],
      height: json['height'],
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? profilePicturePath,
    List<UserRole>? roles,
    UserRole? currentRole,
    bool? isOnline,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? emergencyContact,
    String? bloodType,
    String? weight,
    String? height,
    List<String>? allergies,
    List<String>? medications,
    List<String>? medicalConditions,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      roles: roles ?? this.roles,
      currentRole: currentRole ?? this.currentRole,
      isOnline: isOnline ?? this.isOnline,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bloodType: bloodType ?? this.bloodType,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
