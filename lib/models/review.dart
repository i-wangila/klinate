enum ProviderType {
  doctor,
  pharmacy,
  laboratory,
  hospital,
  clinic,
  nutritionist,
}

class Review {
  final String id;
  final String providerId;
  final String patientId;
  final String patientName;
  final int rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;
  final String appointmentId;
  final ProviderType providerType;
  final String providerName;

  Review({
    required this.id,
    required this.providerId,
    required this.patientId,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.appointmentId,
    required this.providerType,
    required this.providerName,
  });

  Review copyWith({
    String? id,
    String? providerId,
    String? patientId,
    String? patientName,
    int? rating,
    String? comment,
    DateTime? createdAt,
    String? appointmentId,
    ProviderType? providerType,
    String? providerName,
  }) {
    return Review(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      appointmentId: appointmentId ?? this.appointmentId,
      providerType: providerType ?? this.providerType,
      providerName: providerName ?? this.providerName,
    );
  }
}

class ProviderRating {
  final String providerId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // star -> count

  ProviderRating({
    required this.providerId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  ProviderRating copyWith({
    String? providerId,
    double? averageRating,
    int? totalReviews,
    Map<int, int>? ratingDistribution,
  }) {
    return ProviderRating(
      providerId: providerId ?? this.providerId,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
    );
  }
}
