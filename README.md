# Klinate - Professional Healthcare Platform

A comprehensive Flutter-based healthcare platform that connects patients with healthcare professionals and facilities. Built with Firebase backend, professional profiles, comprehensive business account management, and integrated telemedicine services.

## 🏥 Overview

Klinate is a modern, production-ready healthcare platform designed to make medical services accessible through digital channels. The platform features professional profiles for healthcare providers, comprehensive business account management, and seamless patient-provider connections with full communication capabilities.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Android/iOS device or emulator

### Firebase Setup (IMPORTANT)

This project uses Firebase for backend services. You **MUST** set up Firebase before running the app.

#### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard to create your project

#### Step 2: Configure Environment Variables

1. Copy the `.env.example` file to create your own `.env` file:
   ```bash
   cp .env.example .env
   ```

2. Get your Firebase configuration:
   - In Firebase Console, go to **Project Settings** (gear icon)
   - Scroll down to "Your apps" section
   - Click on the Web app icon (</>) or create a new web app
   - Copy the configuration values from the Firebase SDK snippet

3. Update your `.env` file with your Firebase credentials:
   ```env
   FIREBASE_API_KEY=your_actual_api_key_here
   FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
   FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here
   FIREBASE_APP_ID=your_app_id_here
   FIREBASE_MEASUREMENT_ID=your_measurement_id_here
   ```

#### Step 3: Configure Firebase for Each Platform

**Option A: Using FlutterFire CLI (Recommended)**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for your Flutter project
flutterfire configure
```

**Option B: Manual Configuration**

**For Android:**
1. Download `google-services.json` from Firebase Console
2. Copy `android/app/google-services.json.example` to `android/app/google-services.json`
3. Replace the placeholder values with your actual Firebase configuration

**For iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/` directory

**For Web:**
1. Copy `lib/firebase_options.dart.example` to `lib/firebase_options.dart`
2. Replace the placeholder values with your actual Firebase web app credentials from Firebase Console

#### Step 4: Enable Firebase Services

In your Firebase Console, enable the following services:

1. **Authentication**:
   - Go to Authentication > Sign-in method
   - Enable Email/Password authentication
   - Enable Google Sign-In (optional)

2. **Firestore Database**:
   - Go to Firestore Database
   - Create database in production mode
   - Set up security rules (see below)

3. **Storage** (for profile images and documents):
   - Go to Storage
   - Get started with default settings
   - Set up security rules

#### Step 5: Firestore Security Rules

