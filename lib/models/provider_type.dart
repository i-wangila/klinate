enum ProviderCategory { individual, facility }

class ProviderType {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final ProviderCategory category;
  final List<String> examples;
  final List<String> requirements;
  final String estimatedSetupTime;

  ProviderType({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.category,
    required this.examples,
    required this.requirements,
    required this.estimatedSetupTime,
  });
}

class ProviderTypeService {
  static final List<ProviderType> _providerTypes = [
    // Individual Healthcare Providers Only
    ProviderType(
      id: 'doctor',
      name: 'Doctor/Physician',
      description:
          'Licensed medical doctors providing consultations, diagnoses, and treatments',
      iconPath: 'assets/icons/doctor.png',
      category: ProviderCategory.individual,
      examples: [
        'General Practitioner',
        'Cardiology',
        'Pediatrics',
        'General Surgery',
        'Psychiatry',
      ],
      requirements: [
        'Medical License',
        'Professional Certification',
        'Valid ID',
      ],
      estimatedSetupTime: '15-20 minutes',
    ),
    ProviderType(
      id: 'nurse',
      name: 'Nurse/Nursing Services',
      description:
          'Registered nurses providing patient care, health education, and medical support',
      iconPath: 'assets/icons/nurse.png',
      category: ProviderCategory.individual,
      examples: [
        'Registered Nurse',
        'Nurse Practitioner',
        'Home Care Nurse',
        'ICU Nurse',
      ],
      requirements: [
        'Nursing License',
        'Professional Certification',
        'Valid ID',
      ],
      estimatedSetupTime: '10-15 minutes',
    ),
    ProviderType(
      id: 'therapist',
      name: 'Therapist/Counselor',
      description:
          'Mental health professionals and physical therapists providing specialized care',
      iconPath: 'assets/icons/therapist.png',
      category: ProviderCategory.individual,
      examples: [
        'Physiotherapist',
        'Psychologist',
        'Occupational Therapist',
        'Speech Therapist',
      ],
      requirements: ['Professional License', 'Certification', 'Valid ID'],
      estimatedSetupTime: '10-15 minutes',
    ),
    ProviderType(
      id: 'nutritionist',
      name: 'Nutritionist/Dietitian',
      description:
          'Certified nutrition experts providing dietary guidance and meal planning',
      iconPath: 'assets/icons/nutritionist.png',
      category: ProviderCategory.individual,
      examples: [
        'Clinical Nutritionist',
        'Sports Nutritionist',
        'Pediatric Dietitian',
      ],
      requirements: [
        'Nutrition Certification',
        'Professional License',
        'Valid ID',
      ],
      estimatedSetupTime: '10-15 minutes',
    ),
    ProviderType(
      id: 'home_care',
      name: 'Home Care Services',
      description:
          'Professional caregivers providing in-home medical and personal care',
      iconPath: 'assets/icons/home_care.png',
      category: ProviderCategory.individual,
      examples: [
        'Home Health Aide',
        'Personal Care Assistant',
        'Medical Companion',
      ],
      requirements: ['Caregiver Certification', 'Background Check', 'Valid ID'],
      estimatedSetupTime: '15-20 minutes',
    ),
  ];

  static List<ProviderType> getAllProviderTypes() {
    return List.from(_providerTypes);
  }

  static List<ProviderType> getIndividualProviders() {
    // Return all provider types (all are individual now)
    return List.from(_providerTypes);
  }

  static List<ProviderType> getFacilityProviders() {
    // No facilities anymore
    return [];
  }

  static ProviderType? getProviderTypeById(String id) {
    try {
      return _providerTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}
