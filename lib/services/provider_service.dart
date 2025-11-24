import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider_profile.dart';
import '../models/user_profile.dart';
import 'user_service.dart';

class ProviderService {
  static const String _storageKey = 'klinate_providers';
  static final Map<String, ProviderProfile> _providers = {};
  static bool _isInitialized = false;

  // Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadProviders();
    _isInitialized = true;
  }

  // Load providers from storage
  static Future<void> _loadProviders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final providersJson = prefs.getString(_storageKey);

      if (providersJson != null) {
        final Map<String, dynamic> providersMap = json.decode(providersJson);
        _providers.clear();
        providersMap.forEach((key, value) {
          _providers[key] = ProviderProfile.fromJson(value);
        });
      }

      if (kDebugMode) {
        print('Providers loaded: ${_providers.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading providers: $e');
      }
    }
  }

  // Save providers to storage
  static Future<void> _saveProviders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final providersMap = _providers.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      final providersJson = json.encode(providersMap);
      await prefs.setString(_storageKey, providersJson);

      if (kDebugMode) {
        print('Providers saved: ${_providers.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving providers: $e');
      }
    }
  }

  // Create a new provider profile
  static Future<ProviderProfile?> createProvider(
    ProviderProfile provider,
  ) async {
    try {
      _providers[provider.id] = provider;
      await _saveProviders();

      if (kDebugMode) {
        print('Provider created: ${provider.id}');
      }

      return provider;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating provider: $e');
      }
      return null;
    }
  }

  // Get provider by ID
  static ProviderProfile? getProviderById(String providerId) {
    return _providers[providerId];
  }

  // Get provider by user ID
  static ProviderProfile? getProviderByUserId(String userId) {
    try {
      return _providers.values.firstWhere((p) => p.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Get all providers for a user (by user ID)
  static List<ProviderProfile> getProvidersByUserId(String userId) {
    return _providers.values.where((p) => p.userId == userId).toList();
  }

  // Get all providers
  static List<ProviderProfile> getAllProviders() {
    return _providers.values.toList();
  }

  // Get approved providers only
  static List<ProviderProfile> getApprovedProviders() {
    return _providers.values
        .where((p) => p.status == ProviderStatus.approved)
        .toList();
  }

  // Get providers by type
  static List<ProviderProfile> getProvidersByType(UserRole type) {
    return _providers.values
        .where((p) => p.providerType == type && p.isVerified)
        .toList();
  }

  // Get providers by specialization
  static List<ProviderProfile> getProvidersBySpecialization(
    String specialization,
  ) {
    return _providers.values
        .where(
          (p) =>
              p.isVerified &&
              p.specialization?.toLowerCase().contains(
                    specialization.toLowerCase(),
                  ) ==
                  true,
        )
        .toList();
  }

  // Search providers
  static List<ProviderProfile> searchProviders(String query) {
    final lowerQuery = query.toLowerCase();
    return _providers.values.where((p) {
      if (!p.isVerified) return false;

      return p.specialization?.toLowerCase().contains(lowerQuery) == true ||
          p.servicesOffered.any((s) => s.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Update provider profile
  static Future<bool> updateProvider(ProviderProfile provider) async {
    try {
      _providers[provider.id] = provider.copyWith();
      await _saveProviders();

      if (kDebugMode) {
        print('Provider updated: ${provider.id}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating provider: $e');
      }
      return false;
    }
  }

  // Update provider status
  static Future<bool> updateProviderStatus(
    String providerId,
    ProviderStatus status, {
    String? rejectionReason,
  }) async {
    try {
      final provider = _providers[providerId];
      if (provider == null) return false;

      _providers[providerId] = provider.copyWith(
        status: status,
        rejectionReason: rejectionReason,
        verifiedAt: status == ProviderStatus.approved ? DateTime.now() : null,
      );

      await _saveProviders();

      if (kDebugMode) {
        print('Provider status updated: $providerId -> $status');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating provider status: $e');
      }
      return false;
    }
  }

  // Update availability status
  static Future<bool> updateAvailabilityStatus(
    String providerId,
    AvailabilityStatus status,
  ) async {
    try {
      final provider = _providers[providerId];
      if (provider == null) return false;

      _providers[providerId] = provider.copyWith(
        availabilityStatus: status,
        lastActiveAt: DateTime.now(),
      );

      await _saveProviders();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating availability: $e');
      }
      return false;
    }
  }

  // Delete provider
  static Future<bool> deleteProvider(String providerId) async {
    try {
      _providers.remove(providerId);
      await _saveProviders();

      if (kDebugMode) {
        print('Provider deleted: $providerId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting provider: $e');
      }
      return false;
    }
  }

  // Get provider statistics
  static Map<String, int> getProviderStats() {
    return {
      'total': _providers.length,
      'approved': _providers.values.where((p) => p.isVerified).length,
      'pending': _providers.values.where((p) => p.isPending).length,
      'rejected': _providers.values.where((p) => p.isRejected).length,
      'suspended': _providers.values.where((p) => p.isSuspended).length,
      'available': _providers.values.where((p) => p.isAvailable).length,
    };
  }

  // Get top rated providers
  static List<ProviderProfile> getTopRatedProviders({int limit = 10}) {
    final providers = _providers.values.where((p) => p.isVerified).toList();
    providers.sort((a, b) => b.rating.compareTo(a.rating));
    return providers.take(limit).toList();
  }

  // Get providers by status (for admin)
  static List<ProviderProfile> getProvidersByStatus(ProviderStatus status) {
    return _providers.values.where((p) => p.status == status).toList();
  }

  // Get provider display name (from linked user)
  static String getProviderDisplayName(String providerId) {
    final provider = getProviderById(providerId);
    if (provider == null) return 'Unknown Provider';

    // Get the linked user profile
    final users = UserService.getAllUsers();
    final user = users.firstWhere(
      (u) => u.id == provider.userId,
      orElse: () => throw Exception('User not found'),
    );

    return user.fullName; // Use fullName which includes title
  }

  // Get provider email (from linked user)
  static String getProviderEmail(String providerId) {
    final provider = getProviderById(providerId);
    if (provider == null) return '';

    final users = UserService.getAllUsers();
    final user = users.firstWhere(
      (u) => u.id == provider.userId,
      orElse: () => throw Exception('User not found'),
    );

    return user.email;
  }

  // Get provider phone (from linked user)
  static String getProviderPhone(String providerId) {
    final provider = getProviderById(providerId);
    if (provider == null) return '';

    final users = UserService.getAllUsers();
    final user = users.firstWhere(
      (u) => u.id == provider.userId,
      orElse: () => throw Exception('User not found'),
    );

    return user.phone;
  }

  // Clear all providers (for testing)
  static Future<void> clearAllProviders() async {
    _providers.clear();
    await _saveProviders();

    if (kDebugMode) {
      print('All providers cleared');
    }
  }
}
