import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'become_provider_screen.dart';
import 'profile_edit_screen.dart';
import 'edit_provider_profile_screen.dart';
import 'wallet_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'document_management_screen.dart';
import '../utils/responsive_utils.dart';
import '../services/user_service.dart';
import '../services/healthcare_provider_service.dart';
import '../services/provider_service.dart';
import '../models/provider_profile.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImageUrl;
  bool _hasCustomImage = false;
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  void _loadProfileImage() {
    final user = UserService.currentUser;
    if (user?.profilePicturePath != null &&
        user!.profilePicturePath!.isNotEmpty) {
      setState(() {
        if (user.profilePicturePath!.startsWith('/')) {
          // Local file path
          _profileImageFile = File(user.profilePicturePath!);
          _hasCustomImage = true;
        } else {
          // Network URL
          _profileImageUrl = user.profilePicturePath;
          _hasCustomImage = true;
        }
      });
    }
  }

  Widget _buildUserTypeAndBio() {
    final user = UserService.currentUser;

    // Check if user is a healthcare provider
    final provider = HealthcareProviderService.getProviderByEmail(
      user?.email ?? '',
    );

    if (provider != null) {
      return Column(
        children: [
          Text(
            provider.specialization,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          if (provider.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              provider.bio,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                '${provider.rating}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${provider.reviewCount} reviews)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: provider.isAvailable
                      ? Colors.green[100]
                      : Colors.red[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  provider.isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: provider.isAvailable
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Text(
        'Patient',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            // Navigate back to home screen
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions:
            const [], // Explicitly remove any actions including search icon
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildProfileCard(context),

            const SizedBox(height: 12),
            // Show Provider Account card if user has approved provider profile
            if (_hasApprovedProviderAccount()) ...[
              _buildProviderAccountCard(context),
              const SizedBox(height: 12),
            ],
            // Only show "Become a Provider" if user doesn't have approved provider account
            if (!_hasApprovedProviderAccount()) ...[
              _buildBecomeProviderCard(context),
              const SizedBox(height: 12),
            ],
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return ResponsiveUtils.flexibleContainer(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Builder(
                  builder: (context) {
                    final profileImage = _getProfileImage();
                    return CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profileImage,
                      onBackgroundImageError: profileImage != null
                          ? (exception, stackTrace) {}
                          : null,
                      child: !_hasCustomImage
                          ? Text(
                              _getInitials(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showImagePickerDialog();
                      },
                      icon: const Icon(Icons.camera_alt, color: Colors.black),
                      iconSize: 16,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Change profile picture',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ResponsiveUtils.safeText(
              UserService.currentUser?.fullName ?? 'Isaac',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 3),
            _buildUserTypeAndBio(),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileEditScreen(),
                    ),
                  );
                  // Refresh profile data when returning from edit screen
                  if (result == true && mounted) {
                    setState(() {
                      _loadProfileImage();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Choose Profile Picture',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildImageSourceOptions(),
                    if (_hasCustomImage) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _removeImage,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Remove Picture',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOptions() {
    // On web, only show gallery option (camera is not supported)
    if (kIsWeb) {
      return _buildSourceOption(
        icon: Icons.photo_library,
        label: 'Choose from Files',
        onTap: () => _pickImage(ImageSource.gallery),
      );
    }

    // On mobile, show both camera and gallery
    return Row(
      children: [
        Expanded(
          child: _buildSourceOption(
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSourceOption(
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final navigator = Navigator.of(context);

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        navigator.pop(); // Close bottom sheet

        if (kIsWeb) {
          // On web, use the image path as a network URL (blob URL)
          setState(() {
            _profileImageUrl = image.path;
            _profileImageFile = null;
            _hasCustomImage = true;
          });

          await _saveProfileImage();
          _showSnackBar('Profile picture updated successfully');
        } else {
          // On mobile, save to app directory
          try {
            final File imageFile = File(image.path);
            final File savedImage = await _saveImageToAppDirectory(imageFile);

            if (mounted) {
              setState(() {
                _profileImageFile = savedImage;
                _profileImageUrl = null;
                _hasCustomImage = true;
              });

              await _saveProfileImage();
              _showSnackBar('Profile picture updated successfully');
            }
          } catch (e) {
            if (mounted) {
              _showSnackBar('Failed to save image: ${e.toString()}');
            }
          }
        }
      } else if (mounted) {
        navigator.pop(); // Close bottom sheet even if no image selected
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close bottom sheet
        _showSnackBar('Failed to pick image: ${e.toString()}');
      }
    }
  }

  Future<File> _saveImageToAppDirectory(File image) async {
    if (kIsWeb) {
      // On web, just return the file as-is (won't actually be used)
      return image;
    }

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = '${appDir.path}/$fileName';

    return await image.copy(filePath);
  }

  ImageProvider? _getProfileImage() {
    if (_profileImageFile != null) {
      return FileImage(_profileImageFile!);
    } else if (_profileImageUrl != null) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  void _removeImage() {
    final navigator = Navigator.of(context);
    navigator.pop(); // Close bottom sheet
    setState(() {
      _profileImageUrl = null;
      _profileImageFile = null;
      _hasCustomImage = false;
    });
    _saveProfileImage();
  }

  Future<void> _saveProfileImage() async {
    try {
      String? imagePath;

      if (_profileImageFile != null) {
        imagePath = _profileImageFile!.path;
      } else if (_profileImageUrl != null) {
        imagePath = _profileImageUrl;
      }

      // Update the user service with the new profile picture
      await UserService.updateProfilePicture(imagePath ?? '');

      if (mounted) {
        _showSnackBar(
          _hasCustomImage
              ? 'Profile picture updated successfully'
              : 'Profile picture removed',
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update profile picture');
      }
    }
  }

  String _getInitials() {
    final name = UserService.currentUser?.name;
    if (name == null || name.isEmpty) return 'I';

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return parts[0][0].toUpperCase();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 1),
        ),
      ),
    );
  }

  Widget _buildProviderDashboardMenuItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.dashboard, color: Colors.white, size: 24),
        ),
        title: const Text(
          'Business Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: const Text(
          'Manage patients, appointments and analytics',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/provider/dashboard');
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildBecomeProviderCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        leading: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.medical_services,
            color: Colors.blue[700],
            size: 16,
          ),
        ),
        title: const Text(
          'Business Account',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 10,
          color: Colors.grey[400],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BecomeProviderScreen(),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
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
          // Show Provider Dashboard card if user is an approved provider
          if (_isHealthcareProvider()) ...[
            _buildProviderDashboardMenuItem(context),
            _buildDivider(),
          ],
          _buildMenuItem(
            icon: Icons.account_balance_wallet,
            title: 'Wallet',
            subtitle: 'Manage your payments and transactions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Past Appointments',
            subtitle: 'View your appointment history',
            onTap: () {
              // Navigate to past appointments
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.medical_services,
            title: 'Medical Records',
            subtitle: 'Access your medical records',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocumentManagementScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.description,
            title: 'My Documents',
            subtitle: 'Manage uploaded documents and certificates',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocumentManagementScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          // Provider-only menu items
          if (_isHealthcareProvider()) ...[
            _buildMenuItem(
              icon: Icons.edit_note,
              title: 'Edit Business Profile',
              subtitle: 'Update your professional information',
              onTap: () => _editProviderProfile(),
            ),
            _buildDivider(),
          ],
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // Handle help
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Learn more about Klinate and our mission',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences and account settings',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              // Refresh the profile screen when returning from settings
              if (mounted) {
                setState(() {
                  _loadProfileImage();
                });
              }
            },
          ),
          // Admin Setup - Always show for testing, will hide after becoming admin
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.admin_panel_settings,
            title: 'Admin Setup',
            subtitle: 'Become an administrator',
            onTap: () async {
              await Navigator.pushNamed(context, '/admin/setup');
              // Refresh to hide the button after becoming admin
              if (mounted) {
                setState(() {});
              }
            },
          ),
          _buildDivider(),
          _buildAppInfoCard(),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.grey[700], size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: Colors.grey[400],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: Colors.grey[200], thickness: 1, height: 1),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.indigo[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with app icon and name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_services,
                  color: Colors.blue[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Klinate',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Healthcare at Your Fingertips',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // App Information
          _buildInfoRow(
            icon: Icons.info_outline,
            label: 'Version',
            value: '1.0.0',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Developer',
            value: 'Isaac Wangila',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.build_outlined,
            label: 'Build',
            value: 'Release 2025.1',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.flutter_dash,
            label: 'Platform',
            value: 'Flutter 3.24.0',
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.blue[200]!,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Copyright and Legal Information
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.copyright, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '© 2025 Klinate. All rights reserved.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'This application and its content are protected by copyright law. Unauthorized reproduction, distribution, or modification is strictly prohibited.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Licensed software. All trademarks are property of their respective owners.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.info, size: 16, color: Colors.blue[700]),
                  label: Text(
                    'More Info',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLicenseDialog();
                  },
                  icon: Icon(Icons.article, size: 16, color: Colors.grey[700]),
                  label: Text(
                    'Licenses',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  void _showLicenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Open Source Licenses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This application uses the following open source packages:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildLicenseItem('Flutter SDK', 'BSD-3-Clause License'),
              _buildLicenseItem('Material Design', 'Apache License 2.0'),
              _buildLicenseItem('Intl Package', 'BSD-3-Clause License'),
              _buildLicenseItem('Image Picker', 'Apache License 2.0'),
              _buildLicenseItem('Path Provider', 'BSD-3-Clause License'),
              _buildLicenseItem('URL Launcher', 'BSD-3-Clause License'),
              const SizedBox(height: 12),
              Text(
                'Full license texts are available in the application source code.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseItem(String package, String license) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  license,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isHealthcareProvider() {
    final user = UserService.currentUser;
    if (user == null) return false;

    // Admins automatically have access to business dashboard
    if (user.currentRole == UserRole.admin) return true;

    // Check if user has any approved provider profiles
    final providers = ProviderService.getProvidersByUserId(user.id);
    return providers.any((p) => p.status == ProviderStatus.approved);
  }

  bool _hasApprovedProviderAccount() {
    final user = UserService.currentUser;
    if (user == null) return false;

    final providers = ProviderService.getProvidersByUserId(user.id);
    return providers.any((p) => p.status == ProviderStatus.approved);
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

  ProviderProfile? _getApprovedProviderProfile() {
    final user = UserService.currentUser;
    if (user == null) return null;

    final providers = ProviderService.getProvidersByUserId(user.id);
    final approvedProviders = providers
        .where((p) => p.status == ProviderStatus.approved)
        .toList();

    return approvedProviders.isNotEmpty ? approvedProviders.first : null;
  }

  Widget _buildProviderAccountCard(BuildContext context) {
    final provider = _getApprovedProviderProfile();
    if (provider == null) return const SizedBox.shrink();

    final currentUser = UserService.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    // Get provider user info
    final users = UserService.getAllUsers();
    final providerUser = users.firstWhere(
      (u) => u.id == provider.userId,
      orElse: () => currentUser,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/provider/dashboard');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business Account',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getProviderTypeName(provider.providerType),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Approved',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              providerUser.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              provider.servicesDescription != null &&
                                      provider.servicesDescription!.length > 60
                                  ? '${provider.servicesDescription!.substring(0, 60)}...'
                                  : provider.servicesDescription ??
                                        'Providing quality healthcare services',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildProviderStat(
                        icon: Icons.people,
                        label: 'Patients',
                        value: '0',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProviderStat(
                        icon: Icons.calendar_today,
                        label: 'Appointments',
                        value: '0',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProviderStat(
                        icon: Icons.star,
                        label: 'Rating',
                        value: '5.0',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _editProviderProfile() async {
    final user = UserService.currentUser;
    // Allow admins and providers to edit provider profiles
    if (user == null ||
        (!user.isProvider && user.currentRole != UserRole.admin)) {
      _showSnackBar('Only business account holders can edit business profiles');
      return;
    }

    // Try to find individual provider profile first
    final provider = HealthcareProviderService.getProviderByEmail(user.email);
    if (provider != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProviderProfileScreen(provider: provider),
        ),
      );

      if (result != null) {
        _showSnackBar('Business profile updated successfully');
      }
      return;
    }

    // Provider profile editing handled above
    _showSnackBar('Unable to edit profile');
  }
}
