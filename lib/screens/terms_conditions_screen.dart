import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Klinate Terms & Conditions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using Klinate, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              '2. Medical Services',
              'Klinate provides telemedicine services including video consultations, chat consultations, and appointment booking. These services are provided by licensed healthcare professionals.',
            ),
            _buildSection(
              '3. User Responsibilities',
              'Users are responsible for providing accurate medical information and following prescribed treatments. Users must not misuse the platform or provide false information.',
            ),
            _buildSection(
              '4. Privacy and Data Protection',
              'We are committed to protecting your privacy and medical information. All data is encrypted and stored securely in compliance with healthcare regulations.',
            ),
            _buildSection(
              '5. Payment Terms',
              'All consultation fees must be paid through the integrated wallet system. Refunds are available according to our refund policy.',
            ),
            _buildSection(
              '6. Account Security',
              'Users are responsible for maintaining the security of their accounts. We offer security features including two-factor authentication, biometric login, and session management. Users should enable these features and keep their passwords secure.',
            ),
            _buildSection(
              '7. Account Deactivation and Deletion',
              'Users can deactivate their accounts temporarily or request permanent deletion. Deactivated accounts can be reactivated within 3 months by logging in. After 3 months of inactivity, deactivated accounts are permanently deleted. Deletion requests result in immediate loss of access, with permanent deletion occurring after 30 days. Users can cancel deletion by logging in within 30 days.',
            ),
            _buildSection(
              '8. Data Retention',
              'We retain your data as long as your account is active. Upon account deletion, your data is permanently removed after the 30-day grace period. You can request a copy of your data at any time through the app.',
            ),
            _buildSection(
              '9. Limitation of Liability',
              'Klinate is not liable for any damages arising from the use of our services. Emergency medical situations should be handled by calling emergency services immediately.',
            ),
            _buildSection(
              '10. Modifications',
              'We reserve the right to modify these terms at any time. Users will be notified of significant changes via email and in-app notifications.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Email: support@klinate.com'),
            const Text('Phone: +254740109195'),
            const Text('Website: www.klinate.com'),
            const Text('Address: Nairobi, Kenya'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}
