# 🪙 Coin Identifier Pro

A scalable Flutter app that uses AI to identify coins, determine their value, and help users track their collections with real-time market data and premium features.

## 📱 Features

### Core Features
- **AI-Powered Coin Identification**: Upload photos to identify coins with confidence scores
- **Real-time Market Values**: Get accurate price estimates for identified coins
- **Collection Tracking**: Save and organize your coin identification history
- **Responsive Design**: Optimized for iPhone 14 and iPhone SE screen sizes
- **Offline Support**: Graceful handling of offline scenarios

### Premium Features
- **Unlimited History**: Access complete identification history (free users limited to 15)
- **Collection Analytics**: Track total collection value, average confidence scores
- **Advanced Insights**: Detailed statistics and trends
- **Priority Support**: Enhanced customer support experience

## 🛠 Tech Stack

### Frontend
- **Flutter** 3.19+ - Cross-platform mobile development
- **Riverpod** 2.4+ - State management solution
- **Go Router** - Declarative routing

### Backend & Services
- **Firebase** - Backend-as-a-Service
  - Authentication (Email/Password + Apple Sign-In)
  - Firestore NoSQL database
  - Cloud Storage for coin images
  - Real-time data synchronization
- **Apphud** - Subscription management and paywall
- **Mock AI API** - Simulated coin identification service

### Key Packages
```yaml
dependencies:
  flutter: ^3.19.0
  flutter_riverpod: ^2.4.0
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  apphud_flutter: ^2.0.0
  image_picker: ^1.0.0
  cached_network_image: ^3.3.0
  connectivity_plus: ^5.0.0
  shared_preferences: ^2.2.0
  intl: ^0.19.0
  http: ^1.1.0
```

## 🏗 Architecture

### Clean Architecture Pattern
```
lib/
├── core/                   # Core utilities and constants
│   ├── constants/         # App colors, dimensions, API endpoints
│   └── utils/            # Responsive utilities, helpers
├── models/               # Data models
│   └── coin_identification.dart
├── presentation/         # UI Layer
│   ├── river_pods/      # State management providers
│   ├── screens/         # Screen widgets organized by feature
│   │   ├── auth/        # Authentication screens
│   │   ├── history/     # History and collection screens
│   │   ├── home/        # Home screen and widgets
│   │   ├── identify/    # Coin identification screens
│   │   ├── onboarding/  # App onboarding flow
│   │   ├── paywall/     # Subscription and paywall screens
│   │   ├── profile/     # User profile screens
│   │   └── result/      # Identification result screens
│   └── widgets/         # Reusable components
├── services/            # External service integrations
│   ├── apphud_service.dart
│   ├── firebase_auth_service.dart
│   ├── firebase_coin_service.dart
│   └── firebase_options.dart
└── main.dart
```

### State Management Architecture
- **Riverpod Providers**: Centralized state management
- **Repository Pattern**: Clean separation between UI and business logic
- **Real-time Updates**: Reactive UI that responds to data changes
- **Error Handling**: Comprehensive error states and user feedback

### Key Design Decisions

#### 1. **Riverpod over Bloc**
- **Why**: Simpler syntax, better performance, compile-time safety
- **Benefits**: Reduced boilerplate, automatic dependency injection, better testing

#### 2. **Firebase over Supabase**
- **Why**: Mature ecosystem, excellent Flutter integration, real-time capabilities
- **Benefits**: Comprehensive auth system, offline support, scalable NoSQL database

#### 3. **Modular Screen Architecture**
- **Why**: Scalability and maintainability
- **Structure**: Each screen has its own folder with widgets and logic
- **Benefits**: Easy to navigate, test, and modify individual features

#### 4. **Responsive Design System**
- **Breakpoints**: iPhone SE (small) vs iPhone 14+ (regular)
- **Adaptive UI**: Font sizes, padding, and layouts adjust automatically
- **Utility Class**: `Responsive` helper for consistent sizing

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.19+
- Dart 3.3+
- iOS Simulator / Android Emulator
- Firebase account
- Apphud account

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/eaaniwezi/coin_identifier.git
cd coin_identifier
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Set up Firebase configuration**

Add your Firebase configuration files:
- Place `google-services.json` in `android/app/`
- Place `GoogleService-Info.plist` in `ios/Runner/`

