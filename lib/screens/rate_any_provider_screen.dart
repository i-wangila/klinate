import 'package:flutter/material.dart';
import '../models/provider_profile.dart';
import '../models/user_profile.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../services/user_service.dart';

class RateAnyProviderScreen extends StatefulWidget {
  final ProviderProfile provider;

  const RateAnyProviderScreen({super.key, required this.provider});

  @override
  State<RateAnyProviderScreen> createState() => _RateAnyProviderScreenState();
}

class _RateAnyProviderScreenState extends State<RateAnyProviderScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rate & Review',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProviderInfo(),
            const SizedBox(height: 32),
            _buildRatingSection(),
            const SizedBox(height: 32),
            _buildCommentSection(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfo() {
    // Get provider name from user service
    final users = UserService.getAllUsers();
    final user = users.firstWhere(
      (u) => u.id == widget.provider.userId,
      orElse: () => throw Exception('User not found'),
    );
    final providerName = user.name;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue[100],
            child: Icon(Icons.person, size: 30, color: Colors.blue[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  providerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getProviderTypeName(widget.provider.providerType),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                if (widget.provider.rating > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.provider.rating.toStringAsFixed(1)} (${widget.provider.totalReviews} reviews)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getProviderTypeName(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.nurse:
        return 'Nurse';
      case UserRole.therapist:
        return 'Therapist';
      case UserRole.nutritionist:
        return 'Nutritionist';
      case UserRole.homecare:
        return 'Home Care Provider';
      default:
        return 'Healthcare Provider';
    }
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How would you rate your experience?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = starNumber;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  _selectedRating >= starNumber
                      ? Icons.star
                      : Icons.star_border,
                  size: 48,
                  color: _selectedRating >= starNumber
                      ? Colors.amber
                      : Colors.grey[400],
                ),
              ),
            );
          }),
        ),
        if (_selectedRating > 0) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              _getRatingLabel(_selectedRating),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getRatingColor(_selectedRating),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getRatingLabel(int rating) {
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
    if (rating <= 2) return Colors.red;
    if (rating == 3) return Colors.orange;
    return Colors.green;
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share your experience (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Tell us about your experience with this provider...',
            hintStyle: TextStyle(color: Colors.grey[400]),
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
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _selectedRating > 0 && !_isSubmitting;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? _submitReview : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[300],
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
            : const Text(
                'Submit Review',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = UserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Get provider name from user service
      final users = UserService.getAllUsers();
      final providerUser = users.firstWhere(
        (u) => u.id == widget.provider.userId,
        orElse: () => throw Exception('Provider user not found'),
      );

      final review = Review(
        id: 'review_${DateTime.now().millisecondsSinceEpoch}',
        providerId: widget.provider.id,
        patientId: currentUser.id,
        patientName: currentUser.name,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
        appointmentId: 'direct_rating', // No specific appointment
        providerType: _mapUserRoleToProviderType(widget.provider.providerType),
        providerName: providerUser.name,
      );

      ReviewService.addReview(review);

      // Update provider rating in the provider service
      // The rating will be recalculated from all reviews

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Review Submitted!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thank you for sharing your feedback. Your review helps others make informed decisions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to provider profile
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  ProviderType _mapUserRoleToProviderType(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return ProviderType.doctor;
      case UserRole.nutritionist:
        return ProviderType.nutritionist;
      default:
        return ProviderType.doctor;
    }
  }
}
