import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/user_service.dart';
import '../services/provider_service.dart';
import '../services/review_service.dart';
import '../models/provider_profile.dart';
import '../models/review.dart';
import '../models/user_profile.dart';
import '../widgets/role_switcher.dart';
import 'home_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  String _selectedItem = 'Patients';
  ProviderProfile? _providerProfile;
  bool _isLoading = true;
  Map<String, dynamic>? _selectedPatient;
  String _selectedPatientTab = 'Pt Info';
  final List<Map<String, dynamic>> _followUpPatients = [];
  final List<Map<String, dynamic>> _regularPatients = [];
  final List<String> _deletedPatientEmails = [];
  String _patientSearchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSidebarCollapsed = false;
  int _selectedDayRange = 7;

  // Patient records storage - Map of patient email to their records
  final Map<String, Map<String, List<Map<String, String>>>> _patientRecords =
      {};
  final TextEditingController _recordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProviderProfile();
    _loadPatientData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _recordController.dispose();
    super.dispose();
  }

  Future<void> _loadProviderProfile() async {
    setState(() => _isLoading = true);

    final user = UserService.currentUser;
    if (user != null) {
      final providers = ProviderService.getProvidersByUserId(user.id);
      if (providers.isNotEmpty) {
        _providerProfile = providers.firstWhere(
          (p) => p.providerType == user.currentRole,
          orElse: () => providers.first,
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadPatientData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = UserService.currentUser;
      if (user == null) return;

      // Load follow-up patients
      final followUpJson = prefs.getString('followup_patients_${user.id}');
      if (followUpJson != null) {
        final List<dynamic> followUpList = json.decode(followUpJson);
        _followUpPatients.clear();
        _followUpPatients.addAll(
          followUpList.map((e) {
            final patient = Map<String, dynamic>.from(e);
            // Convert int color value back to Color object
            if (patient['color'] is int) {
              patient['color'] = Color(patient['color'] as int);
            }
            return patient;
          }).toList(),
        );
      }

      // Load deleted patients
      final deletedJson = prefs.getString('deleted_patients_${user.id}');
      if (deletedJson != null) {
        final List<dynamic> deletedList = json.decode(deletedJson);
        _deletedPatientEmails.clear();
        _deletedPatientEmails.addAll(deletedList.cast<String>());
      }

      // Load patient records
      final recordsJson = prefs.getString('patient_records_${user.id}');
      if (recordsJson != null) {
        final Map<String, dynamic> recordsMap = json.decode(recordsJson);
        _patientRecords.clear();
        recordsMap.forEach((patientEmail, tabs) {
          _patientRecords[patientEmail] = {};
          (tabs as Map<String, dynamic>).forEach((tabName, records) {
            _patientRecords[patientEmail]![tabName] = (records as List)
                .map((r) => Map<String, String>.from(r))
                .toList();
          });
        });
      }

      setState(() {});
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _savePatientData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = UserService.currentUser;
      if (user == null) return;

      // Convert Color objects to int values for serialization
      final followUpForSave = _followUpPatients.map((patient) {
        final patientCopy = Map<String, dynamic>.from(patient);
        if (patientCopy['color'] is Color) {
          patientCopy['color'] = (patientCopy['color'] as Color).toARGB32();
        }
        return patientCopy;
      }).toList();

      // Save follow-up patients
      final followUpJson = json.encode(followUpForSave);
      await prefs.setString('followup_patients_${user.id}', followUpJson);

      // Save deleted patients
      final deletedJson = json.encode(_deletedPatientEmails);
      await prefs.setString('deleted_patients_${user.id}', deletedJson);

      // Save patient records
      final recordsJson = json.encode(_patientRecords);
      await prefs.setString('patient_records_${user.id}', recordsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = UserService.currentUser;
    final isAdmin = currentUser?.currentRole == UserRole.admin;

    // Admins can access Business Dashboard without provider profile
    // Check if provider profile exists and is approved (skip for admins)
    if (!isAdmin &&
        (_providerProfile == null ||
            _providerProfile!.status != ProviderStatus.approved)) {
      return _buildNotApprovedView();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: isAdmin
          ? AppBar(
              title: const Text(
                'Business Dashboard',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
              actions: [
                RoleSwitcher(
                  onRoleChanged: (role) {
                    if (role == UserRole.patient) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else if (role == UserRole.admin) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin-dashboard',
                      );
                    }
                  },
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar space
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isSidebarCollapsed ? 0 : 70,
              ),
              // Main Content Area
              Expanded(child: _buildMainContent()),
            ],
          ),
          // Collapsible Sidebar
          _buildCollapsibleSidebar(),
          // Toggle Button
          _buildToggleButton(),
        ],
      ),
    );
  }

  Widget _buildNotApprovedView() {
    final status = _providerProfile?.status;

    String title;
    String message;
    IconData icon;
    Color iconColor;

    switch (status) {
      case ProviderStatus.pending:
        title = 'Application Under Review';
        message =
            'Your business account application is being reviewed by our team. You will be notified once approved.';
        icon = Icons.hourglass_empty;
        iconColor = Colors.orange;
        break;
      case ProviderStatus.rejected:
        title = 'Application Not Approved';
        message =
            'Unfortunately, your business account application was not approved. Please contact support for more information.';
        icon = Icons.cancel_outlined;
        iconColor = Colors.red;
        break;
      case ProviderStatus.suspended:
        title = 'Account Suspended';
        message =
            'Your business account has been suspended. Please contact support for assistance.';
        icon = Icons.block;
        iconColor = Colors.red;
        break;
      default:
        title = 'No Business Account';
        message =
            'You need to apply for a business account to access the Business Dashboard.';
        icon = Icons.business_center_outlined;
        iconColor = Colors.grey;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Business Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: iconColor),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              if (status == ProviderStatus.pending) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Approval typically takes 1-3 business days',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: _isSidebarCollapsed ? -70 : 0,
      top: 0,
      bottom: 0,
      width: 70,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo/Header Area
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Icon(
                Icons.business_center,
                size: 28,
                color: Colors.black,
              ),
            ),
            const Divider(height: 1),
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  // Main Menu Items with Icons
                  _buildMenuItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isSelected: _selectedItem == 'Home',
                    onTap: () async {
                      // Exit Business Dashboard and return to patient home
                      await UserService.switchRole(UserRole.patient);
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.people_outline,
                    label: 'Patients',
                    isSelected: _selectedItem == 'Patients',
                    onTap: () => setState(() => _selectedItem = 'Patients'),
                  ),
                  _buildMenuItem(
                    icon: Icons.follow_the_signs_outlined,
                    label: 'Follow Up',
                    isSelected: _selectedItem == 'Follow Up',
                    onTap: () => setState(() => _selectedItem = 'Follow Up'),
                  ),
                  _buildMenuItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Analytics',
                    isSelected: _selectedItem == 'Analytics',
                    onTap: () => setState(() => _selectedItem = 'Analytics'),
                  ),
                  _buildMenuItem(
                    icon: Icons.star_outline,
                    label: 'Reviews',
                    isSelected: _selectedItem == 'Reviews',
                    onTap: () => setState(() => _selectedItem = 'Reviews'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: _isSidebarCollapsed ? 0 : 70,
      top: 20,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isSidebarCollapsed = !_isSidebarCollapsed;
          });
        },
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Icon(
            _isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: isSelected ? Colors.grey[100] : Colors.transparent,
          child: Center(
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedItem == 'Patients') {
      if (_selectedPatient != null) {
        return _buildPatientDetailView();
      }
      return _buildPatientsView();
    }

    if (_selectedItem == 'Analytics') {
      return _buildAnalyticsView();
    }

    if (_selectedItem == 'Reviews') {
      return _buildReviewsView();
    }

    if (_selectedItem == 'Follow Up') {
      return _buildFollowUpView();
    }

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            _selectedItem,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your $_selectedItem',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          // Content Area
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.construction_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
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

  Widget _buildPatientsView() {
    // Start with empty patient list - providers will add their own patients
    // No sample data - clean slate for real patient management

    // Filter patients based on search query and exclude deleted/follow-up patients
    final patients = _regularPatients.where((patient) {
      final email = patient['email'] as String;

      // Exclude deleted patients
      if (_deletedPatientEmails.contains(email)) return false;

      // Exclude patients in follow-up
      if (_followUpPatients.any((p) => p['email'] == email)) return false;

      if (_patientSearchQuery.isEmpty) return true;

      final name = (patient['name'] as String).toLowerCase();
      final emailLower = email.toLowerCase();
      final query = _patientSearchQuery.toLowerCase();

      return name.contains(query) || emailLower.contains(query);
    }).toList();

    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patients',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your patient records',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _patientSearchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        suffixIcon: _patientSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _patientSearchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Patient List with Scrollbar
              Expanded(
                child: patients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No patients found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _patientSearchQuery.isEmpty
                                  ? 'No patients in your list'
                                  : 'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Scrollbar(
                        thumbVisibility: true,
                        thickness: 6,
                        radius: const Radius.circular(3),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: patients.length,
                          itemBuilder: (context, index) {
                            final patient = patients[index];
                            return _buildPatientCard(
                              name: patient['name'] as String,
                              email: patient['email'] as String,
                              date: patient['date'] as String,
                              initial: patient['initial'] as String,
                              color: patient['color'] as Color,
                              isSelected: false,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
        // Floating Action Button - Add Patient
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: _showAddPatientDialog,
            backgroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.person_add, color: Colors.black, size: 28),
          ),
        ),
      ],
    );
  }

  void _showAddPatientDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Add New Patient',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Patient Name',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();

              if (name.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Check if patient already exists
              if (_regularPatients.any((p) => p['email'] == email) ||
                  _followUpPatients.any((p) => p['email'] == email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Patient already exists'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Generate random color for avatar
              final colors = [
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.teal,
                Colors.pink,
              ];
              final color = colors[_regularPatients.length % colors.length];

              // Get initials
              final nameParts = name.split(' ');
              final initial = nameParts.length > 1
                  ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
                  : name[0].toUpperCase();

              // Add patient
              setState(() {
                _regularPatients.add({
                  'name': name,
                  'email': email,
                  'date': DateTime.now().toString().split(' ')[0],
                  'initial': initial,
                  'color': color,
                });
              });

              // Save to persistent storage
              _savePatientData();

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add Patient'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard({
    required String name,
    required String email,
    required String date,
    required String initial,
    required Color color,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.red : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 24,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          email,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(date, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
              onSelected: (value) => _handlePatientAction(
                value,
                name,
                email,
                date,
                initial,
                color,
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'follow_up',
                  child: Row(
                    children: [
                      Icon(
                        Icons.follow_the_signs,
                        color: Colors.blue,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text('Move to Follow Up'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Delete Patient'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedPatient = {
              'name': name,
              'email': email,
              'date': date,
              'initial': initial,
              'color': color,
            };
            _selectedPatientTab = 'Pt Info';
          });
        },
      ),
    );
  }

  void _handlePatientAction(
    String action,
    String name,
    String email,
    String date,
    String initial,
    Color color,
  ) {
    if (action == 'follow_up') {
      setState(() {
        // Remove from regular patients
        _regularPatients.removeWhere((patient) => patient['email'] == email);

        // Add to follow-up patients if not already there
        if (!_followUpPatients.any((p) => p['email'] == email)) {
          _followUpPatients.add({
            'name': name,
            'email': email,
            'date': date,
            'initial': initial,
            'color': color,
          });
        }
      });

      // Save to persistent storage
      _savePatientData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name moved to Follow Up permanently'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (action == 'delete') {
      _showDeleteConfirmation(name, email);
    }
  }

  void _showDeleteConfirmation(String patientName, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text(
          'Are you sure you want to permanently delete $patientName from your patient list? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                // Remove from regular patients list
                _regularPatients.removeWhere(
                  (patient) => patient['email'] == email,
                );

                // Remove from follow-up list if present
                _followUpPatients.removeWhere(
                  (patient) => patient['email'] == email,
                );

                // Add to deleted list to prevent re-appearance
                if (!_deletedPatientEmails.contains(email)) {
                  _deletedPatientEmails.add(email);
                }
              });

              // Save to persistent storage
              _savePatientData();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$patientName permanently deleted'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetailView() {
    final patient = _selectedPatient!;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Back Button and Patient Info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                // Back Button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedPatient = null;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back to patients',
                ),
                const SizedBox(width: 16),
                // Patient Avatar
                CircleAvatar(
                  backgroundColor: patient['color'] as Color,
                  radius: 28,
                  child: Text(
                    patient['initial'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Patient Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient['name'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient['email'] as String,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab Buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 4,
              radius: const Radius.circular(2),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildTabButton('Pt Info'),
                    const SizedBox(width: 8),
                    _buildTabButton('History'),
                    const SizedBox(width: 8),
                    _buildTabButton('Orders'),
                    const SizedBox(width: 8),
                    _buildTabButton('Diagnosis'),
                    const SizedBox(width: 8),
                    _buildTabButton('Treatment Plan'),
                    const SizedBox(width: 8),
                    _buildTabButton('Prescriptions'),
                  ],
                ),
              ),
            ),
          ),
          // Tab Content
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isSelected = _selectedPatientTab == label;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPatientTab = label;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: isSelected ? Colors.black : Colors.grey[600],
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedPatient == null) return const SizedBox.shrink();

    final patientEmail = _selectedPatient!['email'] as String;
    final records = _getPatientRecords(patientEmail, _selectedPatientTab);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getTabIcon(), size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No ${_selectedPatientTab.toLowerCase()} records yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click the button below to add a record',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _buildRecordCard(record, index, patientEmail);
                  },
                ),
        ),
        // Floating Add Button - Pure White
        Positioned(
          right: 24,
          bottom: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAddRecordDialog(patientEmail),
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  child: const Icon(Icons.add, color: Colors.black, size: 28),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getPatientRecords(
    String patientEmail,
    String tab,
  ) {
    if (!_patientRecords.containsKey(patientEmail)) {
      _patientRecords[patientEmail] = {};
    }
    if (!_patientRecords[patientEmail]!.containsKey(tab)) {
      _patientRecords[patientEmail]![tab] = [];
    }
    return _patientRecords[patientEmail]![tab]!;
  }

  void _showAddRecordDialog(String patientEmail) {
    _recordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $_selectedPatientTab'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: _recordController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Enter ${_selectedPatientTab.toLowerCase()} details...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_recordController.text.trim().isNotEmpty) {
                setState(() {
                  final records = _getPatientRecords(
                    patientEmail,
                    _selectedPatientTab,
                  );
                  records.add({
                    'content': _recordController.text.trim(),
                    'date': DateTime.now().toString(),
                  });
                });

                // Save to persistent storage
                _savePatientData();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$_selectedPatientTab added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(
    Map<String, String> record,
    int index,
    String patientEmail,
  ) {
    final date = DateTime.parse(record['date']!);
    final formattedDate =
        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_getTabIcon(), size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    _selectedPatientTab,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () =>
                        _showEditRecordDialog(patientEmail, index, record),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red,
                    onPressed: () => _deleteRecord(patientEmail, index),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            record['content']!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formattedDate,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showEditRecordDialog(
    String patientEmail,
    int index,
    Map<String, String> record,
  ) {
    _recordController.text = record['content']!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $_selectedPatientTab'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: _recordController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Enter ${_selectedPatientTab.toLowerCase()} details...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_recordController.text.trim().isNotEmpty) {
                setState(() {
                  final records = _getPatientRecords(
                    patientEmail,
                    _selectedPatientTab,
                  );
                  records[index] = {
                    'content': _recordController.text.trim(),
                    'date': record['date']!, // Keep original date
                  };
                });

                // Save to persistent storage
                _savePatientData();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$_selectedPatientTab updated successfully'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(String patientEmail, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete this ${_selectedPatientTab.toLowerCase()} record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final records = _getPatientRecords(
                  patientEmail,
                  _selectedPatientTab,
                );
                records.removeAt(index);
              });

              // Save to persistent storage
              _savePatientData();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$_selectedPatientTab deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getTabIcon() {
    switch (_selectedPatientTab) {
      case 'History':
        return Icons.history;
      case 'Orders':
        return Icons.shopping_bag_outlined;
      case 'Diagnosis':
        return Icons.medical_information_outlined;
      case 'Treatment Plan':
        return Icons.assignment_outlined;
      case 'Prescriptions':
        return Icons.medication_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildAnalyticsView() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "Today's Analytics",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Booked Appointments Progress
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booked Appointments',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const Text(
                        '70%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.7,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Dashboard Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                PopupMenuButton<int>(
                  onSelected: (value) {
                    setState(() {
                      _selectedDayRange = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 7, child: Text('7 Days')),
                    const PopupMenuItem(value: 14, child: Text('14 Days')),
                    const PopupMenuItem(value: 30, child: Text('30 Days')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$_selectedDayRange Days',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stats Cards - Vertical Layout
            Column(
              children: [
                _buildStatCard(
                  icon: Icons.calendar_today,
                  label: 'Total Appointments',
                  value: '0',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.event_available,
                  label: 'Upcoming Appointments',
                  value: '0',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Completed Appointments',
                  value: '0',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.follow_the_signs,
                  label: 'Follow-Up Appointments',
                  value: '0',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Appointments Analytics Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Appointments Analytics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '$_selectedDayRange Days',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Bar Chart with Labels - Horizontally Scrollable
                  SizedBox(
                    height: 250,
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(3),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: IntrinsicWidth(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: _generateChartBars(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Legend - Vertical Layout Below Chart
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Upcoming', Colors.pink),
                      const SizedBox(height: 12),
                      _buildLegendItem('Follow-Up', Colors.orange),
                      const SizedBox(height: 12),
                      _buildLegendItem('Completed', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  List<Widget> _generateChartBars() {
    final now = DateTime.now();
    final bars = <Widget>[];

    // Start with zero data - will be populated from real appointment data
    for (int i = _selectedDayRange - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayLabel = _getDayLabel(date, i);

      // No sample data - all zeros until real appointments are added
      final upcoming = 0;
      final followUp = 0;
      final completed = 0;

      bars.add(
        _buildBarGroupWithLabel(dayLabel, upcoming, followUp, completed),
      );
    }

    return bars;
  }

  String _getDayLabel(DateTime date, int daysAgo) {
    if (_selectedDayRange <= 7) {
      // Show day names for 7 days or less
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return days[date.weekday % 7];
    } else if (_selectedDayRange <= 14) {
      // Show short date for 14 days
      return '${date.month}/${date.day}';
    } else {
      // Show date for 30 days
      return '${date.day}';
    }
  }

  Widget _buildBarGroupWithLabel(
    String day,
    int upcoming,
    int followUp,
    int completed,
  ) {
    final total = upcoming + followUp + completed;
    final hasData = total > 0;

    return Container(
      width: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Total count above bar
          if (hasData)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '$total',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            )
          else
            const SizedBox(height: 14),
          // Stacked bars
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (upcoming > 0)
                  Container(
                    width: 32,
                    height: upcoming * 3.0,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                if (followUp > 0)
                  Container(
                    width: 32,
                    height: followUp * 3.0,
                    color: Colors.orange,
                  ),
                if (completed > 0)
                  Container(
                    width: 32,
                    height: completed * 3.0,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.vertical(
                        top: upcoming == 0 && followUp == 0
                            ? const Radius.circular(4)
                            : Radius.zero,
                      ),
                    ),
                  ),
                // Empty state
                if (!hasData)
                  Container(
                    width: 32,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Day label
          Text(
            day,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsView() {
    // Get reviews for current provider
    final providerId = _providerProfile?.id ?? '';
    final reviews = ReviewService.getReviewsByProvider(providerId);
    final rating = ReviewService.getProviderRating(providerId);

    return Container(
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reviews & Ratings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Patient feedback and ratings',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                // Rating Summary
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Average Rating
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                rating.averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < rating.averageRating.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 24,
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${rating.totalReviews} reviews',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Rating Distribution
                        Container(
                          constraints: const BoxConstraints(minWidth: 300),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final star = 5 - index;
                              final count =
                                  rating.ratingDistribution[star] ?? 0;
                              final percentage = rating.totalReviews > 0
                                  ? (count / rating.totalReviews)
                                  : 0.0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      '$star',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 200,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: percentage,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Colors.amber),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 30,
                                      child: Text(
                                        '$count',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Reviews List
          Expanded(
            child: reviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reviews yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Patient reviews will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(32),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return _buildReviewCard(review);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 20,
                child: Text(
                  review.patientName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }

  Widget _buildFollowUpView() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Follow Up Patients',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Patients requiring follow-up appointments',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Follow Up Patient List
          Expanded(
            child: _followUpPatients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.follow_the_signs_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No follow-up patients',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Patients moved to follow-up will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : Scrollbar(
                    thumbVisibility: true,
                    thickness: 6,
                    radius: const Radius.circular(3),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _followUpPatients.length,
                      itemBuilder: (context, index) {
                        final patient = _followUpPatients[index];
                        return _buildFollowUpPatientCard(
                          name: patient['name'] as String,
                          email: patient['email'] as String,
                          date: patient['date'] as String,
                          initial: patient['initial'] as String,
                          color: patient['color'] as Color,
                          index: index,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpPatientCard({
    required String name,
    required String email,
    required String date,
    required String initial,
    required Color color,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!, width: 2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 24,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.follow_the_signs,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          email,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: const Text(
                'Follow Up',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
              onSelected: (value) => _handleFollowUpAction(value, index, name),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(
                        Icons.remove_circle_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text('Remove from Follow Up'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Delete Patient'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedPatient = {
              'name': name,
              'email': email,
              'date': date,
              'initial': initial,
              'color': color,
            };
            _selectedPatientTab = 'Pt Info';
            _selectedItem = 'Patients';
          });
        },
      ),
    );
  }

  void _handleFollowUpAction(String action, int index, String patientName) {
    if (action == 'remove') {
      setState(() {
        // Get patient data before removing
        final patient = _followUpPatients[index];

        // Remove from follow-up
        _followUpPatients.removeAt(index);

        // Add back to regular patients if not deleted
        final email = patient['email'] as String;
        if (!_deletedPatientEmails.contains(email)) {
          _regularPatients.add(patient);
        }
      });

      // Save to persistent storage
      _savePatientData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$patientName removed from Follow Up'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (action == 'delete') {
      final patient = _followUpPatients[index];
      _showDeleteConfirmation(patientName, patient['email'] as String);
    }
  }
}
