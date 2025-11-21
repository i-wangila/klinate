import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../services/user_service.dart';

class RateProviderScreen extends StatefulWidget {
  final Appointment appointment;

  const RateProviderScreen({super.key, required this.appointment});

  @override
  State<RateProviderScreen> createState() => _RateProviderScreenState();
}

class _RateProviderScreenState extends State<RateProviderScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

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
            child: Text(
              widget.appointment.providerName
                  .split(' ')
                  .map((e) => e[0])
                  .take(2)
                  .join(),
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appointment.providerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.appointment.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How was your experience?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rate your overall experience with ${widget.appointment.providerName}',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = starNumber;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    starNumber <= _selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    size: 40,
                    color: starNumber <= _selectedRating
                        ? Colors.amber[600]
                        : Colors.grey[400],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedRating > 0)
          Center(
            child: Text(
              _getRatingText(_selectedRating),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getRatingColor(_selectedRating),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share your experience',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Help others by sharing details about your experience',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _commentController,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Write your review here...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(color: Colors.grey[500]),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickComments(),
      ],
    );
  }

  Widget _buildQuickComments() {
    final quickComments = [
      'Professional and caring',
      'Explained everything clearly',
      'Good communication',
      'Punctual and efficient',
      'Would recommend',
      'Knowledgeable',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick comments:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickComments.map((comment) {
            return GestureDetector(
              onTap: () {
                final currentText = _commentController.text;
                final newText = currentText.isEmpty
                    ? comment
                    : '$currentText. $comment';
                _commentController.text = newText;
                _commentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: newText.length),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  comment,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit =
        _selectedRating > 0 && _commentController.text.trim().isNotEmpty;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit && !_isSubmitting ? _submitReview : null,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your review will help other patients make informed decisions',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final review = Review(
        id: ReviewService.generateReviewId(),
        providerId: widget.appointment.providerId,
        patientId: UserService.currentUser?.email ?? 'current_user',
        patientName: UserService.currentUser?.name ?? 'Current User',
        rating: _selectedRating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
        appointmentId: widget.appointment.id,
        providerType: _getProviderType(widget.appointment.providerName),
        providerName: widget.appointment.providerName,
      );

      ReviewService.addReview(review);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
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

  ProviderType _getProviderType(String providerName) {
    // Determine provider type based on name or other criteria
    final name = providerName.toLowerCase();
    if (name.contains('dr.') || name.contains('doctor')) {
      return ProviderType.doctor;
    } else if (name.contains('pharmacy')) {
      return ProviderType.pharmacy;
    } else if (name.contains('hospital')) {
      return ProviderType.hospital;
    } else if (name.contains('lab') || name.contains('lancet')) {
      return ProviderType.laboratory;
    } else if (name.contains('clinic')) {
      return ProviderType.clinic;
    } else if (name.contains('nutritionist')) {
      return ProviderType.nutritionist;
    } else {
      return ProviderType.doctor; // Default fallback
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
