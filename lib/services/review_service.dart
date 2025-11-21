import '../models/review.dart';

class ReviewService {
  static final List<Review> _reviews = [
    // Doctor Reviews
    Review(
      id: '1',
      providerId: 'dr_sarah_21',
      patientId: 'patient_john',
      patientName: 'John Doe',
      rating: 5,
      comment:
          'Excellent doctor! Very professional and caring. Explained everything clearly and provided great treatment.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      appointmentId: 'apt_1',
      providerType: ProviderType.doctor,
      providerName: 'Dr. Sarah Mwangi',
    ),
    Review(
      id: '2',
      providerId: 'dr_sarah_21',
      patientId: 'patient_mary',
      patientName: 'Mary Smith',
      rating: 4,
      comment:
          'Good consultation. Dr. Sarah was knowledgeable and helpful. Would recommend.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      appointmentId: 'apt_2',
      providerType: ProviderType.doctor,
      providerName: 'Dr. Sarah Mwangi',
    ),
    Review(
      id: '3',
      providerId: 'dr_john_45',
      patientId: 'patient_alice',
      patientName: 'Alice Johnson',
      rating: 5,
      comment:
          'Outstanding service! Dr. John was very thorough and took time to answer all my questions.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      appointmentId: 'apt_3',
      providerType: ProviderType.doctor,
      providerName: 'Dr. John Kamau',
    ),
    Review(
      id: '4',
      providerId: 'dr_john_45',
      patientId: 'patient_bob',
      patientName: 'Bob Wilson',
      rating: 4,
      comment: 'Professional and efficient. Good experience overall.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      appointmentId: 'apt_4',
      providerType: ProviderType.doctor,
      providerName: 'Dr. John Kamau',
    ),
    Review(
      id: '9',
      providerId: 'mary_njeri_67',
      patientId: 'patient_david',
      patientName: 'David Kiprotich',
      rating: 5,
      comment:
          'Mary is an amazing nutritionist! She helped me create a sustainable diet plan that actually works. Lost 10kg in 3 months!',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      appointmentId: 'apt_9',
      providerType: ProviderType.nutritionist,
      providerName: 'Mary Njeri',
    ),
    Review(
      id: '10',
      providerId: 'mary_njeri_67',
      patientId: 'patient_lucy',
      patientName: 'Lucy Wanjiru',
      rating: 4,
      comment:
          'Very knowledgeable and patient. The meal plans are practical and easy to follow.',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      appointmentId: 'apt_10',
      providerType: ProviderType.nutritionist,
      providerName: 'Mary Njeri',
    ),

    // Hospital Reviews
    Review(
      id: '5',
      providerId: 'nairobi_hospital',
      patientId: 'patient_sarah',
      patientName: 'Sarah Kimani',
      rating: 5,
      comment:
          'Excellent hospital with state-of-the-art facilities. The staff was very professional and caring. Highly recommend!',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      appointmentId: 'apt_5',
      providerType: ProviderType.hospital,
      providerName: 'Nairobi Hospital',
    ),
    Review(
      id: '6',
      providerId: 'nairobi_hospital',
      patientId: 'patient_james',
      patientName: 'James Mwangi',
      rating: 4,
      comment:
          'Good hospital with modern equipment. The waiting time was reasonable and the doctors were knowledgeable.',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      appointmentId: 'apt_6',
      providerType: ProviderType.hospital,
      providerName: 'Nairobi Hospital',
    ),
    Review(
      id: '7',
      providerId: 'aga_khan_hospital',
      patientId: 'patient_grace',
      patientName: 'Grace Wanjiku',
      rating: 5,
      comment:
          'Outstanding service! The hospital is clean, well-organized, and the medical staff is top-notch. Worth every penny.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      appointmentId: 'apt_7',
      providerType: ProviderType.hospital,
      providerName: 'Aga Khan University Hospital',
    ),

    // Pharmacy Reviews
    Review(
      id: '8',
      providerId: 'goodlife_pharmacy',
      patientId: 'patient_peter',
      patientName: 'Peter Ochieng',
      rating: 4,
      comment:
          'Great pharmacy with a wide selection of medications. The pharmacist was helpful in explaining the prescriptions.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      appointmentId: 'apt_8',
      providerType: ProviderType.pharmacy,
      providerName: 'Goodlife Pharmacy',
    ),
    Review(
      id: '11',
      providerId: 'goodlife_pharmacy',
      patientId: 'patient_ann',
      patientName: 'Ann Wambui',
      rating: 5,
      comment:
          'Excellent service! They have everything I need and the staff is very knowledgeable about medications. Home delivery is a plus!',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      appointmentId: 'apt_11',
      providerType: ProviderType.pharmacy,
      providerName: 'Goodlife Pharmacy',
    ),

    // Laboratory Reviews
    Review(
      id: '12',
      providerId: 'lancet_kenya',
      patientId: 'patient_michael',
      patientName: 'Michael Otieno',
      rating: 5,
      comment:
          'Very professional lab! Quick results, accurate testing, and the staff explained everything clearly. Home sample collection was convenient.',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      appointmentId: 'apt_12',
      providerType: ProviderType.laboratory,
      providerName: 'Lancet Kenya',
    ),
    Review(
      id: '13',
      providerId: 'lancet_kenya',
      patientId: 'patient_faith',
      patientName: 'Faith Njoki',
      rating: 4,
      comment:
          'Good laboratory services. Results came back quickly and were well-formatted. The facility is clean and modern.',
      createdAt: DateTime.now().subtract(const Duration(days: 16)),
      appointmentId: 'apt_13',
      providerType: ProviderType.laboratory,
      providerName: 'Lancet Kenya',
    ),
    Review(
      id: '14',
      providerId: 'lancet_kenya',
      patientId: 'patient_samuel',
      patientName: 'Samuel Kipchoge',
      rating: 5,
      comment:
          'Outstanding lab! The technicians are skilled and the equipment is top-notch. Got my comprehensive health screening done here.',
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
      appointmentId: 'apt_14',
      providerType: ProviderType.laboratory,
      providerName: 'Lancet Kenya',
    ),
  ];

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

  static void addReview(Review review) {
    _reviews.add(review);
  }

  static void updateReview(Review updatedReview) {
    final index = _reviews.indexWhere(
      (review) => review.id == updatedReview.id,
    );
    if (index != -1) {
      _reviews[index] = updatedReview;
    }
  }

  static void deleteReview(String reviewId) {
    _reviews.removeWhere((review) => review.id == reviewId);
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
