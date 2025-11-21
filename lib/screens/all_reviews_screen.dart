import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class AllReviewsScreen extends StatefulWidget {
  const AllReviewsScreen({super.key});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  ProviderType? _selectedProviderType;
  int _selectedRatingFilter = 0; // 0 means all ratings
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Reviews',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildReviewsList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search reviews...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Provider type filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Doctors', ProviderType.doctor),
                const SizedBox(width: 8),
                _buildFilterChip('Hospitals', ProviderType.hospital),
                const SizedBox(width: 8),
                _buildFilterChip('Pharmacies', ProviderType.pharmacy),
                const SizedBox(width: 8),
                _buildFilterChip('Labs', ProviderType.laboratory),
                const SizedBox(width: 8),
                _buildFilterChip('Clinics', ProviderType.clinic),
                const SizedBox(width: 8),
                _buildFilterChip('Nutritionists', ProviderType.nutritionist),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rating filter
          Row(
            children: [
              const Text(
                'Rating: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              _buildRatingFilter('All', 0),
              const SizedBox(width: 8),
              _buildRatingFilter('5★', 5),
              const SizedBox(width: 8),
              _buildRatingFilter('4★+', 4),
              const SizedBox(width: 8),
              _buildRatingFilter('3★+', 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ProviderType? type) {
    final isSelected = _selectedProviderType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProviderType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingFilter(String label, int rating) {
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

  Widget _buildReviewsList() {
    final filteredReviews = _getFilteredReviews();

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
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProviderTypeColor(review.providerType),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getProviderTypeLabel(review.providerType),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Provider info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getProviderTypeIcon(review.providerType),
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  review.providerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  size: 20,
                  color: Colors.amber[600],
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${review.rating}/5',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comment
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  List<Review> _getFilteredReviews() {
    List<Review> reviews = ReviewService.getAllReviews();

    // Filter by provider type
    if (_selectedProviderType != null) {
      reviews = reviews
          .where((review) => review.providerType == _selectedProviderType)
          .toList();
    }

    // Filter by rating
    if (_selectedRatingFilter > 0) {
      reviews = reviews
          .where((review) => review.rating >= _selectedRatingFilter)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      reviews = reviews
          .where(
            (review) =>
                review.providerName.toLowerCase().contains(query) ||
                review.comment.toLowerCase().contains(query) ||
                review.patientName.toLowerCase().contains(query),
          )
          .toList();
    }

    // Sort by date (newest first)
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return reviews;
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
        return 'Lab';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
