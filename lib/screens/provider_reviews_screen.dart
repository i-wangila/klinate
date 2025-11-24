import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';
import '../models/user_profile.dart';
import '../services/review_service.dart';
import '../services/user_service.dart';
import '../services/provider_service.dart';

class ProviderReviewsScreen extends StatefulWidget {
  final String providerId;
  final String providerName;

  const ProviderReviewsScreen({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  late List<Review> _reviews;
  late ProviderRating _providerRating;
  int _selectedFilter = 0; // 0 = All, 1-5 = Star ratings

  // Review form state
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  // Scroll controller for auto-scroll to review form
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    _reviews = ReviewService.getReviewsByProvider(widget.providerId);
    _providerRating = ReviewService.getProviderRating(widget.providerId);
    _reviews.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    ); // Most recent first
  }

  List<Review> get _filteredReviews {
    if (_selectedFilter == 0) return _reviews;
    return _reviews
        .where((review) => review.rating == _selectedFilter)
        .toList();
  }

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
        title: Text(
          'Reviews',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildRatingSummary(),
            _buildFilterTabs(),
            _buildReviewsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scrollToReviewForm,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.blue, width: 1),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.providerName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _providerRating.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < _providerRating.averageRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber[600],
                      size: 24,
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_providerRating.totalReviews} reviews',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildRatingDistribution(),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final count = _providerRating.ratingDistribution[stars] ?? 0;
        final percentage = _providerRating.totalReviews > 0
            ? count / _providerRating.totalReviews
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(
                '$stars',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.star, size: 16, color: Colors.amber[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber[600],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', '5★', '4★', '3★', '2★', '1★'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          final count = index == 0
              ? _reviews.length
              : (_providerRating.ratingDistribution[6 - index] ?? 0);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  '${filters[index]} ($count)',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsList() {
    final filteredReviews = _filteredReviews;

    return Column(
      children: [
        if (filteredReviews.isEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reviews found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFilter == 0
                        ? 'Be the first to leave a review!'
                        : 'No reviews with ${6 - _selectedFilter} stars yet.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: filteredReviews.length,
            itemBuilder: (context, index) {
              final review = filteredReviews[index];
              return _buildReviewCard(review);
            },
          ),
        // Add separator before review form
        if (filteredReviews.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Write Your Review',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
          ),
        ],
        // Add review form at the bottom
        _buildAddReviewSection(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                    color: Colors.amber[600],
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReviewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Write a Review',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your experience with ${widget.providerName}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildRatingInput(),
          const SizedBox(height: 24),
          _buildCommentInput(),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildRatingInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            if (_selectedRating == 0)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = starNumber;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  starNumber <= _selectedRating
                      ? Icons.star
                      : Icons.star_border,
                  size: 36,
                  color: starNumber <= _selectedRating
                      ? Colors.amber[600]
                      : Colors.grey[400],
                ),
              ),
            );
          }),
        ),
        if (_selectedRating > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getRatingColor(_selectedRating).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getRatingColor(_selectedRating).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _getRatingText(_selectedRating),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getRatingColor(_selectedRating),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'Please select a rating',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Your Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _commentController.text.trim().isEmpty
                  ? Colors.grey[300]!
                  : Colors.blue[300]!,
            ),
          ),
          child: TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Share your experience with ${widget.providerName}...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(color: Colors.grey[500]),
            ),
            style: const TextStyle(fontSize: 15),
            onChanged: (value) {
              setState(() {}); // Trigger rebuild to update border color
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _commentController,
      builder: (context, value, child) {
        final canSubmit = _selectedRating > 0 && value.text.trim().isNotEmpty;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit && !_isSubmitting ? _submitReview : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit ? Colors.white : Colors.grey[300],
              foregroundColor: canSubmit ? Colors.black : Colors.grey[600],
              side: canSubmit
                  ? const BorderSide(color: Colors.black, width: 1)
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    canSubmit
                        ? 'Submit Review'
                        : 'Please rate and write a review',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.red[600]!;
      case 3:
        return Colors.orange[600]!;
      case 4:
      case 5:
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  void _submitReview() async {
    if (_selectedRating == 0 || _commentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = UserService.currentUser;

      // Validate user is logged in
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Only patients can write reviews
      if (currentUser.currentRole != UserRole.patient) {
        throw Exception('Only patients can write reviews');
      }

      // Get provider to check if user is reviewing themselves
      final provider = ProviderService.getProviderById(widget.providerId);
      if (provider != null && provider.userId == currentUser.id) {
        throw Exception('You cannot review your own business account');
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final review = Review(
        id: ReviewService.generateReviewId(),
        providerId: widget.providerId,
        patientId: currentUser.id,
        patientName: currentUser.name,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
        appointmentId:
            'general_review_${DateTime.now().millisecondsSinceEpoch}', // General review ID
        providerType: ProviderType.doctor, // Default to doctor for this screen
        providerName: widget.providerName,
      );

      await ReviewService.addReview(review);

      // Reload reviews to show the new one
      setState(() {
        _loadReviews();
        _selectedRating = 0;
        _commentController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your review!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit review. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _scrollToReviewForm() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