4. **Run the app**
```bash
flutter run
```

### 🔥 Firebase Setup

1. **Create a new Firebase project** at [console.firebase.google.com](https://console.firebase.google.com)

2. **Add your Flutter app** to the Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the correct directories as per Firebase documentation

3. **Configure Firebase CLI**
```bash
firebase login
firebase projects:list
flutterfire configure
```

4. **Firestore Database Setup**

Create these collections and security rules:

**Collections Structure:**
```
users/
├── {userId}/
│   ├── email: string
│   ├── displayName: string
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp

coinIdentifications/
├── {identificationId}/
│   ├── userId: string
│   ├── imageUrl: string
│   ├── coinName: string
│   ├── origin: string
│   ├── issueYear: number
│   ├── mintMark: string
│   ├── rarity: string ('Common', 'Uncommon', 'Rare', 'Error')
│   ├── priceEstimate: number
│   ├── confidenceScore: number (0-100)
│   ├── identifiedAt: timestamp
│   └── createdAt: timestamp
```

**Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can only access their own coin identifications
    match /coinIdentifications/{identificationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

5. **Firebase Authentication Setup**
   - Enable Email/Password authentication
   - Configure Apple Sign-In provider
   - Set up authorized domains for your app

6. **Firebase Storage Setup**
   - Create storage bucket for coin images
   - Configure storage security rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /coin-images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 🎨 Customization

#### Theme Configuration
Located in `lib/core/constants/app_colors.dart`:
```dart
class AppColors {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color primaryNavy = Color(0xFF1A237E);
  // ... customize your brand colors
}
```

#### Responsive Breakpoints
Located in `lib/core/utils/responsive.dart`:
```dart
class Responsive {
  static bool isMobileSmall(BuildContext context) {
    return MediaQuery.of(context).size.width < 375; // iPhone SE
  }
}
```

## 🚀 Running the App

### Development
```bash
# iOS Simulator
flutter run -d ios

# Android Emulator  
flutter run -d android

# Chrome (for web testing)
flutter run -d chrome
```

### Production Build
```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📊 Project Statistics

- **Total Screens**: 8 main screens
- **Riverpod Providers**: 12 state management providers
- **Reusable Widgets**: 25+ custom components
- **API Integrations**: 3 external services
- **Offline Features**: 4 offline-capable screens
- **Responsive Breakpoints**: 2 (iPhone SE, iPhone 14+)

## 🚦 Core User Flows

### 1. Onboarding Flow
```
Splash → Welcome → Sign Up/Sign In → Home
```

### 2. Coin Identification Flow
```
Home → Camera/Gallery → AI Processing → Results → Save to History
```

### 3. Premium Subscription Flow
```
Any Screen → Paywall → Apple Pay → Success → Premium Features Unlocked
```

### 4. Collection Management Flow
```
History → Filter/Search → Coin Details → Edit/Delete → Analytics (Premium)
```

## 🎯 Performance Optimizations

- **Image Caching**: Implements `cached_network_image` for efficient loading
- **Lazy Loading**: History screen loads data in paginated chunks
- **State Persistence**: Critical state saved locally with `shared_preferences`
- **Offline Caching**: Last 3 identifications cached for offline viewing
- **Memory Management**: Proper disposal of controllers and streams

## 📈 Scalability Considerations

### Database Design
- **NoSQL Collections**: Optimized for user-specific data retrieval
- **Real-time Listeners**: Firebase real-time updates for live data
- **Offline Support**: Built-in Firebase offline capabilities
- **Security Rules**: Server-side validation and access control

### State Management
- **Provider Composition**: Modular providers for specific features
- **Dependency Injection**: Automatic provider dependencies
- **Memory Efficiency**: Providers auto-dispose when not needed

### API Architecture
- **Repository Pattern**: Clean abstraction for external services
- **Error Handling**: Comprehensive error states and retry mechanisms
- **Rate Limiting**: Built-in API call throttling

## 🐛 Troubleshooting

### Common Issues

#### 1. Image Upload Issues
```bash
# Check Firebase Storage rules and permissions
# Verify authentication is working properly
# Check storage bucket configuration in Firebase Console
```

#### 2. Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub deps
flutter build ios --release
```
