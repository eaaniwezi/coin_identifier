# 🪙 Coin Radar

**AI-Powered Coin Recognition & Collection Management**

A scalable Flutter application that uses AI to identify coins, determine their value, and helps users organize and track their coin collection with real-time market data.

## 📱 Features

### Core Functionality
- **AI Coin Recognition** - Upload or capture photos to identify coins instantly
- **Real-time Valuation** - Get current market estimates for identified coins
- **Collection Management** - Save, organize, and track your coin collection
- **Detailed Analytics** - View collection statistics and total value
- **Offline Support** - Basic functionality available without internet

### User Experience
- **Seamless Authentication** - Email/password and Apple Sign-In support
- **Responsive Design** - Optimized for iPhone 14 and iPhone SE
- **Pro Features** - Premium subscription with enhanced capabilities
- **Search & Filter** - Find coins in your collection quickly

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Payments**: Apphud SDK for subscription management
- **State Management**: Riverpod
- **Local Storage**: Flutter Secure Storage
- **Development**: Cursor AI-assisted development

### Project Structure
```
lib/
├── core/
│   ├── config/           # Environment configuration
│   ├── constants/        # App constants and themes
│   └── utils/           # Utility functions
├── models/              # Data models
├── services/            # Business logic and API services
│   ├── supabase_auth_service.dart
│   ├── supabase_coin_service.dart
│   └── apphud_service.dart
├── presentation/
│   ├── river_pods/      # State management
│   ├── screens/         # UI screens
│   └── widgets/         # Reusable components
└── main.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.2+)
- iOS development environment (Xcode)
- Supabase account
- Apphud account (for subscriptions)

### Environment Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/coin-identifier-pro.git
   cd coin-identifier-pro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the project root:
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   DEBUG_MODE=true
   
   # Optional (for future features)
   AI_API_URL=
   AI_API_KEY=
   APPHUD_API_KEY=your_apphud_api_key
   ```

4. **Set up Supabase**
   
   Run the database schema in your Supabase SQL Editor:
   ```sql
   -- See database_schema.sql for complete setup
   -- Creates users and coin_identifications tables
   -- Sets up RLS policies and triggers
   ```

5. **Configure Supabase Storage**
   
   Create a `coin-images` bucket in Supabase Storage:
   - Public bucket: ✅ Yes
   - File size limit: 5MB
   - Allowed types: image/jpeg, image/png, image/webp

6. **Run the application**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Supabase Setup

1. **Database Tables**
   - `users` - User profiles and collection stats
   - `coin_identifications` - Saved coin identifications

2. **Storage Buckets**
   - `coin-images` - User uploaded coin images

3. **Authentication**
   - Email/password authentication
   - Apple Sign-In (iOS)
   - Row Level Security (RLS) enabled

### Key Services

#### Authentication Service (`SupabaseAuthService`)
- Handles user registration and login
- Manages session persistence
- Supports multiple auth methods

#### Coin Service (`SupabaseCoinService`)
- Image upload to Supabase Storage
- AI coin identification (currently mocked)
- Collection management
- User statistics

#### Apphud Service (`ApphudService`)
- Subscription management
- Paywall integration
- Pro feature access control

## 📊 Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT,
  display_name TEXT,
  total_collection_value DECIMAL(10,2) DEFAULT 0.00,
  coins_collected INTEGER DEFAULT 0,
  is_pro_user BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Coin Identifications Table
```sql
CREATE TABLE coin_identifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  image_url TEXT NOT NULL,
  coin_name TEXT NOT NULL,
  origin TEXT,
  issue_year INTEGER,
  rarity TEXT CHECK (rarity IN ('Common', 'Uncommon', 'Rare', 'Very Rare', 'Error')),
  price_estimate DECIMAL(10,2),
  confidence_score INTEGER CHECK (confidence_score >= 0 AND confidence_score <= 100),
  identified_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🎯 Core User Flow

1. **Onboarding** → **Sign Up/Sign In** → **Home**
2. **Upload/Take Photo** → **AI Processing** → **Results**
3. **Save to Collection** → **View History** → **Profile Stats**

## 📱 Screens

- **Onboarding** - App introduction and features
- **Authentication** - Sign up/sign in options
- **Home** - Main dashboard with upload options
- **Camera/Upload** - Image capture and selection
- **Results** - Coin identification display
- **History** - Collection browsing and management
- **Profile** - User stats and subscription management
- **Paywall** - Pro subscription options

## 🔐 Security Features

- Row Level Security (RLS) on all database tables
- Secure image upload with user-specific folders
- Environment variable protection for API keys
- Flutter Secure Storage for local data
- Session management with automatic refresh

## 🚧 Current Limitations

- AI identification is currently mocked (ready for real API integration)
- Limited to iOS platform (Android support planned)
- Basic offline functionality (full offline mode planned)

## 🔄 Future Enhancements

- Real AI model integration for coin identification
- Android platform support
- Advanced collection analytics
- Social features (sharing collections)
- Marketplace integration
- Enhanced offline capabilities

## 📦 Dependencies

### Core
- `flutter_riverpod` - State management
- `supabase_flutter` - Backend services
- `flutter_secure_storage` - Secure local storage
- `flutter_dotenv` - Environment configuration

### UI/UX
- `cached_network_image` - Image caching
- `image_picker` - Camera and gallery access
- `share_plus` - Sharing functionality

### Authentication
- `sign_in_with_apple` - Apple Sign-In integration
- `crypto` - Cryptographic operations

### Utilities
- `connectivity_plus` - Network status
- `intl` - Internationalization
- `shared_preferences` - Simple local storage

## 🛠️ Development

### Code Quality
- Follows Flutter best practices
- Modular architecture with clear separation of concerns
- Comprehensive error handling
- Type-safe development

### State Management
- Riverpod for reactive state management
- Provider pattern for service injection
- Immutable state objects

### Testing Strategy
- Unit tests for services and models
- Widget tests for UI components
- Integration tests for complete user flows

## 📄 License

This project is proprietary software. All rights reserved.

## 🤝 Contributing

This is a private project. For development team members:

1. Follow the established code style
2. Write tests for new features
3. Update documentation as needed
4. Use conventional commit messages

## 📞 Support

For technical issues or questions, contact the development team or create an issue in the project repository.

---