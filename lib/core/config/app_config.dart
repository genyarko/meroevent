/// Application-wide configuration
class AppConfig {
  // App Information
  static const String appName = 'MeroEvent';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API Configuration
  static const int apiTimeout = 30; // seconds
  static const int connectTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 50; // MB

  // Image Configuration
  static const int maxImageSize = 5; // MB
  static const int imageQuality = 85; // percentage
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Map Configuration
  static const double defaultMapZoom = 14.0;
  static const double defaultMapRadius = 10.0; // km
  static const int maxNearbyEventsDistance = 50; // km

  // Ticket Configuration
  static const int maxTicketsPerPurchase = 10;
  static const int minTicketsPerPurchase = 1;
  static const Duration ticketReservationTime = Duration(minutes: 15);

  // QR Code Configuration
  static const int qrCodeSize = 300;
  static const int qrCodeVersion = 5;

  // Notification Configuration
  static const Duration notificationReminder = Duration(hours: 24);
  static const bool enablePushNotifications = true;

  // Feature Flags
  static const bool enableSocialFeatures = true;
  static const bool enableChatFeatures = false;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // URLs
  static const String privacyPolicyUrl = 'https://yourdomain.com/privacy';
  static const String termsOfServiceUrl = 'https://yourdomain.com/terms';
  static const String supportEmail = 'support@meroevent.com';
  static const String supportUrl = 'https://support.meroevent.com';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/meroevent';
  static const String twitterUrl = 'https://twitter.com/meroevent';
  static const String instagramUrl = 'https://instagram.com/meroevent';

  // Prevent instantiation
  AppConfig._();
}
