import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/responsive_utils.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About Klinate'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppHeader(context),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
            _buildAboutSection(context),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            _buildFeaturesSection(context),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            _buildMissionSection(context),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            _buildContactSection(context),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            _buildTechnicalSection(context),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            _buildDeveloperSection(context),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
            _buildCopyright(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: ResponsiveUtils.isSmallScreen(context) ? 80 : 100,
            height: ResponsiveUtils.isSmallScreen(context) ? 80 : 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: Icon(
              Icons.medical_services,
              size: ResponsiveUtils.isSmallScreen(context) ? 40 : 50,
              color: Colors.black,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Text(
            'Klinate',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Telemedicine & Healthcare Platform',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getResponsiveSpacing(context, 12),
              vertical: ResponsiveUtils.getResponsiveSpacing(context, 6),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'About Klinate',
      icon: Icons.info_outline,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Klinate is a comprehensive telemedicine and healthcare platform designed to revolutionize how patients access healthcare services. Our mission is to make quality healthcare accessible, affordable, and convenient for everyone.',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Text(
            'Built with cutting-edge technology, Klinate connects patients with healthcare providers, facilitates secure communication, manages medical records, and provides a seamless healthcare experience from the comfort of your home.',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.video_call,
        'title': 'Video Consultations',
        'description': 'High-quality video calls with healthcare providers',
      },
      {
        'icon': Icons.chat,
        'title': 'Secure Messaging',
        'description': 'HIPAA-compliant communication with your doctors',
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Appointment Booking',
        'description':
            'Easy scheduling with your preferred healthcare providers',
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Digital Wallet',
        'description': 'Secure payments with multiple payment methods',
      },
      {
        'icon': Icons.medical_services,
        'title': 'Health Records',
        'description': 'Comprehensive digital health record management',
      },
      {
        'icon': Icons.local_pharmacy,
        'title': 'Pharmacy Integration',
        'description': 'Direct prescription delivery and pharmacy services',
      },
    ];

    return _buildSection(
      context: context,
      title: 'Key Features',
      icon: Icons.star,
      content: Column(
        children: features
            .map((feature) => _buildFeatureItem(context, feature))
            .toList(),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, Map<String, dynamic> feature) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 8),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              feature['icon'],
              color: Colors.black,
              size: ResponsiveUtils.isSmallScreen(context) ? 20 : 24,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'],
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      13,
                    ),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 4),
                ),
                Text(
                  feature['description'],
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'Our Mission',
      icon: Icons.favorite,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To democratize healthcare by leveraging technology to bridge the gap between patients and healthcare providers, ensuring that quality medical care is accessible to everyone, regardless of their location or circumstances.',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              color: Colors.grey[700],
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.black, size: 20),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              Expanded(
                child: Text(
                  'Improve healthcare accessibility',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.black, size: 20),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              Expanded(
                child: Text(
                  'Reduce healthcare costs',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.black, size: 20),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              Expanded(
                child: Text(
                  'Enhance patient experience',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'Contact & Support',
      icon: Icons.contact_support,
      content: Column(
        children: [
          _buildContactItem(
            context: context,
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'support@klinate.com',
            onTap: () => _launchEmail('support@klinate.com'),
          ),
          _buildContactItem(
            context: context,
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: '+254740109195',
            onTap: () => _launchPhone('+254740109195'),
          ),
          _buildContactItem(
            context: context,
            icon: Icons.language,
            title: 'Website',
            subtitle: 'www.klinate.com',
            onTap: () => _launchWebsite('https://www.klinate.com'),
          ),
          _buildContactItem(
            context: context,
            icon: Icons.location_on,
            title: 'Address',
            subtitle: 'Nairobi, Kenya',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 8),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 12),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
        ),
        decoration: BoxDecoration(
          color: onTap != null ? Colors.grey[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 20),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        14,
                      ),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        13,
                      ),
                      color: onTap != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'Technical Information',
      icon: Icons.code,
      content: Column(
        children: [
          _buildTechItem(context, 'Platform', 'Flutter & Dart'),
          _buildTechItem(context, 'Security', 'End-to-End Encryption'),
          _buildTechItem(context, 'Compliance', 'HIPAA Compliant'),
          _buildTechItem(context, 'Supported Platforms', 'iOS, Android, Web'),
          _buildTechItem(
            context,
            'Data Storage',
            'Secure Cloud Infrastructure',
          ),
          _buildTechItem(context, 'Payment Processing', 'PCI DSS Compliant'),
        ],
      ),
    );
  }

  Widget _buildTechItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtils.isSmallScreen(context) ? 100 : 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'Developer',
      icon: Icons.person,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  width: ResponsiveUtils.isSmallScreen(context) ? 50 : 60,
                  height: ResponsiveUtils.isSmallScreen(context) ? 50 : 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: Icon(
                    Icons.person,
                    size: ResponsiveUtils.isSmallScreen(context) ? 25 : 30,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Isaac Wabwile Wangila',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            18,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          4,
                        ),
                      ),
                      Text(
                        'Author & Developer',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            14,
                          ),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          8,
                        ),
                      ),
                      Text(
                        'Full-stack developer passionate about creating innovative healthcare solutions that make a difference in people\'s lives.',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            14,
                          ),
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(context, 8),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Icon(
                  icon,
                  color: Colors.black,
                  size: ResponsiveUtils.isSmallScreen(context) ? 20 : 24,
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(context, 12),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      15,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          content,
        ],
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Divider(color: Colors.grey[300]),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Text(
            '© 2025 Klinate. All rights reserved.',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
          Text(
            'Developed by Isaac Wabwile Wangila',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
        ],
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Klinate Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchWebsite(String url) async {
    final Uri webUri = Uri.parse(url);
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}
