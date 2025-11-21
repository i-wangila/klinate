import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../models/provider_profile.dart';
import '../models/user_profile.dart';
import '../models/message.dart';
import '../models/work_experience.dart';
import '../services/provider_service.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';
import 'book_provider_appointment_screen.dart';
import 'rate_any_provider_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  final String providerId;

  const ProviderProfileScreen({super.key, required this.providerId});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  ProviderProfile? provider;
  UserProfile? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    // Ensure services are initialized
    await ProviderService.initialize();
    await UserService.initialize();

    setState(() {
      provider = ProviderService.getProviderById(widget.providerId);
      if (provider != null) {
        final users = UserService.getAllUsers();
        user = users.firstWhere(
          (u) => u.id == provider!.userId,
          orElse: () => UserProfile(
            id: provider!.userId,
            name: 'Provider',
            email: '',
            phone: '',
          ),
        );
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Provider Not Found'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: Text('Provider not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProviderInfo(),
                if (provider!.bio != null && provider!.bio!.isNotEmpty)
                  _buildAboutSection(),
                if (provider!.workExperience.isNotEmpty)
                  _buildExperienceSection(),
                if (provider!.academicQualifications.isNotEmpty)
                  _buildEducationSection(),
                if (provider!.certifications.isNotEmpty)
                  _buildCertificationsSection(),
                if (provider!.servicesOffered.isNotEmpty ||
                    (provider!.servicesDescription != null &&
                        provider!.servicesDescription!.isNotEmpty))
                  _buildServicesSection(),
                if (provider!.insuranceAccepted.isNotEmpty)
                  _buildInsuranceSection(),
                if (provider!.paymentMethods.isNotEmpty)
                  _buildPaymentMethodsSection(),
                if (provider!.workingDays.isNotEmpty ||
                    provider!.workingHours.isNotEmpty)
                  _buildAvailabilityScheduleSection(),
                _buildReviewsSection(),
                _buildContactInformationSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(background: _buildHeaderImage()),
    );
  }

  Widget _buildHeaderImage() {
    if (provider!.profileImages.isNotEmpty) {
      final firstImage = provider!.profileImages.first;
      return Stack(
        fit: StackFit.expand,
        children: [
          kIsWeb
              ? Image.network(
                  firstImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultHeader(),
                )
              : Image.file(
                  File(firstImage),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultHeader(),
                ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return _buildDefaultHeader();
  }

  Widget _buildDefaultHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[50]!, Colors.white],
        ),
      ),
      child: Center(
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blue[100],
          child: Text(
            user!.name.split(' ').map((e) => e[0]).take(2).join(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user!.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          if (provider!.specialization != null)
            Text(
              provider!.specialization!,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                provider!.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${provider!.totalReviews} reviews)',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const Spacer(),
              if (provider!.experienceYears != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider!.experienceYears} years exp.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (provider!.languages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider!.languages.map((lang) {
                return Chip(
                  label: Text(lang),
                  backgroundColor: Colors.grey[200],
                  labelStyle: const TextStyle(fontSize: 12),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Experience',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...provider!.workExperience.map((exp) => _buildExperienceItem(exp)),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(WorkExperience exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.business, color: Colors.grey[600], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp.jobTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exp.organization,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exp.duration} · ${exp.durationText}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                if (exp.location != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    exp.location!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                if (exp.description != null && exp.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    exp.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    // Build professional paragraph from academic qualifications
    final qualificationParagraphs = <String>[];

    for (final qual in provider!.academicQualifications) {
      final parts = <String>[];

      // Add title and education level
      if (qual.educationLevel != 'N/A') {
        parts.add('Holds ${qual.educationLevel}');
      }

      // Add specialization
      if (qual.specialization != 'General' && qual.specialization != 'N/A') {
        parts.add('in ${qual.specialization}');
      }

      // Add field of study
      if (qual.fieldOfStudy != null && qual.fieldOfStudy!.isNotEmpty) {
        parts.add('(${qual.fieldOfStudy})');
      }

      // Add institution
      if (qual.institution != null && qual.institution!.isNotEmpty) {
        parts.add('from ${qual.institution}');
      }

      // Add year
      if (qual.yearCompleted != null) {
        parts.add('(${qual.yearCompleted})');
      }

      if (parts.isNotEmpty) {
        qualificationParagraphs.add(parts.join(' '));
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Education',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${qualificationParagraphs.join('. ')}.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Professional Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            provider!.bio!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Services Offered',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider!.servicesOffered.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: provider!.servicesOffered.map((service) {
                return Chip(
                  label: Text(service),
                  backgroundColor: Colors.blue[50],
                  labelStyle: TextStyle(fontSize: 13, color: Colors.blue[800]),
                );
              }).toList(),
            ),
          if (provider!.servicesDescription != null &&
              provider!.servicesDescription!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              provider!.servicesDescription!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityScheduleSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Days and Times List
          ...provider!.workingDays.map((day) {
            final dayHours = provider!.workingHours[day] ?? 'Not Available';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Day
                  SizedBox(
                    width: 100,
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Times
                  Expanded(
                    child: Text(
                      dayHours,
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, size: 24, color: Colors.black),
                  const SizedBox(width: 8),
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _rateProvider,
                    icon: Icon(Icons.edit, size: 16, color: Colors.blue[700]),
                    label: Text(
                      'Write Review',
                      style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[300]!),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // Navigate to all reviews
                    },
                    child: Text(
                      'View all',
                      style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Rating Summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                provider!.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < provider!.rating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider!.totalReviews} reviews',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Sample Reviews (you can fetch real reviews from ReviewService)
          _buildReviewCard(
            'SK',
            'Sarah Kimani',
            'Nov 12, 2025',
            5,
            'Excellent hospital with state-of-the-art facilities. The staff was very professional and caring. Highly recommend!',
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'JM',
            'James Mwangi',
            'Nov 06, 2025',
            4,
            'Good hospital with modern equipment. The waiting time was reasonable and the doctors were knowledgeable.',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    String initials,
    String name,
    String date,
    int rating,
    String comment,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformationSection() {
    // Get contact info from user profile
    final contactName = user?.name ?? 'Provider';
    final contactPhone = user?.phone ?? '';
    final contactEmail = user?.email ?? '';
    final contactAddress = '';

    // Don't show section if no contact info available
    if (contactPhone.isEmpty && contactEmail.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contacts, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Key Contacts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Contact Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contactName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getProviderTypeName(provider!.providerType),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                // Phone
                if (contactPhone.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.phone, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        contactPhone,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                // Email
                if (contactEmail.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.email, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          contactEmail,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (contactAddress.isNotEmpty) const SizedBox(height: 12),
                ],
                // Address
                if (contactAddress.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          contactAddress,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
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

  void _makePhoneCall(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Would you like to call this number?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $phoneNumber...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Message Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openChat,
                icon: const Icon(Icons.message, size: 16),
                label: const Text('Message', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Call Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (user != null && user!.phone.isNotEmpty) {
                    _makePhoneCall(user!.phone);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Phone number not available'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.phone, size: 16),
                label: const Text('Call', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Book Appointment Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _bookAppointment,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text(
                  'Book Appointment',
                  style: TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Insurance Accepted',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: provider!.insuranceAccepted.map((insurance) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal[200]!),
                ),
                child: Text(
                  insurance,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Certifications & Accreditations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...provider!.certifications.map((certification) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified, color: Colors.green[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      certification,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, size: 24, color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: provider!.paymentMethods.map((method) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.green[700], size: 18),
                    const SizedBox(width: 6),
                    Text(
                      method,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _openChat() {
    // Create a message object to open chat with provider
    final message = Message(
      id: 'provider_${provider!.id}',
      senderId: provider!.id,
      senderName: user!.name,
      content: 'Start a conversation with ${user!.name}',
      timestamp: DateTime.now(),
      type: MessageType.text,
      category: MessageCategory.healthcareProvider,
      isRead: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(message: message)),
    );
  }

  void _bookAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BookProviderAppointmentScreen(provider: provider!),
      ),
    );
  }

  void _rateProvider() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RateAnyProviderScreen(provider: provider!),
      ),
    );
  }
}
