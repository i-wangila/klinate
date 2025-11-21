import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'FAQ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        children: [
          _buildFAQItem(
            context,
            question: 'How do I book an appointment?',
            answer:
                'To book an appointment, navigate to the home screen, search for your preferred doctor or healthcare facility, tap on their profile, and select "Book Appointment". Choose your preferred date and time, then confirm your booking.',
          ),
          _buildFAQItem(
            context,
            question: 'How can I cancel or reschedule my appointment?',
            answer:
                'Go to the Appointments tab from the bottom navigation, find your appointment, and tap on it. You\'ll see options to either reschedule or cancel the appointment.',
          ),
          _buildFAQItem(
            context,
            question: 'What payment methods are accepted?',
            answer:
                'We accept M-Pesa, bank transfers, and credit/debit cards. You can also use your Klinate wallet for quick and easy payments.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I add money to my wallet?',
            answer:
                'Tap on the Profile icon, select Wallet, then tap "Top Up". Choose your preferred payment method (M-Pesa, Bank Transfer, or Card) and enter the amount you wish to add.',
          ),
          _buildFAQItem(
            context,
            question: 'Can I access my medical records?',
            answer:
                'Yes! Go to Settings > Manage My Account > Medical Records to view all your medical documents including lab results, prescriptions, and discharge summaries shared by healthcare providers.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I search for doctors or hospitals?',
            answer:
                'Use the search bar on the home screen to find doctors, hospitals, clinics, pharmacies, or laboratories. You can search by name, specialization, or location.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I filter healthcare facilities by county?',
            answer:
                'When viewing a category (Hospitals, Pharmacies, etc.), tap the three-dot menu icon at the top right and select "Filter by County". Choose your preferred county to see facilities in that area.',
          ),
          _buildFAQItem(
            context,
            question: 'Can I chat with my doctor?',
            answer:
                'Yes! After booking an appointment, you can message your doctor through the Inbox tab. You can also initiate video or voice calls if the doctor is available.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I become a healthcare provider on Klinate?',
            answer:
                'Tap on the Profile icon, then select "Become a Healthcare Provider". Fill in your professional details, upload your credentials, and submit for verification. Our team will review and approve your application.',
          ),
          _buildFAQItem(
            context,
            question: 'Is my personal information secure?',
            answer:
                'Absolutely! We use industry-standard encryption to protect your data. Your medical records and personal information are stored securely and only shared with healthcare providers you authorize.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I update my profile information?',
            answer:
                'Go to Settings > Manage My Account. Here you can update your personal information, medical details, and profile picture.',
          ),
          _buildFAQItem(
            context,
            question: 'What should I do if I forget my password?',
            answer:
                'On the login screen, tap "Forgot Password". Enter your registered email address, and we\'ll send you instructions to reset your password.',
          ),
          _buildFAQItem(
            context,
            question: 'Can I rate and review healthcare providers?',
            answer:
                'Yes! After your appointment, you can rate your experience and leave a review. This helps other users make informed decisions.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I contact customer support?',
            answer:
                'Tap on the Profile icon and select "Contact Us". You can reach us via email, phone, or through the in-app contact form. Our support team is available 24/7.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I enable two-factor authentication?',
            answer:
                'Go to Settings > Security > Two-Factor Authentication. Toggle it on and choose your preferred method: SMS, Email, or Authenticator App. Follow the setup instructions to secure your account.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I change my password?',
            answer:
                'Navigate to Settings > Security > Change Password. Enter your current password, then your new password twice to confirm. Your password must be at least 6 characters long.',
          ),
          _buildFAQItem(
            context,
            question: 'Can I use biometric login?',
            answer:
                'Yes! Go to Settings > Security > Biometric Login and toggle it on. You can use fingerprint or face ID to quickly and securely access your account.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I view my active sessions?',
            answer:
                'Go to Settings > Security > Active Sessions to see all devices logged into your account. You can log out from individual devices or all other devices at once for security.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I check my login history?',
            answer:
                'Navigate to Settings > Security > Login History to view all recent login attempts, including successful and failed logins with device and location information.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I control my privacy settings?',
            answer:
                'Go to Settings > Security > Privacy Settings to control who can view your profile, email, phone number, and who can message you.',
          ),
          _buildFAQItem(
            context,
            question: 'What happens if I deactivate my account?',
            answer:
                'When you deactivate your account, you lose access immediately but can reactivate by logging in within 3 months. If you don\'t log in within 3 months, your account will be permanently deleted.',
          ),
          _buildFAQItem(
            context,
            question: 'What happens if I delete my account?',
            answer:
                'When you request account deletion, you lose access immediately. Your account is scheduled for permanent deletion in 30 days. You can cancel the deletion by logging in within 30 days. After 30 days, all your data is permanently deleted.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I manage notification preferences?',
            answer:
                'Go to Settings > Manage Notifications to control push notifications, email notifications, and SMS notifications. You can enable or disable each type based on your preferences.',
          ),
          _buildFAQItem(
            context,
            question: 'Can I download my personal data?',
            answer:
                'Yes! Go to Settings > Data & Privacy > Download My Data. Your personal data will be exported and sent to your registered email address within a few minutes.',
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
        ],
      ),
    );
  }

  static Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.all(
            ResponsiveUtils.getResponsiveSpacing(context, 16),
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            ResponsiveUtils.getResponsiveSpacing(context, 16),
            0,
            ResponsiveUtils.getResponsiveSpacing(context, 16),
            ResponsiveUtils.getResponsiveSpacing(context, 16),
          ),
          title: Text(
            question,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          iconColor: Colors.black,
          collapsedIconColor: Colors.grey[600],
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