Add these security rules in Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Providers collection
    match /providers/{providerId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Appointments collection
    match /appointments/{appointmentId} {
      allow read, write: if request.auth != null;
    }
    
    // Messages collection
    match /messages/{messageId} {
      allow read, write: if request.auth != null;
    }
    
    // Admin collection (restricted)
    match /admins/{adminId} {
      allow read: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/i-wangila/klinate.git
   cd klinate
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables** (see Firebase Setup above)

4. **Run the app**
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

**Web:**
```bash
flutter build web --release
```

## 🔐 Security & Environment Variables

### Important Security Notes

⚠️ **NEVER commit your `.env` file to version control!**

The `.env` file contains sensitive API keys and should be kept private. This file is already added to `.gitignore` to prevent accidental commits.

### For Contributors

1. Copy `.env.example` to `.env`
2. Add your own Firebase credentials
3. Never share your `.env` file publicly
4. Use different Firebase projects for development and production

### For Production Deployment

1. Use environment-specific `.env` files:
   - `.env.development`
   - `.env.staging`
   - `.env.production`

2. Set up CI/CD secrets for automated deployments
3. Use Firebase App Distribution for beta testing
4. Enable Firebase App Check for additional security

## ✨ Key Features

### 🔐 Authentication & Security
- Firebase Authentication integration
- Email/Password authentication with strong password requirements
- User titles (Mr., Mrs., Dr., Prof., etc.)
- Secure session management
- Role-based access control

### 👩‍⚕️ Healthcare Provider Network
- Individual doctors and specialists
- Healthcare facilities and hospitals
- Pharmacies and laboratories
- Business account registration with document verification
- Professional profile management with Firebase Storage
- Location-based provider listings (city & country)
- Patient management system
- Dynamic ratings and reviews system

### 📞 Communication System
- Real-time chat with Firestore
- WebRTC voice and video calling (WhatsApp-style)
- Unified inbox with message categories
- Message notifications
- System notifications
- Direct phone dialing from provider profiles

### 📅 Appointment Management
- Smart booking system
- Multiple consultation types (In-person, Video, Phone)
- Real-time availability checking
- Appointment rescheduling
- Appointment history with clear function
- Reminder notifications
- Analytics dashboard

### 💳 Payment & Wallet System
- Digital wallet management
- M-Pesa integration (Top-up & Withdraw)
- C2B payment for direct provider payments
- Transaction history
- Pay medical bills feature
- Transfer between users
- Payment method selection

### 🛡️ Admin System
- Comprehensive admin dashboard
- Business account approval workflow
- Document verification system
- User management with role assignment
- Provider and patient analytics
- Activity logging and audit trails
- Review management and moderation
- Reports and analytics

### 📊 Business Dashboard
- Patient management with detailed records
- Follow-up system with reminders
- Interactive analytics with fl_chart
- Review and rating management
- Appointment tracking and statistics
- Revenue analytics
- Patient satisfaction metrics

### 📄 Document Management
- Upload medical records and certificates
- Document verification for providers
- Download functionality for all documents
- Document status tracking (Pending, Approved, Rejected)
- Secure document storage

### ⭐ Reviews & Ratings
- Patient review system
- Provider rating calculation
- Review moderation by admins
- Persistent storage with SharedPreferences
- Prevention of self-reviews
- Real-time rating updates

## 🛠 Technical Stack

### Framework & Language
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **Firebase**: Backend as a Service

### Firebase Services
- **Firebase Authentication**: User authentication and management
- **Cloud Firestore**: Real-time NoSQL database
- **Firebase Storage**: File and image storage
- **Firebase Cloud Messaging**: Push notifications (optional)

### Key Dependencies
- `firebase_core ^3.8.1`: Firebase core functionality
- `firebase_auth ^5.3.3`: Authentication services
- `cloud_firestore ^5.5.1`: Firestore database
- `flutter_dotenv ^5.1.0`: Environment variable management
- `intl ^0.19.0`: Internationalization
- `table_calendar ^3.0.9`: Calendar widget
- `image_picker ^1.0.4`: Image selection
- `shared_preferences ^2.2.2`: Local storage
- `fl_chart ^0.69.0`: Analytics charts
- `url_launcher ^6.2.4`: External links and phone calls
- `path_provider ^2.1.1`: File system paths
- `file_picker ^8.1.2`: File selection

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point with Firebase initialization
├── firebase_options.dart        # Firebase configuration for all platforms
├── models/                      # Data models
│   ├── user_profile.dart
│   ├── provider_profile.dart
│   ├── appointment.dart
│   ├── message.dart
│   └── ...
├── screens/                     # UI screens
│   ├── onboarding_screen.dart
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   ├── provider_dashboard_screen.dart
│   ├── admin_dashboard_screen.dart
│   └── ...
├── services/                    # Business logic with Firebase integration
│   ├── user_service.dart
│   ├── provider_service.dart
│   ├── appointment_service.dart
│   ├── message_service.dart
│   └── ...
├── middleware/                  # Route guards
│   └── auth_guard.dart
└── widgets/                     # Reusable components
    └── role_switcher.dart

android/
└── app/
    └── google-services.json     # Android Firebase config

ios/
└── Runner/
    └── GoogleService-Info.plist # iOS Firebase config

.env                             # Environment variables (DO NOT COMMIT)
.env.example                     # Template for environment variables
```

## 💳 M-Pesa Integration

### Overview
The app integrates with Safaricom's M-Pesa Daraja API for real money transactions:
- **Top Up**: Users can add money to their wallet via M-Pesa STK Push
- **Withdraw**: Users can withdraw money from wallet to their M-Pesa account

### ⚠️ IMPORTANT SECURITY NOTE

**M-Pesa integration requires a backend server!** Never put M-Pesa credentials directly in your mobile app.

**Recommended Architecture:**
```
Flutter App → Backend Server → M-Pesa Daraja API
              (Firebase Functions,
               Node.js, PHP, etc.)
```

### Setup M-Pesa Integration

1. **Get Daraja API Credentials:**
   - Visit https://developer.safaricom.co.ke/
   - Create an account and login
   - Go to "My Apps" and create a new app
   - Select "Lipa Na M-Pesa Online" API
   - Get your Consumer Key, Consumer Secret, Business Short Code, and Passkey

2. **Set up Firebase Cloud Functions (Backend):**
   ```bash
   cd functions
   npm install
   ```

3. **Configure M-Pesa credentials in Firebase:**
   ```bash
   firebase functions:config:set \
     mpesa.consumer_key="YOUR_CONSUMER_KEY" \
     mpesa.consumer_secret="YOUR_CONSUMER_SECRET" \
     mpesa.business_short_code="YOUR_SHORTCODE" \
     mpesa.passkey="YOUR_PASSKEY" \
     mpesa.environment="sandbox" \
     app.url="https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net"
   ```

4. **Deploy Firebase Functions:**
   ```bash
   firebase deploy --only functions
   ```

5. **Update .env file (for reference only):**
   ```env
   MPESA_CONSUMER_KEY=your_consumer_key
   MPESA_CONSUMER_SECRET=your_consumer_secret
   MPESA_BUSINESS_SHORT_CODE=your_shortcode
   MPESA_PASSKEY=your_passkey
   MPESA_CALLBACK_URL=https://your-functions-url/mpesaCallback
   MPESA_ENVIRONMENT=sandbox  # or 'production'
   ```

6. **Test in Sandbox:**
   - Use M-Pesa sandbox for testing
   - Test phone number: 254708374149
   - Test amounts: 1-70000
   - Enter PIN: 1234 (sandbox test PIN)

### M-Pesa Service Features

- **STK Push**: Prompts user to enter M-Pesa PIN on their phone
- **Transaction Query**: Check status of pending transactions
- **B2C Payments**: Send money from business to customer (withdrawals)
- **Phone Number Validation**: Validates Kenyan phone numbers
- **Auto-formatting**: Formats phone numbers correctly

### Production Checklist

Before going live with M-Pesa:
- [ ] Set up production Daraja API credentials
- [ ] Deploy secure backend server
- [ ] Implement proper callback handling
- [ ] Set up transaction logging
- [ ] Implement retry logic for failed transactions
- [ ] Add transaction reconciliation
- [ ] Test thoroughly in sandbox environment
- [ ] Get M-Pesa Go-Live approval from Safaricom

## 🔧 Firebase Collections Structure

```
users/
  {userId}/
    - name, email, phone, role, profilePicture, etc.

providers/
  {providerId}/
    - userId, specialization, status, rating, etc.

appointments/
  {appointmentId}/
    - patientId, providerId, date, time, status, etc.

messages/
  {messageId}/
    - senderId, receiverId, content, timestamp, etc.

admins/
  {adminId}/
    - userId, permissions, createdAt, etc.
```

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (responsive design)

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Set up your own Firebase project for testing
4. Create your `.env` file (never commit it!)
5. Make your changes
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style
- Follow Dart/Flutter style guidelines
- Use meaningful variable names
- Add comments for complex logic
- Keep Firebase queries efficient
- Maintain consistent file organization

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support & Contact

- **Email**: support@klinate.com
- **Phone**: +254740109195
- **GitHub**: [https://github.com/i-wangila/klinate](https://github.com/i-wangila/klinate)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend infrastructure
- Healthcare providers for their valuable input
- Open source community for excellent packages

## ⚠️ Important Security Notes

1. **Never commit sensitive files to Git:**
   - `.env` - Contains Firebase API keys
   - `android/app/google-services.json` - Android Firebase config
   - `ios/Runner/GoogleService-Info.plist` - iOS Firebase config
   - `lib/firebase_options.dart` - Flutter Firebase config
   
2. **These files are in .gitignore** - They won't be committed to version control

3. **Use the .example files** - Copy them and add your real credentials:
   ```bash
   cp android/app/google-services.json.example android/app/google-services.json
   cp lib/firebase_options.dart.example lib/firebase_options.dart
   # Then edit these files with your actual Firebase credentials
   ```

4. **Use separate Firebase projects** - Development, staging, and production

5. **Enable Firebase security rules** - Protect your data

6. **Monitor Firebase usage** - Stay within free tier limits or upgrade as needed

7. **Backup your data** - Regular Firestore exports recommended

8. **Keep dependencies updated** - Run `flutter pub upgrade` regularly

9. **Test on multiple platforms** - Ensure compatibility across Android, iOS, and Web

## 🔄 Version History

### Version 2.0 (Current)
- ✨ User titles support (Mr., Mrs., Dr., Prof., etc.)
- 🌍 Location-based provider profiles (city & country)
- 📞 WebRTC video and voice calling
- ⭐ Dynamic reviews and ratings system
- 📱 Direct phone dialing from profiles
- 💳 M-Pesa C2B payment integration
- 📄 Document upload and download functionality
- 🎨 Standardized button styling across app
- 🔄 Provider persistence fix (no more disappearing profiles)
- 🛡️ Enhanced admin review management
- 📊 Improved analytics and reporting

### Version 1.0
- Firebase integration with Authentication and Firestore
- Business dashboard with patient management
- Real-time messaging and notifications
- Appointment booking and management
- Admin system with approval workflow
- Multi-role support (Patient, Provider, Admin)

---

**Made with ❤️ for better healthcare access**
