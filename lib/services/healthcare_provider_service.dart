import '../models/healthcare_provider.dart';
import 'review_service.dart';

class HealthcareProviderService {
  static final List<HealthcareProvider> _providers = [
    HealthcareProvider(
      id: 'dr_sarah_21',
      name: 'Dr. Sarah Mwangi',
      type: 'Doctor',
      specialization: 'Cardiologist',
      rating: 4.86,
      reviewCount: 127,
      location: 'Nairobi Hospital, Nairobi',
      phone: '+254740109195',
      email: 'dr.sarah.mwangi@klinate.com',
      services: [
        'Cardiology Consultation',
        'ECG',
        'Heart Surgery',
        'Preventive Care',
      ],
      isAvailable: true,
      openingHours: '8:00 AM - 6:00 PM',
      bio:
          'Dr. Sarah Mwangi is a highly experienced cardiologist with over 15 years of practice. She specializes in interventional cardiology and has performed over 500 successful cardiac procedures. She is passionate about preventive cardiology and patient education.',
      qualifications: [
        'MBChB - University of Nairobi (2008)',
        'MMed Cardiology - University of Cape Town (2013)',
        'Fellowship in Interventional Cardiology - Johns Hopkins (2015)',
      ],
      certifications: [
        'Kenya Medical Practitioners Board License',
        'American Heart Association Certification',
        'European Society of Cardiology Member',
      ],
      experienceYears: 15,
      languages: ['English', 'Swahili', 'Kikuyu'],
      consultationFee: 2150.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      timeSlots: {
        'morning': '8:00 AM - 12:00 PM',
        'afternoon': '2:00 PM - 6:00 PM',
      },
    ),
    HealthcareProvider(
      id: 'dr_john_45',
      name: 'Dr. John Kamau',
      type: 'Doctor',
      specialization: 'General Practitioner',
      rating: 4.72,
      reviewCount: 89,
      location: 'Aga Khan Hospital, Nairobi',
      phone: '+254 700 234 567',
      email: 'dr.john.kamau@klinate.com',
      services: [
        'General Consultation',
        'Health Checkups',
        'Vaccinations',
        'Minor Procedures',
      ],
      isAvailable: true,
      openingHours: '9:00 AM - 5:00 PM',
      bio:
          'Dr. John Kamau is a dedicated general practitioner with a focus on family medicine and preventive healthcare. He believes in building long-term relationships with his patients and providing comprehensive care for all ages.',
      qualifications: [
        'MBChB - Moi University (2010)',
        'Diploma in Family Medicine - KMTC (2012)',
      ],
      certifications: [
        'Kenya Medical Practitioners Board License',
        'Family Medicine Certification',
      ],
      experienceYears: 12,
      languages: ['English', 'Swahili'],
      consultationFee: 1800.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ],
      timeSlots: {
        'morning': '9:00 AM - 1:00 PM',
        'afternoon': '2:00 PM - 5:00 PM',
      },
    ),
    HealthcareProvider(
      id: 'mary_njeri_67',
      name: 'Mary Njeri',
      type: 'Nutritionist',
      specialization: 'Clinical Nutritionist',
      rating: 4.75,
      reviewCount: 64,
      location: 'Wellness Center, Westlands',
      phone: '+254 700 345 678',
      email: 'mary.njeri@klinate.com',
      services: [
        'Nutrition Counseling',
        'Diet Planning',
        'Weight Management',
        'Sports Nutrition',
      ],
      isAvailable: true,
      openingHours: '8:00 AM - 4:00 PM',
      bio:
          'Mary Njeri is a certified clinical nutritionist with expertise in therapeutic nutrition and lifestyle medicine. She helps clients achieve their health goals through personalized nutrition plans and sustainable lifestyle changes.',
      qualifications: [
        'BSc Nutrition and Dietetics - Kenyatta University (2015)',
        'MSc Clinical Nutrition - University of Nairobi (2018)',
      ],
      certifications: [
        'Kenya Nutritionists and Dietitians Institute License',
        'Certified Diabetes Educator',
      ],
      experienceYears: 8,
      languages: ['English', 'Swahili', 'Kikuyu'],
      consultationFee: 1200.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      timeSlots: {
        'morning': '8:00 AM - 12:00 PM',
        'afternoon': '1:00 PM - 4:00 PM',
      },
    ),

