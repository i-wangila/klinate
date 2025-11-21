# Klinate - Professional Healthcare Platform

A comprehensive Flutter-based healthcare platform that connects patients with healthcare professionals and facilities across Kenya. Built with LinkedIn-style professional profiles, comprehensive business account management, and integrated telemedicine services.

## 🏥 Overview

Klinate is a modern, production-ready healthcare platform designed to make medical services accessible through digital channels. The platform features professional LinkedIn-style profiles for healthcare providers, comprehensive business account management, and seamless patient-provider connections with full communication capabilities including voice calls, video calls, and real-time messaging.

## ✨ Features

### 🔐 Enhanced Authentication & Security
- **Separate Name Fields**: First name and last name registration
- **Strong Password Requirements**: 6+ characters with uppercase, numbers, and special characters
- **Real-time Validation**: Live password strength indicator
- **Secure Login System**: Persistent authentication with proper session management
- **Interactive Onboarding**: Comprehensive app introduction
- **Two-Factor Authentication (2FA)**: SMS, Email, or Authenticator App options
- **Biometric Login**: Fingerprint and Face ID support for quick access
- **Active Session Management**: View and manage all logged-in devices
- **Login History**: Track all login attempts with device and location info
- **Privacy Controls**: Manage profile visibility and contact information
- **Password Management**: Secure password change with validation
- **Account Deactivation**: Temporary deactivation with 3-month grace period
- **Account Deletion**: Permanent deletion with 30-day cancellation window

### 👩‍⚕️ Comprehensive Healthcare Provider Network
- **Individual Doctors**: Specialists across various medical fields with detailed profiles
- **Healthcare Facilities**: Hospitals, clinics with complete facility information
- **Pharmacies**: Prescription fulfillment and medication services
- **Laboratories**: Diagnostic testing and health screening services
- **Business Account Registration**: Complete onboarding system with working hours selection
- **Profile Management**: Full profile editing with professional image upload
- **Working Hours**: Day-by-day schedule with customizable start and end times
- **Insurance & Payments**: Display accepted insurance providers and payment methods
- **Certifications**: Showcase professional certifications and accreditations
- **Contact Information**: Email and phone visible to patients for easy communication
- **Patient Management**: Complete patient record system with medical history tracking

### 📞 Advanced Communication System
- **Voice Calls**: High-quality voice calling with healthcare providers
- **Video Calls**: Face-to-face consultations with video calling interface
- **Real-time Chat**: Instant messaging with persistent chat history and proper alignment
- **Unified Inbox**: Single inbox for all messages, notifications, and conversations
- **Quick Actions**: Call, video, or message directly from provider cards
- **Call Management**: Mute, speaker, and call duration tracking
- **Message Notifications**: Real-time message alerts and unread indicators
- **Smart Message Display**: Sent messages appear on right, received on left
- **Conversation Threading**: Messages organized by sender with timestamps
- **System Notifications**: Appointment confirmations, reminders, and updates

### 📅 Complete Appointment Management
- **Smart Booking**: Calendar-based appointment scheduling with availability checking
- **Multiple Consultation Types**:
  - Video consultations
  - Voice calls
  - In-person visits
  - Chat consultations
- **Appointment Lifecycle**: Book, reschedule, cancel, and complete appointments
- **Provider Availability**: Real-time slot checking and time management
- **Appointment History**: Complete tracking of past and upcoming appointments
- **Real-Time Analytics**: Automatic updates when appointments are booked or completed
- **Interactive Dashboard**: Click stat cards to view detailed appointment lists
- **Status Tracking**: Visual indicators for upcoming, completed, and cancelled appointments

### 🖼️ Professional Profile System
- **Image Upload**: Professional photo/logo upload during registration
- **Profile Editing**: Complete profile management for providers and facilities
- **Image Management**: Change, remove, or update profile images
- **Smart Display**: Automatic image handling with fallback systems
- **Professional Guidelines**: Specific guidance for individual vs facility images

### ⭐ Comprehensive Review & Rating System
- **Multi-Provider Reviews**: Rate doctors, hospitals, pharmacies, and laboratories
- **Detailed Feedback**: Written reviews with star ratings
- **Review Management**: View, edit, and manage all reviews
- **Business Account Ratings**: Aggregate ratings displayed on business profiles
- **Review Analytics**: Comprehensive review statistics and insights

### 💳 Integrated Payment & Wallet System
- **Digital Wallet**: Complete wallet management system
- **Consultation Fees**: Transparent pricing display
- **Payment Integration**: Ready for mobile money integration (M-Pesa, Airtel Money)
- **Transaction History**: Complete payment tracking and history

### 🛡️ Complete Admin System
- **Admin Dashboard**: Comprehensive system overview with real-time statistics
- **Business Account Approval**: Review and approve/reject business account applications
- **User Management**: View, suspend, and manage all users
- **Admin Management**: Add and manage multiple administrators
- **Activity Log**: Complete audit trail of all admin actions
- **Reports & Analytics**: System statistics and performance metrics
- **Route Guards**: Secure admin routes with authentication checks
- **Document Review**: Review and approve provider verification documents

### 📱 Enhanced User Experience
- **Quick Actions**: Call, video, message buttons on all provider cards
- **Smart Navigation**: Intuitive bottom navigation with smooth transitions
- **Business Dashboard Access**: Quick access icon appears in nav bar when business account is approved
- **Search & Filter**: Advanced provider and facility search capabilities
- **Responsive Design**: Optimized for all screen sizes and devices
- **Professional UI**: Clean, medical-grade interface design with compact elements
- **Account Management**: Unified interface for General, Business, and Admin accounts
- **Streamlined Business Dashboard**: Focused tabs - Patient, Inbox, Appointments, Analytics
- **Optimized Sizing**: Reduced spacing and font sizes for cleaner, more professional appearance
- **Patient Management**: Comprehensive patient records with medical history, appointments, and prescriptions
- **Security Dashboard**: Centralized security settings with comprehensive controls
- **Data Privacy**: Download personal data and control information sharing
- **Notification Preferences**: Granular control over push, email, and SMS notifications

