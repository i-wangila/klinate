import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'appointments_screen.dart';
import 'category_screen.dart';
import 'inbox_screen.dart';
import '../utils/responsive_utils.dart';
import '../services/user_service.dart';
import 'provider_profile_screen.dart';
import '../services/provider_service.dart';
import '../services/message_service.dart';
import '../services/review_service.dart';
import '../models/provider_profile.dart';
import '../models/user_profile.dart';
import 'wallet_screen.dart';
import 'document_management_screen.dart';
import 'terms_conditions_screen.dart';
import 'privacy_policy_screen.dart';
import 'contact_us_screen.dart';
import 'about_screen.dart';
import 'become_provider_screen.dart';
import 'settings_screen.dart';
import 'faqs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // Profile image state for drawer header
  String? _profileImageUrl;
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MessageService.addListener(_onMessageUpdate);
    _searchController.addListener(_onSearchChanged);
    _loadProfileImage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    MessageService.removeListener(_onMessageUpdate);
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _performSearch(query);
    });
  }

  List<Map<String, dynamic>> _performSearch(String query) {
    final results = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();

    // Search providers - only show approved providers
    final providers = ProviderService.getApprovedProviders();
    for (var provider in providers) {
      final providerName = ProviderService.getProviderDisplayName(provider.id);
      final specialization = provider.specialization ?? '';

      if (providerName.toLowerCase().contains(lowerQuery) ||
          specialization.toLowerCase().contains(lowerQuery)) {
        // Get dynamic rating from reviews
        final providerRating = ReviewService.getProviderRating(provider.id);
        results.add({
          'type': 'provider',
          'name': providerName,
          'subtitle': specialization,
          'rating': providerRating.averageRating.toStringAsFixed(2),
          'data': provider,
        });
      }
    }

    return results;
  }

  void _onMessageUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _showExitConfirmation();
        if (shouldExit == true && context.mounted) {
          // Only exit if user confirms
          if (kIsWeb) {
            // On web, just show a message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please use logout to exit the app'),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            // On mobile, exit the app
            exit(0);
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        endDrawer: _buildProfileMenuDrawer(),
        body: _getSelectedScreen(),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Future<bool?> _showExitConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text(
          'Do you want to exit the app? Please use the logout button to sign out.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: SafeArea(
        child: Column(
          children: [
            _buildBecomeProviderBanner(),
            _buildProfileHeader(),
            Expanded(
              child: SingleChildScrollView(child: _buildProfileMenuList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const AppointmentsScreen();
      case 2:
        return const InboxScreen();
      case 3:
        return _buildHomeContent();
      case 4:
        // Provider Dashboard - navigate to provider dashboard screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/provider-dashboard');
          // Reset to home after navigation
          setState(() {
            _selectedNavIndex = 0;
          });
        });
        return _buildHomeContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHomeHeader(),
          _buildSearchBar(),
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProvidersSection(),
                        SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            80,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 16),
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return Card(
          margin: EdgeInsets.only(
            bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Icon(Icons.person, color: Colors.grey[700]),
            ),
            title: Text(
              result['name'],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  result['subtitle'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(
                      result['rating'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to provider profile (no facilities anymore)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProviderProfileScreen(providerId: result['data'].id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search doctors and specialists...',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[600],
              size: ResponsiveUtils.isSmallScreen(context) ? 20 : 24,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
              vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 20),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Builder(
                builder: (context) {
                  final img = _getProfileImage();
                  return CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: img,
                    onBackgroundImageError: img != null ? (e, st) {} : null,
                    child: img == null
                        ? Text(
                            _getInitials(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )
                        : null,
                  );
                },
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePickerSheet,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserService.currentUser?.name ?? 'User',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      24,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  UserService.currentUser?.email ?? 'user@example.com',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
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

  Widget _buildBecomeProviderBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BecomeProviderScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
        ),
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.medical_services, color: Colors.blue[700], size: 24),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a Healthcare Business Account',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        16,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  Text(
                    'Join our network of professionals',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        12,
                      ),
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuList() {
    final user = UserService.currentUser;
    final isAdmin = user != null && user.hasRole(UserRole.admin);

    return Column(
      children: [
        _buildProfileMenuItem(
          icon: Icons.home,
          title: 'Home',
          onTap: () {
            Navigator.of(context).pop(); // Close the drawer
            setState(() {
              _selectedNavIndex = 0;
            });
          },
        ),
        if (isAdmin)
          _buildProfileMenuItem(
            icon: Icons.admin_panel_settings,
            title: 'Admin Dashboard',
            onTap: () {
              Navigator.pushNamed(context, '/admin/dashboard');
            },
            isHighlighted: true,
          ),
        _buildProfileMenuItem(
          icon: Icons.account_balance_wallet,
          title: 'Wallet',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalletScreen()),
            );
          },
        ),
        _buildProfileMenuItem(
          icon: Icons.medical_information,
          title: 'Medical Records',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DocumentManagementScreen(),
              ),
            );
          },
        ),
        _buildProfileMenuItem(
          icon: Icons.article,
          title: 'Terms & Conditions',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsConditionsScreen(),
              ),
            );
          },
        ),
        _buildProfileMenuItem(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
            );
          },
        ),
        _buildProfileMenuItem(
          icon: Icons.help,
          title: 'FAQ',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FAQsScreen()),
            );
          },
        ),
        _buildProfileMenuItem(
          icon: Icons.contact_support,
          title: 'Contact Us',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsScreen()),
            );
          },
        ),
        _buildProfileMenuItem(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
            // Refresh the screen when returning from settings
            if (mounted) {
              setState(() {});
            }
          },
        ),
        _buildProfileMenuItem(
          icon: Icons.info,
          title: 'About',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          },
        ),
        _buildProfileMenuItem(
          icon: Icons.logout,
          title: 'Logout',
          onTap: () {
            _showLogoutDialog();
          },
          isLogout: true,
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 80)),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.blue[50] : Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout
                  ? Colors.red
                  : isHighlighted
                  ? Colors.blue[700]
                  : Colors.black,
              size: ResponsiveUtils.isSmallScreen(context) ? 20 : 24,
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  color: isLogout
                      ? Colors.red
                      : isHighlighted
                      ? Colors.blue[900]
                      : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: ResponsiveUtils.isSmallScreen(context) ? 18 : 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear the user session
              await UserService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // === Profile image helpers ===
  void _loadProfileImage() {
    final user = UserService.currentUser;
    if (user?.profilePicturePath != null &&
        user!.profilePicturePath!.isNotEmpty) {
      setState(() {
        if (user.profilePicturePath!.startsWith('/')) {
          _profileImageFile = File(user.profilePicturePath!);
          _profileImageUrl = null;
        } else {
          _profileImageUrl = user.profilePicturePath;
          _profileImageFile = null;
        }
      });
    }
  }

  ImageProvider? _getProfileImage() {
    if (_profileImageFile != null) return FileImage(_profileImageFile!);
    if (_profileImageUrl != null) return NetworkImage(_profileImageUrl!);
    return null;
  }

  String _getInitials() {
    final name = UserService.currentUser?.name ?? 'User';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
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
          ),
        ),
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Colors.black),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
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
      if (image == null) {
        navigator.pop();
        return;
      }

      if (kIsWeb) {
        setState(() {
          _profileImageUrl = image.path; // blob URL
          _profileImageFile = null;
        });
      } else {
        final File saved = await _saveImageToAppDirectory(File(image.path));
        setState(() {
          _profileImageFile = saved;
          _profileImageUrl = null;
        });
      }

      await _saveProfileImage();
      if (mounted) navigator.pop();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<File> _saveImageToAppDirectory(File image) async {
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return image.copy(path);
  }

  Future<void> _saveProfileImage() async {
    String? imagePath;
    if (_profileImageFile != null) {
      imagePath = _profileImageFile!.path;
    } else if (_profileImageUrl != null) {
      imagePath = _profileImageUrl;
    }
    await UserService.updateProfilePicture(imagePath ?? '');
    setState(() {});
  }

  Widget _buildHomeHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Klinate',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 32),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                  size: ResponsiveUtils.isSmallScreen(context) ? 22 : 24,
                ),
                onPressed: () {
                  setState(() {
                    _selectedNavIndex = 2; // Navigate to Inbox
                  });
                },
              ),
              if (MessageService.getUnreadCount() > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${MessageService.getUnreadCount()}',
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToProviderProfileNew(ProviderProfile provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderProfileScreen(providerId: provider.id),
      ),
    );
  }

  void _navigateToCategory(String title, List<Map<String, dynamic>> items) {
    // Convert dynamic to String for CategoryScreen
    final stringItems = items
        .map(
          (item) => {
            'id': item['id']?.toString() ?? '',
            'title': item['title']?.toString() ?? '',
            'rating': item['rating']?.toString() ?? '',
            'imageUrl': item['imageUrl']?.toString() ?? '',
            'location': item['location']?.toString() ?? '',
          },
        )
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CategoryScreen(title: title, items: stringItems, category: title),
      ),
    );
  }

  Widget _buildProvidersSection() {
    // Hide providers section if current user is a provider (but not for admins)
    final currentUser = UserService.currentUser;
    if (currentUser?.isProvider == true &&
        currentUser?.currentRole != UserRole.admin) {
      return const SizedBox.shrink();
    }

    // Use new ProviderService - only show approved providers
    final allProviders = ProviderService.getApprovedProviders();

    // Filter providers by specialization
    final generalPractitioners = allProviders
        .where((p) => p.specialization?.toLowerCase() == 'general practitioner')
        .toList();

    final specialists = allProviders
        .where(
          (p) =>
              p.specialization?.toLowerCase() != 'general practitioner' &&
              p.specialization != null &&
              p.specialization!.isNotEmpty,
        )
        .toList();

    // If no providers at all, show empty state
    if (generalPractitioners.isEmpty && specialists.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsiveSpacing(context, 32),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              Text(
                'No healthcare providers yet',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              Text(
                'Healthcare providers will appear here once approved',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // General Practitioners Section - Only show if there are any
        if (generalPractitioners.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
              vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ResponsiveUtils.safeText(
                    'General Practitioners',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        18,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigateToCategory(
                    'General Practitioners',
                    generalPractitioners.map((p) {
                      final rating = ReviewService.getProviderRating(p.id);
                      return {
                        'id': p.id,
                        'title':
                            '${ProviderService.getProviderDisplayName(p.id)} - ${p.specialization}',
                        'rating': rating.averageRating.toStringAsFixed(1),
                        'location': '',
                      };
                    }).toList(),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 8),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: ResponsiveUtils.isSmallScreen(context) ? 18 : 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              itemCount: generalPractitioners.length > 8
                  ? 8
                  : generalPractitioners.length,
              itemBuilder: (context, index) {
                final provider = generalPractitioners[index];
                return _buildProviderCard(provider);
              },
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
        ],
        // Specialists Section - Only show if there are any
        if (specialists.isNotEmpty) _buildSpecialistsSection(specialists),
      ],
    );
  }

  Widget _buildSpecialistsSection(List<ProviderProfile> allProviders) {
    // Only render if there are specialists
    if (allProviders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
            vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ResponsiveUtils.safeText(
                  'Specialists',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      18,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToCategory(
                  'Specialists',
                  allProviders.map((p) {
                    final rating = ReviewService.getProviderRating(p.id);
                    return {
                      'id': p.id,
                      'title':
                          '${ProviderService.getProviderDisplayName(p.id)} - ${p.specialization}',
                      'rating': rating.averageRating.toStringAsFixed(1),
                      'location': '',
                    };
                  }).toList(),
                ),
                child: Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveSpacing(context, 8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: ResponsiveUtils.isSmallScreen(context) ? 18 : 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
            ),
            itemCount: allProviders.length > 8 ? 8 : allProviders.length,
            itemBuilder: (context, index) {
              final provider = allProviders[index];
              return _buildProviderCard(provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(provider) {
    final providerName = ProviderService.getProviderDisplayName(provider.id);
    return GestureDetector(
      onTap: () => _navigateToProviderProfileNew(provider),
      child: Container(
        width: 160,
        margin: EdgeInsets.only(
          right: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: _buildProviderImage(provider),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 6)),
            ResponsiveUtils.safeText(
              providerName,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 1,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 1)),
            ResponsiveUtils.safeText(
              provider.specialization,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
              maxLines: 1,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 2)),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: ResponsiveUtils.isSmallScreen(context) ? 12 : 14,
                  color: Colors.black,
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 2),
                ),
                Flexible(
                  child: Text(
                    ReviewService.getProviderRating(
                      provider.id,
                    ).averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        15,
                      ),
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderImage(provider) {
    // First check if provider has profile images from registration
    if (provider.profileImages != null && provider.profileImages.isNotEmpty) {
      final firstImage = provider.profileImages.first;
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: kIsWeb
            ? Image.network(
                firstImage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultProviderAvatar(provider);
                },
              )
            : Image.file(
                File(firstImage),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultProviderAvatar(provider);
                },
              ),
      );
    }

    // Fallback to user profile picture
    final users = UserService.getAllUsers();
    final user = users.firstWhere(
      (u) => u.id == provider.userId,
      orElse: () => UserProfile(
        id: provider.userId,
        name: 'Provider',
        email: '',
        phone: '',
      ),
    );

    final profileImagePath = user.profilePicturePath;

    if (profileImagePath != null &&
        profileImagePath.isNotEmpty &&
        profileImagePath != 'https://via.placeholder.com/200' &&
        profileImagePath.startsWith('/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(profileImagePath),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultProviderAvatar(provider);
          },
        ),
      );
    } else if (profileImagePath != null &&
        profileImagePath.isNotEmpty &&
        profileImagePath != 'https://via.placeholder.com/200') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          profileImagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultProviderAvatar(provider);
          },
        ),
      );
    } else {
      return _buildDefaultProviderAvatar(provider);
    }
  }

  Widget _buildDefaultProviderAvatar(provider) {
    final providerName = ProviderService.getProviderDisplayName(provider.id);
    return Center(
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.blue[100],
        child: Text(
          providerName.split(' ').map((e) => e[0]).take(2).join(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    // Check if user has approved provider account or is an admin
    final currentUser = UserService.currentUser;
    final hasApprovedProvider =
        currentUser != null &&
        (ProviderService.getProviderByUserId(currentUser.id)?.status ==
                ProviderStatus.approved ||
            currentUser.hasRole(UserRole.admin));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.calendar_today, 'Appointments', 1),
              _buildNavItem(Icons.inbox, 'Inbox', 2),
              if (hasApprovedProvider)
                _buildNavItem(Icons.dashboard, 'Business', 4),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          // Profile - open drawer
          _scaffoldKey.currentState?.openEndDrawer();
        } else if (index == 4) {
          // Provider Dashboard - navigate to provider dashboard
          Navigator.pushNamed(context, '/provider-dashboard');
        } else {
          setState(() {
            _selectedNavIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.red : Colors.grey[600],
            size: ResponsiveUtils.isSmallScreen(context) ? 22 : 26,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.red : Colors.grey[600],
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
