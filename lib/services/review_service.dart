import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';

class ReviewService {
  static const String _storageKey = 'klinate_reviews';
  static final List<Review> _reviews = [];
  static bool _isInitialized = false;

  // Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadReviews();
    _isInitialized = true;
  }

  // Load reviews from storage
  static Future<void> _loadReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsJson = prefs.getString(_storageKey);

      if (reviewsJson != null && reviewsJson.isNotEmpty) {
        final List<dynamic> reviewsList = json.decode(reviewsJson);
        _reviews.clear();
        _reviews.addAll(
          reviewsList.map((json) => Review.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      // Handle loading error silently
    }
  }

  // Save reviews to storage
  static Future<void> _saveReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsJson = json.encode(
        _reviews.map((review) => review.toJson()).toList(),
      );
      await prefs.setString(_storageKey, reviewsJson);
    } catch (e) {
      // Handle save error silently
    }
  }

  static List<Review> getAllReviews() => List.from(_reviews);

  static List<Review> getReviewsByProvider(String providerId) {
    return _reviews.where((review) => review.providerId == providerId).toList();
  }

  static List<Review> getReviewsByPatient(String patientId) {
    return _reviews.where((review) => review.patientId == patientId).toList();
  }

  static Review? getReviewByAppointment(String appointmentId) {
    try {
      return _reviews.firstWhere(
        (review) => review.appointmentId == appointmentId,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> addReview(Review review) async {
    _reviews.add(review);
    await _saveReviews();
  }

  static Future<void> updateReview(Review updatedReview) async {
    final index = _reviews.indexWhere(
      (review) => review.id == updatedReview.id,
    );
    if (index != -1) {
      _reviews[index] = updatedReview;
      await _saveReviews();
    }
  }

  static Future<void> deleteReview(String reviewId) async {
    _reviews.removeWhere((review) => review.id == reviewId);
    await _saveReviews();
  }

  static ProviderRating getProviderRating(String providerId) {
    final providerReviews = getReviewsByProvider(providerId);

    if (providerReviews.isEmpty) {
      return ProviderRating(
        providerId: providerId,
        averageRating: 0.0,
        totalReviews: 0,
        ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
    }

    final totalRating = providerReviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );
    final averageRating = totalRating / providerReviews.length;

    final ratingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in providerReviews) {
      ratingDistribution[review.rating] =
          (ratingDistribution[review.rating] ?? 0) + 1;
    }

    return ProviderRating(
      providerId: providerId,
      averageRating: averageRating,
      totalReviews: providerReviews.length,
      ratingDistribution: ratingDistribution,
    );
  }

  static bool hasUserReviewedProvider(String patientId, String providerId) {
    return _reviews.any(
      (review) =>
          review.patientId == patientId && review.providerId == providerId,
    );
  }

  static bool hasUserReviewedAppointment(String appointmentId) {
    return _reviews.any((review) => review.appointmentId == appointmentId);
  }

  static String generateReviewId() {
    return 'review_${DateTime.now().millisecondsSinceEpoch}';
  }

  static List<Review> getReviewsByProviderType(ProviderType providerType) {
    return _reviews
        .where((review) => review.providerType == providerType)
        .toList();
  }

  static Map<ProviderType, List<Review>> getReviewsGroupedByType() {
    final Map<ProviderType, List<Review>> grouped = {};
    for (final review in _reviews) {
      if (!grouped.containsKey(review.providerType)) {
        grouped[review.providerType] = [];
      }
      grouped[review.providerType]!.add(review);
    }
    return grouped;
  }

  static double getAverageRatingByProviderType(ProviderType providerType) {
    final typeReviews = getReviewsByProviderType(providerType);
    if (typeReviews.isEmpty) return 0.0;

    final totalRating = typeReviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );
    return totalRating / typeReviews.length;
  }

  static List<Review> getTopRatedProviders({int limit = 10}) {
    final providerRatings = <String, List<Review>>{};

    // Group reviews by provider
    for (final review in _reviews) {
      if (!providerRatings.containsKey(review.providerId)) {
        providerRatings[review.providerId] = [];
      }
      providerRatings[review.providerId]!.add(review);
    }

    // Calculate average ratings and get top providers
    final topProviders = <MapEntry<String, double>>[];
    providerRatings.forEach((providerId, reviews) {
      final avgRating =
          reviews.fold<int>(0, (sum, review) => sum + review.rating) /
          reviews.length;
      topProviders.add(MapEntry(providerId, avgRating));
    });

    topProviders.sort((a, b) => b.value.compareTo(a.value));

    // Return reviews for top providers
    final topReviews = <Review>[];
    for (final entry in topProviders.take(limit)) {
      final providerReviews = providerRatings[entry.key]!;
      topReviews.addAll(providerReviews);
    }

    return topReviews;
  }
}