### 🏥 Healthcare Facility Management
- **Facility Profiles**: Complete facility information with services and departments
- **Facility Registration**: Comprehensive onboarding for healthcare facilities
- **Logo Management**: Professional logo upload and management
- **Service Listings**: Detailed services, departments, and specialties
- **Contact Integration**: Direct calling and messaging from facility profiles

### 👨‍⚕️ Provider Patient Management
- **Patient Records**: Comprehensive patient information with medical history
- **Medical History Tracking**: 
  - Chronic conditions and diagnoses
  - Treatment status and medications
  - Appointment history
  - Current prescriptions
- **Direct Communication**: Message patients directly from patient list or detail view
- **Record Management**: 
  - Delete individual patient records
  - Bulk delete all patients
  - Undo functionality for accidental deletions
- **Search & Filter**: Quick patient search functionality
- **Detailed Patient View**: Click any patient to view complete medical history

### 📊 Real-Time Analytics Dashboard
- **Interactive Statistics Cards**:
  - Total Appointments: View all appointments in selected period
  - Upcoming Appointments: See scheduled future consultations
  - Completed Appointments: Review past consultations
  - Follow-Up Appointments: Track ongoing patient care
- **Automatic Updates**: Analytics refresh instantly when appointments change
- **Detailed Appointment Views**: Click any card to see:
  - Patient names and contact information
  - Appointment dates and times
  - Status badges (Upcoming, Completed, Cancelled, Past)
  - Communication types (Video, Voice, In-Person, Chat)
  - Consultation descriptions
  - Payment amounts
- **Visual Analytics**:
  - Stacked bar charts showing appointment distribution
  - Color-coded categories for quick scanning
  - Period selection (7 days, 30 days, 90 days)
  - Booking percentage with progress indicators
- **Smart Sorting**:
  - Upcoming: Sorted by soonest first
  - Completed: Sorted by most recent first
  - Total: Sorted by date (newest first)
- **Clean, Modern Design**: Professional typography and minimal UI

### 🔒 Comprehensive Security Features
- **Two-Factor Authentication (2FA)**:
  - SMS verification with phone number
  - Email verification codes
  - Authenticator app support (Google Authenticator, Authy, Microsoft Authenticator)
  - QR code setup for easy authenticator configuration
  - Backup codes for account recovery
  - Toggle 2FA on/off from Security settings
- **Biometric Authentication**:
  - Fingerprint recognition for Android and iOS
  - Face ID support for iOS devices
  - Touch ID support for compatible devices
  - Quick and secure access without passwords
  - Fallback to password if biometric fails
  - Enable/disable from Security settings
- **Active Session Management**:
  - View all devices currently logged into your account
  - See device type, browser, and operating system
  - View last active time for each session
  - Location information for each login
  - Log out from individual devices remotely
  - "Log out from all other devices" option for security
  - Automatic session expiry after inactivity
- **Login History & Monitoring**:
  - Track all successful login attempts
  - Monitor failed login attempts
  - View device and browser information
  - See IP address and location for each login
  - Timestamp for every login event
  - Security alerts for suspicious activity
  - Export login history for audit purposes
- **Privacy Settings & Controls**:
  - Control who can view your profile
  - Manage email address visibility
  - Control phone number display
  - Set who can message you (Everyone, Contacts Only, No One)
  - Profile visibility options (Public, Private, Contacts Only)
  - Granular privacy controls for each data field
  - Privacy dashboard for quick overview
- **Password Management**:
  - Secure password change with current password verification
  - Strong password requirements (6+ characters, uppercase, numbers, special chars)
  - Real-time password strength indicator
  - Password confirmation to prevent typos
  - Password history to prevent reuse
  - Secure password reset via email
- **Account Management**:
  - **Account Deactivation**: 
    - Temporary deactivation with immediate access loss
    - 3-month grace period before permanent deletion
    - Reactivate by logging in during grace period
    - All data preserved during deactivation
    - Password confirmation required
  - **Account Deletion**: 
    - Permanent deletion request with 30-day grace period
    - Cancel deletion by logging in within 30 days
    - All data permanently deleted after grace period
    - Type "DELETE" confirmation required
    - Password verification for security
    - Clear warnings about data loss
- **Data Control & Privacy**:
  - Download complete personal data export
  - Data sent to registered email address
  - JSON format for easy data portability
  - Notification preferences management (Push, Email, SMS)
  - Data retention policies clearly stated
  - GDPR-compliant data handling
  - Right to be forgotten implementation
  - Data access request processing

### 📞 Customer Support & Contact
- **Updated Contact Information**: 
  - Phone: +254740109195
  - Email: support@klinate.com
- **Contact Forms**: Direct message sending to support team
- **Business Hours**: Clear availability and response time information
- **Help & Support**: Comprehensive FAQ and support system

## 🛠 Technical Stack

### Framework & Language
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language

### Key Dependencies
- `intl ^0.19.0`: Internationalization and date formatting
- `table_calendar ^3.0.9`: Advanced calendar widget for appointment scheduling
- `url_launcher ^6.2.4`: External URL and phone number handling
- `shared_preferences ^2.2.2`: Local data persistence and user preferences
- `image_picker ^1.0.4`: Professional profile image selection and upload
- `path_provider ^2.1.1`: File system path management for image storage
- `cupertino_icons ^1.0.8`: iOS-style icons for cross-platform consistency
- `fl_chart ^0.68.0`: Beautiful, animated charts for analytics visualization

