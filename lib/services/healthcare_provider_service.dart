import '../models/healthcare_provider.dart';
import 'review_service.dart';

class HealthcareProviderService {
  // Start with empty providers list - real providers will be added through registration
  static final List<HealthcareProvider> _providers = [];

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
      rating: providerRating.averageRating,
      reviewCount: providerRating.totalReviews,
    );
  }

  /// Get provider by ID
  static HealthcareProvider? getProviderById(String id) {
    try {
      return _providers.firstWhere((provider) => provider.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get providers by type
  static List<HealthcareProvider> getProvidersByType(String type) {
    return _providers
        .where((provider) => provider.type.toLowerCase() == type.toLowerCase())
        .map((provider) => _updateProviderRating(provider))
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
        .map((provider) => _updateProviderRating(provider))
        .toList();
  }

  /// Search providers by name, specialization, or location
  static List<HealthcareProvider> searchProviders(String query) {
    final lowerQuery = query.toLowerCase();
    return _providers
        .where(
          (provider) =>
              provider.name.toLowerCase().contains(lowerQuery) ||
              provider.specialization.toLowerCase().contains(lowerQuery) ||
              provider.location.toLowerCase().contains(lowerQuery) ||
              provider.services.any(
                (service) => service.toLowerCase().contains(lowerQuery),
              ),
        )
        .map((provider) => _updateProviderRating(provider))
        .toList();
  }

  /// Get available providers
  static List<HealthcareProvider> getAvailableProviders() {
    return _providers
        .where((provider) => provider.isAvailable)
        .map((provider) => _updateProviderRating(provider))
        .toList();
  }

  /// Get top rated providers
  static List<HealthcareProvider> getTopRatedProviders({int limit = 10}) {
    final providers = getAllProviders();
    providers.sort((a, b) => b.rating.compareTo(a.rating));
    return providers.take(limit).toList();
  }

  /// Add a new provider (for registration)
  static Future<void> addNewProvider(HealthcareProvider provider) async {
    _providers.add(provider);
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
    required String profileImagePath,
  }) {
    final id = 'provider_${DateTime.now().millisecondsSinceEpoch}';

    return HealthcareProvider(
      id: id,
      name: name,
      type: providerType,
      specialization: specialization,
      rating: 0.0,
      reviewCount: 0,
      location: address,
      phone: phone,
      email: email,
      services: services,
      isAvailable: true,
      openingHours: '8:00 AM - 6:00 PM',
      bio: bio,
      qualifications: [],
      certifications: [],
      experienceYears: experienceYears,
      languages: languages,
      consultationFee: consultationFee,
      profileImageUrl: profileImagePath,
      workingDays: workingDays,
      timeSlots: {
        'morning': '8:00 AM - 12:00 PM',
        'afternoon': '2:00 PM - 6:00 PM',
      },
    );
  }

  /// Update provider availability
  static void updateProviderAvailability(String id, bool isAvailable) {
    final index = _providers.indexWhere((provider) => provider.id == id);
    if (index != -1) {
      _providers[index] = _providers[index].copyWith(isAvailable: isAvailable);
    }
  }

  /// Get provider by email
  static HealthcareProvider? getProviderByEmail(String email) {
    try {
      return _providers.firstWhere(
        (provider) => provider.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Update provider
  static Future<void> updateProvider(HealthcareProvider provider) async {
    final index = _providers.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      _providers[index] = provider;
    }
  }

  /// Get provider statistics
  static Map<String, dynamic> getProviderStats() {
    return {
      'total': _providers.length,
      'available': _providers.where((p) => p.isAvailable).length,
      'doctors': getProvidersByType('Doctor').length,
      'nurses': getProvidersByType('Nurse').length,
      'therapists': getProvidersByType('Therapist').length,
      'nutritionists': getProvidersByType('Nutritionist').length,
    };
  }
}
