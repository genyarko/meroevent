# MeroEvent - Modern Event Management & Ticketing Platform

![Flutter](https://img.shields.io/badge/Flutter-3.27.1-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.6.2-0175C2?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-Ready-3ECF8E?logo=supabase)
![License](https://img.shields.io/badge/license-MIT-blue)

A modern, scalable event management and ticketing platform built with Flutter and Supabase. Features include event discovery, ticket purchasing, QR code validation, real-time updates, and comprehensive analytics.

## 🌟 Features

### Core Features
- **Event Discovery**: Browse and search events with advanced filters
- **Smart Ticketing**: QR codes, dynamic pricing, seat selection
- **Secure Payments**: Stripe integration with multiple payment methods
- **Real-time Updates**: Live ticket availability and event notifications
- **Social Integration**: Reviews, ratings, and social sharing
- **Analytics Dashboard**: Comprehensive insights for organizers

### Technical Highlights
- **Clean Architecture**: Organized, maintainable, and testable codebase
- **State Management**: Riverpod for reactive state management
- **Backend**: Supabase (Auth, Database, Storage, Realtime)
- **UI/UX**: Material 3 design with light/dark theme support
- **Cross-platform**: Single codebase for iOS, Android, and Web

## 📋 Prerequisites

- **Flutter SDK**: 3.27.1 or higher
- **Dart SDK**: 3.6.2 or higher
- **Supabase Account**: [Create one here](https://supabase.com)
- **Stripe Account**: For payment processing (optional for development)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/genyarko/meroevent.git
cd meroevent
git checkout claude/event-app-supabase-011CV4BXn3MJPo9zYaLnQi5y
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

Copy the example environment file and fill in your credentials:

```bash
cp .env.example .env
```

Edit `.env` and add your Supabase credentials:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Stripe Configuration (optional for development)
STRIPE_PUBLISHABLE_KEY=pk_test_your-key
STRIPE_SECRET_KEY=sk_test_your-key
```

### 4. Run the App

```bash
# Development mode
flutter run

# For web
flutter run -d chrome

# For iOS
flutter run -d ios

# For Android
flutter run -d android
```

## 🗄️ Supabase Setup

### Database Setup

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Copy your project URL and anon key
3. Run the SQL migrations from `system architecture/event-app-architecture.md`
4. Set up Row Level Security (RLS) policies from `system architecture/supabase-config-guide.md`

### Storage Buckets

Create the following storage buckets in Supabase:
- `event-images` (public)
- `ticket-qr-codes` (private)
- `venue-images` (public)
- `user-uploads` (private)

### Edge Functions (Optional)

Deploy Edge Functions for advanced features:
```bash
supabase functions deploy generate-tickets
supabase functions deploy send-ticket-email
supabase functions deploy validate-ticket
supabase functions deploy process-payment
```

## 📁 Project Structure

```
lib/
├── core/                   # Core functionality
│   ├── config/            # Configuration files
│   ├── constants/         # App constants
│   ├── errors/            # Error handling
│   ├── theme/             # Theme configuration
│   └── utils/             # Utility functions
├── data/                  # Data layer
│   ├── datasources/       # Remote & local data sources
│   ├── models/            # Data models
│   └── repositories/      # Repository implementations
├── domain/                # Domain layer
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business logic
└── presentation/          # Presentation layer
    ├── providers/         # State management
    ├── screens/           # UI screens
    ├── widgets/           # Reusable widgets
    └── router/            # Navigation
```

## 🎨 Design System

### Theme
- **Primary Color**: Indigo (#6366F1)
- **Secondary Color**: Pink (#EC4899)
- **Accent Color**: Green (#10B981)
- **Typography**: Inter font family
- **Design System**: Material 3

### Components
- Custom buttons (Elevated, Outlined, Text)
- Input fields with validation
- Cards with consistent styling
- Responsive layouts for all screen sizes

## 📦 Dependencies

### State Management
- `flutter_riverpod` - State management
- `riverpod_annotation` - Code generation

### Backend
- `supabase_flutter` - Supabase client
- `dio` - HTTP client

### UI/UX
- `flutter_animate` - Animations
- `google_fonts` - Custom fonts
- `cached_network_image` - Image caching
- `shimmer` - Loading effects

### Features
- `flutter_stripe` - Payment processing
- `mobile_scanner` - QR code scanning
- `qr_flutter` - QR code generation
- `flutter_map` - Maps integration
- `table_calendar` - Calendar views
- `fl_chart` - Charts and analytics

[See pubspec.yaml for complete list]

## 🔧 Development Workflow

### Phase 1: Foundation ✅ (COMPLETE)
- Project setup and configuration
- Clean Architecture structure
- Theme system and design constants
- Error handling framework
- Supabase integration

### Phase 2: Core Architecture (IN PROGRESS)
- Domain entities
- Repository interfaces
- Use cases
- Data models

### Phase 3-19: Feature Development
See `nextSteps.txt` for detailed phase breakdown

## 📊 Progress Tracking

Track development progress in `nextSteps.txt`:
- ✅ Phase 1: Foundation (100%)
- 🔄 Phase 2-19: Pending

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Generate coverage report
flutter test --coverage
```

## 📝 Code Generation

When you add new models or providers using Freezed or Riverpod annotations:

```bash
# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (recommended during development)
flutter pub run build_runner watch --delete-conflicting-outputs
```

## 🔒 Security

- Environment variables stored in `.env` (not committed)
- Supabase RLS policies for data security
- Secure storage for sensitive data
- Input validation and sanitization

## 🌐 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📚 Documentation

- **Architecture**: See `system architecture/event-app-architecture.md`
- **Supabase Config**: See `system architecture/supabase-config-guide.md`
- **Implementation Guide**: See `system architecture/flutter-event-app-implementation.md`
- **Progress**: See `nextSteps.txt`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

- **Development Team** - Initial work

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Stripe for payment processing
- All contributors and supporters

## 📧 Support

For support, email support@meroevent.com or open an issue on GitHub.

---

**Status**: Phase 1 Complete ✅ | **Version**: 1.0.0 | **Last Updated**: 2025-11-12
