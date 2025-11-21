import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
              'Klinate Privacy Policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Effective Date: January 1, ${DateTime.now().year}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              'We collect personal information including name, email, phone number, medical history, and payment information to provide healthcare services.',
            ),
            _buildSection(
              'How We Use Your Information',
              'Your information is used to provide medical consultations, process payments, send appointment reminders, and improve our services.',
            ),
            _buildSection(
              'Data Security',
              'We implement industry-standard security measures including encryption, secure servers, two-factor authentication, biometric login, and access controls to protect your medical information. We monitor active sessions and maintain login history for security purposes.',
            ),
            _buildSection(
              'Information Sharing',
              'We do not sell your personal information. We may share information with healthcare providers involved in your care and as required by law. You can control who can view your profile information through privacy settings.',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to access, update, or delete your personal information. You can request a copy of your medical records and personal data at any time. You can also control your privacy settings, manage active sessions, and view your login history.',
            ),
            _buildSection(
              'Account Deactivation and Deletion',
              'You can deactivate your account temporarily (reactivate within 3 months) or request permanent deletion (30-day grace period). During deactivation or deletion grace periods, you can reactivate your account by logging in. After the grace period expires, all your data is permanently deleted and cannot be recovered.',
            ),
            _buildSection(
              'Data Retention',
              'We retain your data while your account is active and during grace periods. Deactivated accounts are deleted after 3 months of inactivity. Deletion requests result in permanent data removal after 30 days. You can download your data before deletion.',
            ),
            _buildSection(
              'Cookies and Tracking',
              'We use cookies to improve user experience and analyze app usage. You can disable cookies in your browser settings.',
            ),
            _buildSection(
              'Children\'s Privacy',
              'Our services are not intended for children under 13. We do not knowingly collect information from children under 13.',
            ),
            _buildSection(
              'Changes to This Policy',
              'We may update this privacy policy periodically. We will notify users of significant changes via email or app notifications.',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If you have questions about this privacy policy:',
                  ),
                  const SizedBox(height: 8),
                  const Text('Email: privacy@klinate.com'),
                  const Text('Phone: +254740109195'),
                  const Text('Website: www.klinate.com'),
                ],
              ),
            ),
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