### Architecture
- **MVC Pattern**: Clean separation of concerns with proper state management
- **Service Layer**: Comprehensive business logic abstraction
- **Model Classes**: Robust data structure definitions with JSON serialization
- **Screen Components**: Modular UI layer organization
- **Stream Controllers**: Real-time data flow for chat, calls, and analytics
- **Persistent Storage**: Local data management with SharedPreferences
- **Error Handling**: Comprehensive error management and user feedback
- **Real-Time Updates**: Broadcast streams for instant data synchronization
- **State Management**: StatefulWidget with proper lifecycle management
- **Responsive Design**: Adaptive layouts for all screen sizes

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point with theme configuration
├── models/                             # Data models with JSON serialization
│   ├── admin_action.dart               # Admin activity logging
│   ├── admin_profile.dart              # Admin user profiles
│   ├── appointment.dart                # Appointment booking and management
│   ├── conversation.dart               # Chat conversation threading
│   ├── document.dart                   # Document upload and verification
│   ├── message.dart                    # Messaging system
│   ├── provider_profile.dart           # Healthcare professional profiles
│   ├── review.dart                     # Review and rating system
│   ├── system_stats.dart               # System-wide statistics
│   └── user_profile.dart               # User profile management
├── screens/                            # UI screens and user interfaces
│   ├── admin_dashboard_screen.dart     # Admin system overview
│   ├── admin_management_screen.dart    # Manage administrators
│   ├── admin_setup_screen.dart         # Initial admin setup
│   ├── activity_log_screen.dart        # Admin activity audit trail
│   ├── appointments_screen.dart        # Patient appointment management
│   ├── approved_providers_screen.dart  # View approved business accounts
│   ├── auth_screen.dart                # Authentication with validation
│   ├── become_provider_screen.dart     # Business account application flow
│   ├── book_appointment_screen.dart    # Appointment booking with calendar
│   ├── chat_screen.dart                # Real-time messaging interface
│   ├── edit_provider_basic_info_screen.dart    # Edit provider basic info
│   ├── edit_provider_business_info_screen.dart # Edit business details
│   ├── edit_provider_professional_info_screen.dart # Edit professional info
│   ├── facility_profile_screen.dart    # Healthcare facility profiles
│   ├── home_screen.dart                # Main dashboard with quick actions
│   ├── inbox_screen.dart               # Unified message inbox
│   ├── manage_admin_account_screen.dart # Admin account settings
│   ├── manage_my_accounts_screen.dart  # Multi-account management
│   ├── manage_provider_account_screen.dart # Provider account settings
│   ├── notification_chat_screen.dart   # Notification center
│   ├── patient_detail_screen.dart      # Detailed patient records
│   ├── pending_providers_screen.dart   # Business account approval queue
│   ├── profile_screen.dart             # User profile management
│   ├── provider_analytics_screen.dart  # Real-time analytics dashboard
│   ├── provider_appointments_screen.dart # Provider appointment management
│   ├── provider_dashboard_screen.dart  # Provider main dashboard
│   ├── provider_inbox_screen.dart      # Business account message inbox
│   ├── provider_patients_screen.dart   # Business account patient list
│   ├── provider_profile_screen.dart    # Healthcare professional profiles
│   ├── provider_registration_screen.dart # Business account registration system
│   ├── provider_reviews_screen.dart    # Business account review management
│   ├── rate_any_provider_screen.dart   # Rate any provider
│   ├── rate_provider_screen.dart       # Review and rating interface
│   ├── reports_screen.dart             # Admin reports and analytics
│   ├── reschedule_appointment_screen.dart # Appointment rescheduling
│   ├── settings_screen.dart            # App settings
│   ├── user_management_screen.dart     # Admin user management
│   └── ... (additional screens)
├── services/                           # Business logic and data management
│   ├── admin_service.dart              # Admin operations and statistics
│   ├── appointment_service.dart        # Appointment booking with real-time updates
│   ├── approval_service.dart           # Business account approval workflow
│   ├── audit_service.dart              # Activity logging and audit trails
│   ├── chat_service.dart               # Real-time messaging service
│   ├── document_service.dart           # Document upload and management
│   ├── message_service.dart            # Message persistence and notifications
│   ├── provider_service.dart           # Provider data and search
│   └── user_service.dart               # User authentication and profiles
├── middleware/                         # Route guards and middleware
│   └── auth_guard.dart                 # Authentication and authorization
└── widgets/                            # Reusable UI components
    └── role_switcher.dart              # Multi-account role switching
