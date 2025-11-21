import 'package:flutter/material.dart';
import 'provider_type_selection_screen.dart';

class BecomeProviderScreen extends StatefulWidget {
  const BecomeProviderScreen({super.key});

  @override
  State<BecomeProviderScreen> createState() => _BecomeProviderScreenState();
}

class _BecomeProviderScreenState extends State<BecomeProviderScreen> {
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildBenefitsSection(),
              const SizedBox(height: 32),
              _buildStepsSection(),
              const SizedBox(height: 32),
              _buildEarningsSection(),
              const SizedBox(height: 40),
              _buildGetStartedButton(),
              const SizedBox(height: 24),
              _buildFooterText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.medical_services,
            size: 48,
            color: Colors.blue[600],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Create a Healthcare Business Account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Join Klinate\'s network of healthcare professionals and facilities. Create your business account to connect with patients, grow your practice, and make healthcare more accessible.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.people,
        'title': 'Reach More Patients',
        'description':
            'Connect with patients across Kenya looking for quality healthcare services',
      },
      {
        'icon': Icons.schedule,
        'title': 'Flexible Scheduling',
        'description':
            'Set your own availability and manage appointments on your terms',
      },
      {
        'icon': Icons.trending_up,
        'title': 'Grow Your Practice',
        'description':
            'Expand your patient base and increase your healthcare practice revenue',
      },
      {
        'icon': Icons.support_agent,
        'title': '24/7 Support',
        'description':
            'Get dedicated support to help you succeed on our platform',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why join Klinate?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        ...benefits.map(
          (benefit) => _buildBenefitItem(
            benefit['icon'] as IconData,
            benefit['title'] as String,
            benefit['description'] as String,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.green[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    final steps = [
      {
        'number': '1',
        'title': 'Choose Your Service Type',
        'description':
            'Select whether you\'re a healthcare professional or healthcare facility',
      },
      {
        'number': '2',
        'title': 'Basic Information',
        'description':
            'Add your name, professional headline, and location details',
      },
      {
        'number': '3',
        'title': 'Professional Summary',
        'description':
            'Write your bio and describe your professional background',
      },
      {
        'number': '4',
        'title': 'Work Experience',
        'description': 'Add your work history, positions, and organizations',
      },
      {
        'number': '5',
        'title': 'Education & Qualifications',
        'description': 'List your academic qualifications and degrees',
      },
      {
        'number': '6',
        'title': 'Licenses & Certifications',
        'description': 'Add your professional licenses and certifications',
      },
      {
        'number': '7',
        'title': 'Services & Availability',
        'description':
            'Set services, fees, insurance, payments, and working hours',
      },
      {
        'number': '8',
        'title': 'Documents & Verification',
        'description': 'Upload credentials and submit for admin approval',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How it works',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return _buildStepItem(
            step['number'] as String,
            step['title'] as String,
            step['description'] as String,
            isLast: index == steps.length - 1,
          );
        }),
      ],
    );
  }

  Widget _buildStepItem(
    String number,
    String title,
    String description, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.green[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, size: 32, color: Colors.green[600]),
              const SizedBox(width: 12),
              const Text(
                'Earning Potential',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Healthcare professionals and facilities on Klinate earn competitive rates.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '* Earnings vary based on specialization, experience, and service type',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProviderTypeSelectionScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Column(
      children: [
        Text(
          'By continuing, you agree to Klinate\'s Terms of Service and Privacy Policy for Business Accounts.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Questions? ',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to support or FAQ
              },
              child: const Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
