import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class ProviderReviewsListScreen extends StatefulWidget {
  final String providerId;
  final String providerName;
  final ProviderType providerType;

  const ProviderReviewsListScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.providerType,
  });

  @override
  State<ProviderReviewsListScreen> createState() =>
      _ProviderReviewsListScreenState();
}

class _ProviderReviewsListScreenState extends State<ProviderReviewsListScreen> {
  int _selectedRatingFilter = 0; // 0 means all ratings

  @override
  Widget build(BuildContext context) {
    final reviews = ReviewService.getReviewsByProvider(widget.providerId);
    final providerRating = ReviewService.getProviderRating(widget.providerId);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.providerName} Reviews',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildRatingSummary(providerRating),
          _buildRatingFilter(),
          Expanded(child: _buildReviewsList(reviews)),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(ProviderRating rating) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getProviderTypeColor(
                    widget.providerType,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getProviderTypeIcon(widget.providerType),
                  size: 24,
                  color: _getProviderTypeColor(widget.providerType),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.providerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getProviderTypeLabel(widget.providerType),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      rating.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 20,
                          color: Colors.amber[600],
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rating.totalReviews} reviews',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  children: List.generate(5, (index) {
                    final starCount = 5 - index;
                    final count = rating.ratingDistribution[starCount] ?? 0;
                    final percentage = rating.totalReviews > 0
                        ? (count / rating.totalReviews)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$starCount',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.star, size: 12, color: Colors.amber[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.amber[600]!,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Text(
            'Filter by rating: ',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          _buildRatingFilterChip('All', 0),
          const SizedBox(width: 8),
          _buildRatingFilterChip('5★', 5),
          const SizedBox(width: 8),
          _buildRatingFilterChip('4★+', 4),
          const SizedBox(width: 8),
          _buildRatingFilterChip('3★+', 3),
        ],
      ),
    );
  }

  Widget _buildRatingFilterChip(String label, int rating) {
    final isSelected = _selectedRatingFilter == rating;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRatingFilter = rating;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber[300]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.amber[800] : Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList(List<Review> allReviews) {
    final filteredReviews = _getFilteredReviews(allReviews);

    if (filteredReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No reviews found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredReviews.length,
      itemBuilder: (context, index) {
        final review = filteredReviews[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildReviewCard(review),
        );
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: Text(
                  review.patientName.split(' ').map((e) => e[0]).take(2).join(),
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(review.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber[600],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  List<Review> _getFilteredReviews(List<Review> reviews) {
    if (_selectedRatingFilter == 0) {
      return reviews;
    }

    return reviews
        .where((review) => review.rating >= _selectedRatingFilter)
        .toList();
  }

  Color _getProviderTypeColor(ProviderType type) {
    switch (type) {
      case ProviderType.doctor:
        return Colors.blue;
      case ProviderType.hospital:
        return Colors.red;
      case ProviderType.pharmacy:
        return Colors.green;
      case ProviderType.laboratory:
        return Colors.purple;
      case ProviderType.clinic:
        return Colors.orange;
      case ProviderType.nutritionist:
        return Colors.teal;
    }
  }

  String _getProviderTypeLabel(ProviderType type) {
    switch (type) {
      case ProviderType.doctor:
        return 'Doctor';
      case ProviderType.hospital:
        return 'Hospital';
      case ProviderType.pharmacy:
        return 'Pharmacy';
      case ProviderType.laboratory:
        return 'Laboratory';
      case ProviderType.clinic:
        return 'Clinic';
      case ProviderType.nutritionist:
        return 'Nutritionist';
    }
  }

  IconData _getProviderTypeIcon(ProviderType type) {
    switch (type) {
      case ProviderType.doctor:
        return Icons.medical_services;
      case ProviderType.hospital:
        return Icons.local_hospital;
      case ProviderType.pharmacy:
        return Icons.local_pharmacy;
      case ProviderType.laboratory:
        return Icons.science;
      case ProviderType.clinic:
        return Icons.healing;
      case ProviderType.nutritionist:
        return Icons.restaurant_menu;
    }
  }
}