```

## 🎯 Key Highlights

### Production-Ready Features
- ✅ **Real-Time Data Synchronization**: Stream-based architecture for instant updates
- ✅ **Comprehensive Admin System**: Complete business account approval and user management
- ✅ **Interactive Analytics**: Click-to-view detailed appointment breakdowns
- ✅ **Unified Messaging**: Single inbox for all communications
- ✅ **Multi-Account Support**: Seamlessly switch between Patient, Provider, and Admin roles
- ✅ **Document Management**: Upload, verify, and manage provider credentials
- ✅ **Audit Trails**: Complete activity logging for compliance and security
- ✅ **Professional UI/UX**: Clean, modern design with excellent readability
- ✅ **Persistent Storage**: All data saved locally with SharedPreferences
- ✅ **Error Handling**: Comprehensive error management with user-friendly messages

### Security & Privacy Excellence
- 🔐 **Two-Factor Authentication**: SMS, Email, and Authenticator App support
- 👆 **Biometric Login**: Fingerprint and Face ID authentication
- 📱 **Session Management**: View and control all logged-in devices
- 📊 **Login History**: Track all login attempts with device and location info
- 🔒 **Privacy Controls**: Granular control over profile visibility and data sharing
- 🔑 **Password Security**: Strong password requirements with real-time validation
- ⏸️ **Account Deactivation**: Temporary deactivation with 3-month grace period
- 🗑️ **Account Deletion**: Permanent deletion with 30-day cancellation window
- 📥 **Data Export**: Download complete personal data in JSON format
- 🔔 **Notification Control**: Manage push, email, and SMS preferences
- 🛡️ **GDPR Compliant**: Full compliance with data protection regulations
- 🔐 **Secure by Design**: Security-first architecture throughout the app

### Technical Excellence
- 🔒 **Secure Authentication**: Strong password requirements with validation
- 📊 **Advanced Analytics**: Beautiful charts with fl_chart library
- 🔄 **State Management**: Proper lifecycle management and memory handling
- 📱 **Responsive Design**: Works seamlessly on all screen sizes
- 🎨 **Consistent Theming**: Professional color scheme throughout
- ⚡ **Performance Optimized**: Efficient data loading and rendering
- 🧪 **Well Tested**: Comprehensive testing across all features
- 📝 **Clean Code**: Well-organized, maintainable codebase
- 🔐 **Security Hardened**: Multiple layers of security protection
- 📋 **Audit Ready**: Complete logging and compliance features

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS (requires macOS):**
```bash
flutter build ios --release
```

## 🔧 Configuration

### Environment Setup
The app includes comprehensive local services for demonstration and testing. For production deployment:

1. **Backend Integration**: Configure REST API endpoints for data synchronization
2. **Authentication Services**: Integrate with Firebase Auth or custom authentication
3. **Payment Gateways**: Set up M-Pesa, Airtel Money, and card payment processing
4. **Push Notifications**: Configure Firebase Cloud Messaging for real-time alerts
5. **Video Calling Infrastructure**: Integrate with Agora, Twilio, or WebRTC services
6. **File Storage**: Configure cloud storage for profile images and documents
7. **Database**: Set up PostgreSQL, MongoDB, or Firebase Firestore for data persistence

### Customization Options
- **Theme Configuration**: Update app colors and styling in `lib/main.dart`
- **Provider Data**: Modify healthcare provider information in service classes
- **UI Components**: Customize screen layouts and component designs
- **Business Logic**: Adapt appointment booking and communication workflows
- **Localization**: Add support for multiple languages and regions
- **Branding**: Update app icons, splash screens, and brand elements

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (responsive design)
- ✅ Windows, macOS, Linux (desktop support)

## 🧪 Testing & Quality Assurance

### Automated Testing
Run the comprehensive test suite:
```bash
flutter test
```

### Manual Testing Scenarios
The app has been thoroughly tested for:

1. **User Registration & Authentication**
   - First/last name separation
   - Strong password validation
   - Login/logout functionality

2. **Communication Features**
   - Voice calling interface and controls
   - Video calling with camera/microphone management
   - Real-time chat messaging
   - Quick action buttons from provider cards

3. **Appointment Management**
   - Calendar-based booking system
   - Provider availability checking
   - Appointment rescheduling and cancellation
   - Multiple consultation type selection

4. **Profile Management**
   - Image upload during registration
   - Profile editing for providers and facilities
   - Image management (change, remove, update)
   - Professional information updates

5. **Business Account & Facility Features**
   - Business account registration and onboarding
   - Facility profile management
   - Service and department listings
   - Contact information integration

### Code Quality
- **Flutter Analyze**: Zero lint issues and warnings
- **Compilation**: All code compiles successfully across platforms
- **Error Handling**: Comprehensive error management with user feedback
- **Memory Management**: Proper resource disposal and lifecycle management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent file organization

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support & Contact

For support, inquiries, and technical assistance:
- **Email**: support@klinate.com
- **Phone**: +254740109195 (Available during business hours)
- **Business Hours**: Monday to Friday, 8:00 AM - 5:00 PM (EAT)
- **Response Time**: We reply within 24 hours
- **Website**: www.klinate.com
- **Address**: Posta House, Off Kenyatta Avenue, P.O. Box 38256 - 00100, Nairobi, Kenya

### In-App Support
- Contact form available in the app
- Real-time chat support during business hours
- Comprehensive FAQ section
- Help documentation and user guides

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Healthcare providers for their valuable input
- Beta testers for their feedback and suggestions
- Open source community for the excellent packages

## 🔄 Version History

### v1.6.0 (Current) - Enhanced Analytics & Medical Records
- **Dynamic Analytics Dashboard**:
  - Interactive day range selector (7, 14, 30 days)
  - Chart automatically updates based on selected period
  - Full 7-day chart with day labels (Mon, Tue, Wed, etc.)
  - Horizontal scrolling for larger day ranges
  - Total appointment count displayed above each bar
  - Stacked bar visualization with color-coded categories
  - Sample data generation for demonstration
  - Responsive chart width calculation (50px per day)

- **Collapsible Sidebar**:
  - Sidebar can be collapsed to maximize workspace
  - Smooth 300ms animations for collapse/expand
  - Toggle button with chevron icons
  - Sidebar slides off-screen to the left when collapsed
  - Tooltips on icons for better UX
  - Icon-only navigation when collapsed
  - Compact 70px width for efficient space usage

- **Enhanced Medical Records System**:
  - Separated medical records from business verification documents
  - Added 12 new medical record types:
    - CT Scan Reports, MRI Reports, Ultrasound Reports
    - ECG/EKG Reports, Blood Test Reports, Urine Test Reports
    - Biopsy Reports, Pathology Reports
    - Nutrition Plans, Physiotherapy Reports
    - Dental Reports, Eye Examination Reports
  - Improved categorization (Lab Tests, Imaging, Reports, Plans)
  - Color-coded icons for each document type
  - Medical records only show healthcare-related documents
  - Business verification documents excluded from patient view

- **Review System Integration**:
  - Patient reviews instantly visible in provider's Business Dashboard
  - Real-time review synchronization
  - Reviews tab shows all patient feedback
  - Rating distribution and average rating display
  - Review cards with patient names and timestamps

- **Messaging System Verification**:
  - Confirmed full messaging functionality
  - Persistent message storage with SharedPreferences
  - Unified inbox for all message types
  - Real-time chat with proper message threading
  - System notifications for appointments and medical records
  - Message read/unread tracking
  - Delete and mark as read/unread functionality

- **Bug Fixes & Improvements**:
  - Fixed deprecated withOpacity warnings (replaced with withValues)
  - Fixed provider profile navigation from category screens
  - Added provider ID to category navigation
  - Ensured ProviderService initialization before profile loading
  - Updated document upload screen for new medical record types
  - Comprehensive switch statement coverage for all document types

### v1.5.0 - Business Dashboard & Unified Messaging
- **Complete Business Dashboard Redesign**:
  - Clean sidebar navigation with Home, Patients, Follow Up, Analytics, and Reviews
  - Home button exits Business Dashboard and returns to patient view
  - Compact 200px sidebar for more content space
  - Professional business-focused interface

- **Advanced Patient Management**:
  - Comprehensive patient list with search functionality
  - Real-time search by name or email
  - Patient detail view with tabs: History, Orders, Diagnosis, Treatment Plan, Prescriptions
  - Three-dot menu for patient actions (Move to Follow Up, Delete)
  - Scrollable tab buttons with visible scrollbar
  - Patient cards with colored avatars and contact information

- **Follow-Up System**:
  - Dedicated Follow Up section for patients requiring follow-up care
  - Move patients between regular and follow-up lists
  - Orange-themed follow-up patient cards with badges
  - Remove from follow-up or delete options
  - Separate management for ongoing patient care

- **Enhanced Analytics Dashboard**:
  - Today's Analytics with booking percentage progress bar
  - Dashboard stats: Total, Upcoming, Completed, Follow-Up Appointments
  - Visual bar charts showing appointment distribution
  - Color-coded categories (Pink: Upcoming, Orange: Follow-Up, Green: Completed)
  - 7-day period selection with dropdown
  - Interactive stat cards with icons

- **Reviews & Ratings Integration**:
  - Business Dashboard reviews section
  - Average rating display with star visualization
  - Rating distribution with progress bars (5★ to 1★)
  - Individual review cards with patient names and comments
  - Automatic updates when patients submit reviews
  - Professional review management interface

- **Unified Inbox System**:
  - Single inbox for all messages (patients and providers)
  - Removed separate Business Dashboard inbox
  - Appointment notifications with "View Appointment" button
  - System notifications for appointment bookings
  - Messages accessible from main home screen
  - Simplified messaging architecture

- **Account Persistence**:
  - Fixed account storage and retrieval
  - Accounts persist after logout and refresh
  - Proper data loading from SharedPreferences
  - Reliable sign-in functionality

- **Admin System Improvements**:
  - "Become Admin" only appears when no admin exists
  - Proper admin status checking on settings screen load
  - Admin approval required for Business Dashboard access
  - Status-based access control (Pending, Approved, Rejected, Suspended)

- **UI/UX Enhancements**:
  - Reduced sidebar width from 250px to 200px
  - Smaller icons and compact spacing
  - Scrollable patient tabs with horizontal scrollbar
  - Search bar with clear button
  - Empty states for no patients/reviews
  - Professional color scheme throughout

### v1.4.0 - Comprehensive Security & Privacy Update
- **Two-Factor Authentication (2FA) System**:
  - SMS-based verification with phone number
  - Email verification code system
  - Authenticator app integration (Google Authenticator, Authy, Microsoft Authenticator)
  - QR code generation for easy authenticator setup
  - Backup codes for account recovery
  - Toggle 2FA on/off from Security settings
  - Step-by-step setup wizard for each method
  
- **Biometric Authentication**:
  - Fingerprint recognition for Android and iOS
  - Face ID support for iOS devices
  - Touch ID support for compatible devices
  - Quick login without password entry
  - Secure fallback to password authentication
  - Enable/disable toggle in Security settings
  - Biometric data stored securely on device
  
- **Active Session Management**:
  - Real-time view of all logged-in devices
  - Device type, browser, and OS information
  - Last active timestamp for each session
  - Location data for each login
  - Remote logout from individual devices
  - "Log out from all other devices" bulk action
  - Automatic session expiry after inactivity
  - Session security monitoring
  
- **Login History & Security Monitoring**:
  - Comprehensive login attempt tracking
  - Successful and failed login records
  - Device and browser fingerprinting
  - IP address and location logging
  - Timestamp for every login event
  - Security alerts for suspicious activity
  - Exportable login history for auditing
  - Real-time security notifications
  
- **Privacy Settings & Controls**:
  - Profile visibility controls (Public, Private, Contacts Only)
  - Email address visibility management
  - Phone number display controls
  - Message permissions (Everyone, Contacts Only, No One)
  - Granular privacy controls for each data field
  - Privacy dashboard with quick toggles
  - Privacy impact indicators
  - Easy-to-understand privacy explanations
  
- **Enhanced Password Management**:
  - Secure password change workflow
  - Current password verification required
  - Strong password requirements enforced
  - Real-time password strength indicator
  - Password confirmation to prevent errors
  - Password history to prevent reuse
  - Secure password reset via email
  - Password security tips and guidance
  
- **Account Deactivation System**:
  - Temporary account deactivation option
  - Immediate access loss upon deactivation
  - 3-month grace period before permanent deletion
  - Reactivation by logging in during grace period
  - All data preserved during deactivation
  - Password confirmation required for security
  - Clear warnings about access loss
  - Information cards explaining the process
  
- **Account Deletion System**:
  - Permanent account deletion request
  - 30-day grace period before final deletion
  - Cancel deletion by logging in within 30 days
  - All data permanently deleted after grace period
  - Type "DELETE" confirmation required
  - Password verification for security
  - Multiple confirmation steps
  - Clear warnings about permanent data loss
  - Distinction between deactivation and deletion
  
- **Data Privacy & Control**:
  - Complete personal data export feature
  - Data sent to registered email in JSON format
  - Notification preferences (Push, Email, SMS)
  - Granular notification controls
  - Data retention policies clearly stated
  - GDPR-compliant data handling
  - Right to be forgotten implementation
  - Data portability support
  
- **Security Dashboard**:
  - Centralized security settings interface
  - Quick access to all security features
  - Security status overview
  - Recent security activity
  - Security recommendations
  - One-tap access to critical settings
  
- **UI/UX Security Improvements**:
  - Color-coded alerts for critical actions (red for deletion, orange for deactivation)
  - Information cards explaining consequences
  - Multi-step confirmation dialogs
  - Visual warnings before destructive actions
  - Clear distinction between temporary and permanent actions
  - Progress indicators for security operations
  - Success/error feedback for all actions
  
- **Documentation & Compliance**:
  - Updated FAQs with 10+ security questions
  - Enhanced Terms & Conditions with security policies
  - Updated Privacy Policy with new features
  - Comprehensive README security documentation
  - In-app help text for all security features
  - Security best practices guide
  - Compliance with data protection regulations

### v1.3.1 - Provider/Patient Separation
- **Provider Exclusion from Patient Statistics**:
  - Provider accounts are now excluded from patient lists and statistics
  - Analytics only count actual patients, not other providers
  - Patient lists show only non-provider users
  - Prevents mix-up between provider and patient data
  - Ensures accurate patient counts and analytics

### v1.3.0 - Real-Time Analytics & Enhanced UI
- **Real-Time Analytics Dashboard**:
  - **Interactive Stat Cards**: Click any card to view detailed appointment lists
  - **Automatic Updates**: Analytics refresh instantly when appointments are booked/completed
  - **Stream-Based Architecture**: Real-time data synchronization across the app
  - **Smart Filtering**: View appointments by Total, Upcoming, Completed, or Follow-Up
  - **Detailed Views**: Each appointment shows patient name, date/time, status, and amount
  - **Period Selection**: 7-day, 30-day, or 90-day analytics views
  - **Visual Charts**: Stacked bar charts with color-coded appointment statuses
  - **Booking Metrics**: Real-time booking percentage with progress indicators
  - **Clean Design**: Modern, minimal UI with professional typography
  - **Smart Sorting**: Upcoming appointments sorted by soonest, completed by most recent

- **Enhanced Messaging System**:
  - **Unified Inbox**: Single inbox for all messages (system, appointments, conversations)
  - **Real-Time Notifications**: Instant message alerts with unread counts
  - **Conversation Threading**: Organized message threads by sender
  - **System Notifications**: Appointment confirmations and updates
  - **Provider Inbox**: Separate inbox for provider communications
  - **Message Persistence**: All messages saved and synced across sessions

- **Complete Admin System**:
  - **Admin Dashboard**: Real-time system statistics and overview
  - **Business Account Approval Workflow**: Review and approve/reject business account applications
  - **Document Verification**: Review uploaded business account documents
  - **User Management**: View, suspend, and manage all users
  - **Admin Management**: Add and manage multiple administrators
  - **Activity Logging**: Complete audit trail of all admin actions
  - **Reports & Analytics**: System-wide statistics and performance metrics
  - **Secure Routes**: Authentication guards for admin-only areas

- **Provider Account Management**:
  - **Profile Editing**: Update basic info, professional details, and business information
  - **Working Hours**: Customize schedule for each day of the week
  - **Insurance & Payments**: Manage accepted insurance and payment methods
  - **Certifications**: Display professional credentials and accreditations
  - **Image Management**: Upload and update professional photos/logos
  - **Contact Information**: Email and phone visible to patients

### v1.2.0 - Complete Provider Patient Management
- **Patient Management System**: 
  - Comprehensive patient detail screens with medical history
  - View patient medical conditions, diagnoses, and treatment status
  - Recent appointment history with status tracking
  - Current prescriptions and medication management
  - Direct messaging from patient records
  - Unique patient identifiers (APID) for accurate record management
- **Patient Record Management**:
  - Delete individual patient records with confirmation
  - Bulk delete all patients with enhanced warnings
  - Undo functionality for accidental deletions
  - Search and filter patients
- **Provider-Patient Communication**:
  - Message patients directly from patient list
  - Messages appear in provider inbox
  - Real-time chat with proper message threading
  - Message history persistence

### v1.1.0 - Enhanced Business Account Experience
- **Business Dashboard Navigation**: Quick access icon in bottom nav bar for approved business accounts
- **Working Hours Management**: Business accounts can set specific hours for each working day during registration
- **Enhanced Business Profiles**: 
  - Insurance accepted section with visual badges
  - Certifications & accreditations display
  - Payment methods accepted
  - Contact information (email, phone) visible to patients
  - Left-aligned About and Services sections with icons
  - Removed redundant call buttons (using bottom action bar)
- **Improved Chat System**: Messages now correctly align (sent messages on right, received on left)
- **Streamlined Business Dashboard**: Removed unused "List" tab, focusing on Patient, Inbox, Appointments, and Analytics
- **Compact UI Elements**: Reduced button sizes and font sizes throughout the app for cleaner appearance
- **Profile Header Optimization**: Smaller avatar and text sizes in profile screen

### v1.0.0 - Production Ready Release
- **Complete Healthcare Ecosystem**: Full patient-provider interaction system
- **Advanced Communication**: Voice calls, video calls, and real-time messaging
- **Enhanced Authentication**: Separate name fields with strong password validation
- **Professional Profiles**: Image upload and comprehensive profile management
- **Smart Appointment System**: Calendar-based booking with availability checking
- **Multi-Provider Support**: Doctors, hospitals, pharmacies, laboratories, and facilities
- **Comprehensive Review System**: Rate and review all types of healthcare providers
- **Quick Actions**: Call, video, and message buttons throughout the app
- **Business Account Registration**: Complete onboarding system for healthcare professionals
- **Facility Management**: Full facility profile and service management
- **Real-time Features**: Live chat, call management, and instant notifications
- **Full Admin System**: Complete admin dashboard with business account approval workflow
- **Security Features**: Route guards, authentication checks, and audit trails
- **Account Management**: Unified interface for managing multiple account types
- **Document Persistence**: Uploaded documents persist across navigation
- **Optimized UI/UX**: Pure white text on all dark backgrounds for maximum readability
- **Clean Codebase**: Removed obsolete files and IDE-specific configurations

## 🎨 UI/UX Improvements

### Accessibility & Readability
- All text on dark backgrounds (black buttons, step indicators) uses pure white color
- Consistent color scheme throughout the application
- High contrast ratios for better accessibility
- Professional and clean interface design

### Recent Updates (v1.3.0)
- ✅ Real-time analytics with interactive stat cards
- ✅ Stream-based data synchronization for instant updates
- ✅ Clean, modern UI with professional typography
- ✅ Removed "KES" prefix from amounts for cleaner display
- ✅ Consolidated all documentation into single README
- ✅ Removed obsolete documentation files
- ✅ Updated project structure to reflect current state
- ✅ Enhanced appointment detail views with status badges
- ✅ Improved visual hierarchy and spacing throughout

## 📈 Future Roadmap

### Planned Features
- 🔜 **Backend Integration**: REST API for data synchronization
- 🔜 **Push Notifications**: Firebase Cloud Messaging integration
- 🔜 **Payment Gateway**: M-Pesa and Airtel Money integration
- 🔜 **Video Calling**: Agora/Twilio integration for real video calls
- 🔜 **Cloud Storage**: Firebase Storage for images and documents
- 🔜 **Multi-Language**: Support for Swahili and other local languages
- 🔜 **Prescription Management**: Digital prescription creation and tracking
- 🔜 **Lab Results**: Upload and view lab test results
- 🔜 **Health Records**: Comprehensive electronic health records (EHR)
- 🔜 **Insurance Claims**: Direct insurance claim submission

---

**Klinate** - Making healthcare accessible, one tap at a time. 🏥📱

*Built with ❤️ using Flutter*

--
-

## 📜 Privacy Policy

**Last Updated: November 15, 2025**

### 1. Introduction

Klinate ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our healthcare platform.

### 2. Information We Collect

**Personal Information:**
- Name, email address, phone number
- Date of birth, gender, location
- Profile photos and professional credentials
- Medical history and health records (for patients)
- Professional qualifications and certifications (for healthcare providers)

**Health Information:**
- Medical conditions and diagnoses
- Prescriptions and medications
- Appointment records and consultation notes
- Lab results and medical documents

**Usage Information:**
- Device information and IP address
- App usage patterns and preferences
- Communication logs (calls, messages, video consultations)
- Payment and transaction history

### 3. How We Use Your Information

- **Healthcare Services**: Facilitate consultations, appointments, and medical care
- **Communication**: Enable messaging, calls, and video consultations between patients and providers
- **Account Management**: Create and manage user accounts and business accounts
- **Payment Processing**: Process consultation fees and transactions
- **Platform Improvement**: Analyze usage to improve our services
- **Legal Compliance**: Comply with healthcare regulations and legal requirements
- **Security**: Protect against fraud and unauthorized access

### 4. Information Sharing

We do not sell your personal information. We may share information with:

- **Healthcare Providers**: When you book appointments or consultations
- **Service Providers**: Third-party services that help operate our platform (payment processors, cloud storage)
- **Legal Authorities**: When required by law or to protect rights and safety
- **Business Transfers**: In case of merger, acquisition, or sale of assets

### 5. Data Security

We implement industry-standard security measures including:
- End-to-end encryption for communications
- Secure data storage and transmission
- Regular security audits and updates
- Access controls and authentication systems
- HIPAA-compliant data handling practices

### 6. Your Rights

You have the right to:
- Access your personal and health information
- Correct inaccurate information
- Request deletion of your data (subject to legal requirements)
- Opt-out of marketing communications
- Export your data in a portable format
- Deactivate or delete your account

### 7. Data Retention

- **Active Accounts**: Data retained while account is active
- **Deactivated Accounts**: 3-month grace period before permanent deletion
- **Deleted Accounts**: 30-day cancellation window, then permanent deletion
- **Medical Records**: Retained as required by healthcare regulations (typically 7-10 years)

### 8. Children's Privacy

Klinate is not intended for users under 18 years of age. We do not knowingly collect information from children. Parents/guardians must create accounts for minors.

### 9. International Data Transfers

Your information may be transferred to and processed in countries other than Kenya. We ensure appropriate safeguards are in place for such transfers.

### 10. Changes to Privacy Policy

We may update this Privacy Policy periodically. We will notify you of significant changes via email or app notification.

### 11. Contact Us

For privacy concerns or questions:
- Email: privacy@klinate.com
- Phone: +254 740 109 195
- Address: Nairobi, Kenya

---

## 📋 Terms and Conditions

**Last Updated: November 15, 2025**

### 1. Acceptance of Terms

By accessing or using Klinate, you agree to be bound by these Terms and Conditions. If you disagree with any part, you may not use our services.

### 2. User Accounts

**Account Creation:**
- You must provide accurate and complete information
- You are responsible for maintaining account security
- You must be 18+ years old or have parental consent
- One person may not create multiple accounts

**Account Types:**
- **Patient Accounts**: For individuals seeking healthcare services
- **Business Accounts**: For healthcare professionals and facilities
- **Admin Accounts**: For platform administrators (by invitation only)

### 3. Business Account Terms

**For Healthcare Providers:**
- Must possess valid professional licenses and certifications
- Must provide accurate qualifications and credentials
- Subject to verification and approval process
- Must maintain professional standards and ethics
- Responsible for accuracy of medical advice and services provided

**Registration Requirements:**
- Complete LinkedIn-style professional profile
- Provide work experience and education history
- Upload valid licenses and certifications
- Verify contact information and physical address
- Set consultation fees and working hours

### 4. Services Provided

**Platform Services:**
- Connection between patients and healthcare providers
- Appointment scheduling and management
- Communication tools (messaging, voice, video calls)
- Payment processing and wallet management
- Medical record storage and management

**Not Provided:**
- Emergency medical services (call emergency services for emergencies)
- Prescription fulfillment (providers may prescribe, but fulfillment is separate)
- Medical diagnosis guarantee (consultations are advisory)

### 5. User Responsibilities

**Patients:**
- Provide accurate medical history
- Attend scheduled appointments or cancel in advance
- Pay consultation fees as agreed
- Use platform for legitimate healthcare purposes only
- Respect healthcare providers' time and expertise

**Healthcare Providers:**
- Maintain valid licenses and certifications
- Provide professional and ethical care
- Maintain patient confidentiality
- Respond to appointments and messages promptly
- Keep availability schedule updated

### 6. Payments and Fees

**Consultation Fees:**
- Set by individual healthcare providers
- Displayed before booking confirmation
- Paid through platform wallet system
- Non-refundable except in case of provider cancellation

**Platform Fees:**
- Service fees may apply to transactions
- Fees clearly disclosed before payment
- Payment methods: M-Pesa, Bank Transfer, Credit/Debit Card

### 7. Cancellations and Refunds

**Appointment Cancellations:**
- Patients may cancel up to 24 hours before appointment for full refund
- Cancellations within 24 hours may incur fees
- Provider cancellations result in automatic full refund
- No-shows may result in forfeiture of fees

### 8. Intellectual Property

**Platform Content:**
- Klinate owns all platform design, code, and branding
- Users retain ownership of their content (profiles, messages, reviews)
- Users grant Klinate license to use content for platform operation

**Prohibited Uses:**
- Copying or reproducing platform code or design
- Using platform content for competing services
- Scraping or automated data collection

### 9. Prohibited Conduct

Users may not:
- Provide false information or impersonate others
- Use platform for illegal activities
- Harass, abuse, or threaten other users
- Share inappropriate or offensive content
- Attempt to hack or compromise platform security
- Spam or send unsolicited communications
- Share login credentials with others

### 10. Content Moderation

We reserve the right to:
- Remove content that violates terms
- Suspend or terminate accounts for violations
- Monitor communications for safety and compliance
- Report illegal activities to authorities

### 11. Liability and Disclaimers

**Platform Liability:**
- Platform provided "as is" without warranties
- We are not liable for medical outcomes or provider actions
- We do not guarantee service availability or accuracy
- Maximum liability limited to fees paid in last 12 months

**Healthcare Provider Liability:**
- Providers are independent professionals
- Providers responsible for their own medical advice and actions
- Platform is not liable for provider negligence or malpractice

### 12. Dispute Resolution

**Process:**
1. Contact support for informal resolution
2. Mediation if informal resolution fails
3. Arbitration in Nairobi, Kenya
4. Kenyan law governs all disputes

### 13. Account Termination

**By User:**
- Deactivate account (3-month grace period)
- Delete account (30-day cancellation window)
- Export data before deletion

**By Klinate:**
- Immediate termination for serious violations
- Suspension for investigation of violations
- Notice provided except in severe cases

### 14. Changes to Terms

We may modify these terms at any time. Continued use after changes constitutes acceptance. Significant changes will be notified via email.

### 15. Severability

If any provision is found unenforceable, remaining provisions remain in effect.

### 16. Contact Information

For questions about these terms:
- Email: legal@klinate.com
- Phone: +254 740 109 195
- Address: Nairobi, Kenya

---

## 🔒 Data Protection Statement

Klinate is committed to protecting your data in compliance with:
- Kenya Data Protection Act, 2019
- HIPAA (Health Insurance Portability and Accountability Act) standards
- GDPR principles for international users
- ISO 27001 information security standards

**Our Commitments:**
- ✅ Secure data encryption in transit and at rest
- ✅ Regular security audits and penetration testing
- ✅ Staff training on data protection and privacy
- ✅ Incident response plan for data breaches
- ✅ Data minimization - collect only what's necessary
- ✅ User control over personal data
- ✅ Transparent data practices

**Your Data Rights:**
- Right to access your data
- Right to rectification of inaccurate data
- Right to erasure ("right to be forgotten")
- Right to data portability
- Right to object to processing
- Right to withdraw consent

For data protection inquiries: dpo@klinate.com

---

## ⚖️ Healthcare Disclaimer

**Important Notice:**

Klinate is a healthcare platform that facilitates connections between patients and healthcare providers. We do not provide medical advice, diagnosis, or treatment directly.

**Key Points:**
- 🏥 **Not for Emergencies**: In case of medical emergency, call emergency services immediately
- 👨‍⚕️ **Provider Responsibility**: Healthcare providers are independent professionals responsible for their own medical advice
- 📋 **No Guarantee**: We do not guarantee medical outcomes or accuracy of provider advice
- 💊 **Prescription Verification**: Always verify prescriptions with licensed pharmacists
- 🔍 **Second Opinions**: Seek second opinions for serious conditions
- 📱 **Technology Limitations**: Video/voice quality may affect consultations

**Always consult with qualified healthcare professionals for medical decisions.**

---

## 📞 Support & Contact

**Customer Support:**
- Email: support@klinate.com
- Phone: +254 740 109 195
- Hours: Monday - Friday, 8:00 AM - 6:00 PM EAT

**Business Account Support:**
- Email: business@klinate.com
- Phone: +254 740 109 196

**Technical Support:**
- Email: tech@klinate.com

**Emergency:** For medical emergencies, call 999 or 112 immediately.

---

**© 2025 Klinate. All rights reserved.**
