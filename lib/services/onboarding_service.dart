import 'package:flutter/foundation.dart';

class OnboardingService {
  static bool _hasSeenOnboarding = false;

  static bool get hasSeenOnboarding => _hasSeenOnboarding;

  static void completeOnboarding() {
    _hasSeenOnboarding = true;
    // In a real app, you would save this to SharedPreferences or similar
    if (kDebugMode) {
      print('Onboarding completed');
    }
  }

  static void resetOnboarding() {
    _hasSeenOnboarding = false;
    if (kDebugMode) {
      print('Onboarding reset');
    }
  }
}