    // Additional Doctors
    HealthcareProvider(
      id: 'dr_grace_wanjiku',
      name: 'Dr. Grace Wanjiku',
      type: 'Doctor',
      specialization: 'Dermatologist',
      rating: 4.89,
      reviewCount: 156,
      location: 'Karen Hospital, Nairobi',
      phone: '+254 700 456 789',
      email: 'dr.grace.wanjiku@klinate.com',
      services: [
        'Skin Consultation',
        'Acne Treatment',
        'Cosmetic Dermatology',
        'Skin Cancer Screening',
      ],
      isAvailable: true,
      openingHours: '9:00 AM - 5:00 PM',
      bio:
          'Dr. Grace Wanjiku is a board-certified dermatologist specializing in medical and cosmetic dermatology with over 12 years of experience.',
      qualifications: [
        'MBChB - University of Nairobi (2011)',
        'MMed Dermatology - University of Cape Town (2016)',
      ],
      certifications: [
        'Kenya Medical Practitioners Board License',
        'International Society of Dermatology Member',
      ],
      experienceYears: 12,
      languages: ['English', 'Swahili', 'Kikuyu'],
      consultationFee: 2500.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      timeSlots: {
        'morning': '9:00 AM - 1:00 PM',
        'afternoon': '2:00 PM - 5:00 PM',
      },
    ),

