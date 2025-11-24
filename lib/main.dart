import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_setup_screen.dart';
import 'screens/pending_providers_screen.dart';
import 'screens/approved_providers_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/activity_log_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/admin_management_screen.dart';
import 'screens/admin_reviews_screen.dart';
import 'screens/provider_dashboard_screen.dart';
import 'services/user_service.dart';
import 'services/message_service.dart';
import 'services/wallet_service.dart';
import 'services/admin_service.dart';
import 'services/audit_service.dart';
import 'services/provider_service.dart';
import 'services/appointment_service.dart';
import 'services/review_service.dart';
import 'middleware/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await UserService.initialize();
  await MessageService.loadMessages();
  await WalletService.initialize();
  await AdminService.initialize();
  await AuditService.initialize();
  await ProviderService.initialize();
  await ReviewService.initialize();
  await AppointmentService.loadAppointments();
  runApp(const KlinateApp());
}

class KlinateApp extends StatelessWidget {
  const KlinateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klinate',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        // Check authentication for admin routes
        if (settings.name?.startsWith('/admin/') == true &&
            settings.name != '/admin/setup') {
          if (!AuthGuard.isAdmin()) {
            return MaterialPageRoute(
              builder: (context) => const _AdminGuardScreen(),
            );
          }
        }

        // Route mapping
        switch (settings.name) {
          case '/admin/dashboard':
            return MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            );
          case '/admin/setup':
            return MaterialPageRoute(
              builder: (context) => const AdminSetupScreen(),
            );
          case '/admin/pending-providers':
            return MaterialPageRoute(
              builder: (context) => const PendingProvidersScreen(),
            );
          case '/admin/approved-providers':
            return MaterialPageRoute(
              builder: (context) => const ApprovedProvidersScreen(),
            );
          case '/admin/user-management':
            return MaterialPageRoute(
              builder: (context) => const UserManagementScreen(),
            );
          case '/admin/activity-log':
            return MaterialPageRoute(
              builder: (context) => const ActivityLogScreen(),
            );
          case '/admin/reports':
            return MaterialPageRoute(
              builder: (context) => const ReportsScreen(),
            );
          case '/admin/admin-management':
            return MaterialPageRoute(
              builder: (context) => const AdminManagementScreen(),
            );
          case '/admin/reviews':
            return MaterialPageRoute(
              builder: (context) => const AdminReviewsScreen(),
            );
          case '/provider-dashboard':
            return MaterialPageRoute(
              builder: (context) => const ProviderDashboardScreen(),
            );
          default:
            return null;
        }
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E86AB)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        primaryColor: const Color(0xFF2E86AB),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          titleMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          bodySmall: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
          labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF2E86AB),
          selectionColor: Colors.transparent,
          selectionHandleColor: Color(0xFF2E86AB),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}

class _AdminGuardScreen extends StatefulWidget {
  const _AdminGuardScreen();

  @override
  State<_AdminGuardScreen> createState() => _AdminGuardScreenState();
}

class _AdminGuardScreenState extends State<_AdminGuardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AuthGuard.requireAdmin(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