    HealthcareProvider(
      id: 'dr_peter_mwangi',
      name: 'Dr. Peter Mwangi',
      type: 'Doctor',
      specialization: 'Orthopedic Surgeon',
      rating: 4.95,
      reviewCount: 203,
      location: 'Mater Hospital, Nairobi',
      phone: '+254 700 567 890',
      email: 'dr.peter.mwangi@klinate.com',
      services: [
        'Joint Replacement',
        'Sports Medicine',
        'Fracture Treatment',
        'Arthroscopy',
      ],
      isAvailable: true,
      openingHours: '8:00 AM - 6:00 PM',
      bio:
          'Dr. Peter Mwangi is a renowned orthopedic surgeon with expertise in joint replacement and sports medicine.',
      qualifications: [
        'MBChB - Moi University (2009)',
        'MMed Orthopedic Surgery - University of Nairobi (2014)',
        'Fellowship in Joint Replacement - Mayo Clinic (2016)',
      ],
      certifications: [
        'Kenya Medical Practitioners Board License',
        'American Academy of Orthopedic Surgeons Member',
      ],
      experienceYears: 14,
      languages: ['English', 'Swahili'],
      consultationFee: 3000.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ],
      timeSlots: {
        'morning': '8:00 AM - 12:00 PM',
        'afternoon': '2:00 PM - 6:00 PM',
      },
    ),

    HealthcareProvider(
      id: 'dr_anne_njeri',
      name: 'Dr. Anne Njeri',
      type: 'Doctor',
      specialization: 'Pediatrician',
      rating: 4.92,
      reviewCount: 178,
      location: 'Gertrudes Children Hospital, Nairobi',
      phone: '+254 700 678 901',
      email: 'dr.anne.njeri@klinate.com',
      services: [
        'Child Healthcare',
        'Vaccinations',
        'Growth Monitoring',
        'Newborn Care',
      ],
      isAvailable: true,
      openingHours: '8:00 AM - 5:00 PM',
      bio:
          'Dr. Anne Njeri is a dedicated pediatrician with special interest in child development and preventive care.',
      qualifications: [
        'MBChB - Kenyatta University (2012)',
        'MMed Pediatrics - University of Nairobi (2017)',
      ],
      certifications: [
        'Kenya Medical Practitioners Board License',
        'Pediatric Advanced Life Support Certification',
      ],
      experienceYears: 11,
      languages: ['English', 'Swahili', 'Kikuyu'],
      consultationFee: 2000.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      timeSlots: {
        'morning': '8:00 AM - 12:00 PM',
        'afternoon': '1:00 PM - 5:00 PM',
      },
    ),

    // Nurses
    HealthcareProvider(
      id: 'nurse_mary_wanjiku',
      name: 'Mary Wanjiku',
      type: 'Nurse',
      specialization: 'Registered Nurse',
      rating: 4.78,
      reviewCount: 89,
      location: 'Nairobi Hospital, Nairobi',
      phone: '+254 700 789 012',
      email: 'mary.wanjiku@klinate.com',
      services: [
        'Patient Care',
        'Wound Dressing',
        'Medication Administration',
        'Health Education',
      ],
      isAvailable: true,
      openingHours: '7:00 AM - 7:00 PM',
      bio:
          'Mary Wanjiku is an experienced registered nurse with expertise in critical care and patient education.',
      qualifications: [
        'Diploma in Nursing - KMTC (2015)',
        'BSc Nursing - Kenyatta University (2018)',
      ],
      certifications: [
        'Kenya Nursing Council License',
        'Basic Life Support Certification',
      ],
      experienceYears: 8,
      languages: ['English', 'Swahili', 'Kikuyu'],
      consultationFee: 800.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ],
      timeSlots: {
        'morning': '7:00 AM - 1:00 PM',
        'afternoon': '1:00 PM - 7:00 PM',
      },
    ),

    // Therapists
    HealthcareProvider(
      id: 'therapist_james_ochieng',
      name: 'James Ochieng',
      type: 'Therapist',
      specialization: 'Physiotherapist',
      rating: 4.85,
      reviewCount: 134,
      location: 'Rehab Center, Westlands',
      phone: '+254 700 890 123',
      email: 'james.ochieng@klinate.com',
      services: [
        'Physical Therapy',
        'Sports Rehabilitation',
        'Pain Management',
        'Mobility Training',
      ],
      isAvailable: true,
      openingHours: '8:00 AM - 6:00 PM',
      bio:
          'James Ochieng is a certified physiotherapist specializing in sports rehabilitation and chronic pain management.',
      qualifications: [
        'Diploma in Physiotherapy - KMTC (2014)',
        'BSc Physiotherapy - Kenyatta University (2017)',
      ],
      certifications: [
        'Kenya Physiotherapy Association License',
        'Sports Medicine Certification',
      ],
      experienceYears: 9,
      languages: ['English', 'Swahili', 'Luo'],
      consultationFee: 1500.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ],
      timeSlots: {
        'morning': '8:00 AM - 12:00 PM',
        'afternoon': '2:00 PM - 6:00 PM',
      },
    ),

    HealthcareProvider(
      id: 'therapist_susan_akinyi',
      name: 'Susan Akinyi',
      type: 'Therapist',
      specialization: 'Clinical Psychologist',
      rating: 4.91,
      reviewCount: 167,
      location: 'Mind Wellness Center, Karen',
      phone: '+254 700 901 234',
      email: 'susan.akinyi@klinate.com',
      services: [
        'Mental Health Counseling',
        'Cognitive Behavioral Therapy',
        'Family Therapy',
        'Stress Management',
      ],
      isAvailable: true,
      openingHours: '9:00 AM - 5:00 PM',
      bio:
          'Susan Akinyi is a licensed clinical psychologist with expertise in cognitive behavioral therapy and family counseling.',
      qualifications: [
        'BA Psychology - University of Nairobi (2013)',
        'MA Clinical Psychology - Kenyatta University (2016)',
      ],
      certifications: [
        'Kenya Psychological Association License',
        'CBT Certification',
      ],
      experienceYears: 10,
      languages: ['English', 'Swahili', 'Luo'],
      consultationFee: 2200.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      timeSlots: {
        'morning': '9:00 AM - 1:00 PM',
        'afternoon': '2:00 PM - 5:00 PM',
      },
    ),

    // Additional Nutritionists
    HealthcareProvider(
      id: 'nutritionist_david_kimani',
      name: 'David Kimani',
      type: 'Nutritionist',
      specialization: 'Sports Nutritionist',
      rating: 4.83,
      reviewCount: 92,
      location: 'Fitness Plus Center, Kilimani',
      phone: '+254 700 012 345',
      email: 'david.kimani@klinate.com',
      services: [
        'Sports Nutrition',
        'Performance Enhancement',
        'Weight Management',
        'Supplement Guidance',
      ],
      isAvailable: true,
      openingHours: '6:00 AM - 8:00 PM',
      bio:
          'David Kimani is a certified sports nutritionist helping athletes and fitness enthusiasts optimize their performance through proper nutrition.',
      qualifications: [
        'BSc Nutrition - Kenyatta University (2016)',
        'MSc Sports Nutrition - University of Nairobi (2019)',
      ],
      certifications: [
        'Kenya Nutritionists and Dietitians Institute License',
        'International Society of Sports Nutrition Member',
      ],
      experienceYears: 7,
      languages: ['English', 'Swahili', 'Kikuyu'],
      consultationFee: 1800.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ],
      timeSlots: {
        'morning': '6:00 AM - 12:00 PM',
        'afternoon': '2:00 PM - 8:00 PM',
      },
    ),

    // Dentists
    HealthcareProvider(
      id: 'dr_michael_otieno',
      name: 'Dr. Michael Otieno',
      type: 'Doctor',
      specialization: 'Dentist',
      rating: 4.87,
      reviewCount: 145,
      location: 'Dental Care Center, Kilimani',
      phone: '+254740109195',
      email: 'dr.michael.otieno@klinate.com',
      services: [
        'General Dentistry',
        'Teeth Cleaning',
        'Root Canal Treatment',
        'Dental Implants',
        'Orthodontics',
      ],
      isAvailable: true,
      openingHours: '8:00 AM - 6:00 PM',
      bio:
          'Dr. Michael Otieno is an experienced dentist specializing in cosmetic and restorative dentistry.',
      qualifications: [
        'BDS - University of Nairobi (2014)',
        'Certificate in Orthodontics (2017)',
      ],
      certifications: [
        'Kenya Dental Association License',
        'Implant Dentistry Certification',
      ],
      experienceYears: 9,
      languages: ['English', 'Swahili', 'Luo'],
      consultationFee: 1500.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ],
      timeSlots: {
        'morning': '8:00 AM - 12:00 PM',
        'afternoon': '2:00 PM - 6:00 PM',
      },
    ),

    // Ophthalmologist
    HealthcareProvider(
      id: 'dr_lucy_wambui',
      name: 'Dr. Lucy Wambui',
      type: 'Doctor',
      specialization: 'Ophthalmologist',
      rating: 4.93,
      reviewCount: 187,
      location: 'Eye Care Clinic, Westlands',
      phone: '+254 700 234 567',
      email: 'dr.lucy.wambui@klinate.com',
      services: [
        'Eye Examination',
        'Cataract Surgery',
        'Glaucoma Treatment',
        'Retinal Care',
        'Vision Correction',
      ],
      isAvailable: true,
      openingHours: '8:00 AM - 5:00 PM',
      bio:
          'Dr. Lucy Wambui is a board-certified ophthalmologist with expertise in cataract and retinal surgery.',
      qualifications: [
        'MBChB - University of Nairobi (2010)',
        'MMed Ophthalmology - University of Cape Town (2015)',
      ],
      certifications: [
        'Kenya Medical Practitioners Board License',
        'International Council of Ophthalmology Member',
      ],
      experienceYears: 13,
      languages: ['English', 'Swahili', 'Kikuyu'],
      consultationFee: 2800.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      timeSlots: {
        'morning': '8:00 AM - 12:00 PM',
        'afternoon': '1:00 PM - 5:00 PM',
      },
    ),

    // ENT Specialist
    HealthcareProvider(
      id: 'dr_robert_maina',
      name: 'Dr. Robert Maina',
      type: 'Doctor',
      specialization: 'ENT Specialist',
      rating: 4.81,
      reviewCount: 123,
      location: 'ENT Clinic, Upper Hill',
      phone: '+254 700 345 678',
      email: 'dr.robert.maina@klinate.com',
      services: [
        'Ear Examination',
        'Nose Treatment',
        'Throat Surgery',
        'Hearing Tests',
        'Sinus Treatment',
      ],
      isAvailable: true,
      openingHours: '9:00 AM - 5:00 PM',
      bio:
          'Dr. Robert Maina is an ENT specialist with extensive experience in ear, nose, and throat disorders.',
      qualifications: [
        'MBChB - Moi University (2012)',
        'MMed ENT - University of Nairobi (2017)',
      ],
      certifications: [
        'Kenya Medical Practitioners Board License',
        'ENT Society of Kenya Member',
      ],
      experienceYears: 11,
      languages: ['English', 'Swahili', 'Kikuyu'],
      consultationFee: 2300.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      timeSlots: {
        'morning': '9:00 AM - 1:00 PM',
        'afternoon': '2:00 PM - 5:00 PM',
      },
    ),

    // Pharmacist
    HealthcareProvider(
      id: 'pharm_jane_mutua',
      name: 'Jane Mutua',
      type: 'Pharmacist',
      specialization: 'Clinical Pharmacist',
      rating: 4.76,
      reviewCount: 98,
      location: 'Community Pharmacy, South B',
      phone: '+254 700 456 789',
      email: 'jane.mutua@klinate.com',
      services: [
        'Medication Counseling',
        'Drug Interaction Checks',
        'Health Screenings',
        'Vaccination Services',
        'Chronic Disease Management',
      ],
      isAvailable: true,
      openingHours: '8:00 AM - 8:00 PM',
      bio:
          'Jane Mutua is a clinical pharmacist dedicated to optimizing medication therapy and patient care.',
      qualifications: [
        'BPharm - University of Nairobi (2016)',
        'Clinical Pharmacy Certificate (2018)',
      ],
      certifications: [
        'Pharmacy and Poisons Board License',
        'Clinical Pharmacy Certification',
      ],
      experienceYears: 7,
      languages: ['English', 'Swahili', 'Kamba'],
      consultationFee: 1000.0,
      profileImageUrl: 'https://via.placeholder.com/200',
      workingDays: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ],
      timeSlots: {
        'morning': '8:00 AM - 2:00 PM',
        'afternoon': '2:00 PM - 8:00 PM',
      },
    ),
  ];

  /// Get all healthcare providers with updated ratings
  static List<HealthcareProvider> getAllProviders() {
    return _providers
        .map((provider) => _updateProviderRating(provider))
        .toList();
  }

  /// Update provider rating from review service
  static HealthcareProvider _updateProviderRating(HealthcareProvider provider) {
    final providerRating = ReviewService.getProviderRating(provider.id);
    return provider.copyWith(
      rating: providerRating.averageRating > 0
          ? providerRating.averageRating
          : provider.rating,
      reviewCount: providerRating.totalReviews > 0
          ? providerRating.totalReviews
          : provider.reviewCount,
    );
  }

  /// Get provider by ID with updated rating
  static HealthcareProvider? getProviderById(String id) {
    try {
      final provider = _providers.firstWhere((provider) => provider.id == id);
      return _updateProviderRating(provider);
    } catch (e) {
      return null;
    }
  }

  /// Get provider by email
  static HealthcareProvider? getProviderByEmail(String email) {
    try {
      final provider = _providers.firstWhere(
        (provider) => provider.email.toLowerCase() == email.toLowerCase(),
      );
      return _updateProviderRating(provider);
    } catch (e) {
      return null;
    }
  }

  /// Get providers by type
  static List<HealthcareProvider> getProvidersByType(String type) {
    return _providers
        .where(
          (provider) =>
              provider.type.toLowerCase().contains(type.toLowerCase()),
        )
        .toList();
  }

  /// Get providers by specialization
  static List<HealthcareProvider> getProvidersBySpecialization(
    String specialization,
  ) {
    return _providers
        .where(
          (provider) => provider.specialization.toLowerCase().contains(
            specialization.toLowerCase(),
          ),
        )
        .toList();
  }

  /// Search providers by name or specialization
  static List<HealthcareProvider> searchProviders(String query) {
    if (query.isEmpty) return getAllProviders();

    final lowercaseQuery = query.toLowerCase();
    return _providers
        .where(
          (provider) =>
              provider.name.toLowerCase().contains(lowercaseQuery) ||
              provider.specialization.toLowerCase().contains(lowercaseQuery) ||
              provider.type.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  /// Update provider profile (for provider editing)
  static bool updateProvider(HealthcareProvider updatedProvider) {
    final index = _providers.indexWhere(
      (provider) => provider.id == updatedProvider.id,
    );
    if (index != -1) {
      _providers[index] = updatedProvider;
      return true;
    }
    return false;
  }

  /// Toggle favorite status
  static void toggleFavorite(String providerId) {
    final index = _providers.indexWhere(
      (provider) => provider.id == providerId,
    );
    if (index != -1) {
      _providers[index].isFavorite = !_providers[index].isFavorite;
    }
  }

  /// Get favorite providers
  static List<HealthcareProvider> getFavoriteProviders() {
    return _providers.where((provider) => provider.isFavorite).toList();
  }

  /// Get available providers
  static List<HealthcareProvider> getAvailableProviders() {
    return _providers.where((provider) => provider.isAvailable).toList();
  }

  /// Get providers by rating range
  static List<HealthcareProvider> getProvidersByRating(double minRating) {
    return _providers.where((provider) => provider.rating >= minRating).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  /// Add new healthcare provider (for registration)
  static Future<bool> addNewProvider(HealthcareProvider newProvider) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if provider with same email already exists
      final existingProvider = _providers.any(
        (p) => p.email == newProvider.email,
      );
      if (existingProvider) {
        return false; // Provider already exists
      }

      // Add the new provider
      _providers.add(newProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create provider from registration data
  static HealthcareProvider createProviderFromRegistration({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String specialization,
    required int experienceYears,
    required String bio,
    required double consultationFee,
    required List<String> services,
    required List<String> languages,
    required List<String> workingDays,
    required String providerType,
    String? profileImagePath,
  }) {
    // Generate unique ID
    final id = 'provider_${DateTime.now().millisecondsSinceEpoch}';

    // Create time slots based on provider type
    Map<String, String> timeSlots = {
      'morning': '9:00 AM - 12:00 PM',
      'afternoon': '2:00 PM - 5:00 PM',
    };

    return HealthcareProvider(
      id: id,
      name: name,
      type: providerType,
      specialization: specialization,
      rating: 0.0, // New providers start with no rating
      reviewCount: 0,
      location: address,
      phone: phone,
      email: email,
      services: services,
      isAvailable: true, // New providers are available by default
      openingHours: '9:00 AM - 5:00 PM',
      bio: bio,
      qualifications: [], // Will be updated after document verification
      certifications: [], // Will be updated after document verification
      experienceYears: experienceYears,
      languages: languages,
      consultationFee: consultationFee,
      profileImageUrl: profileImagePath ?? 'https://via.placeholder.com/200',
      workingDays: workingDays,
      timeSlots: timeSlots,
    );
  }
}
