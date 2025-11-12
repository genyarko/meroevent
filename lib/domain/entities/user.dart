import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class User extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;

  // Location
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  // Preferences
  final List<String>? interests;
  final Map<String, dynamic>? preferences;
  final String? language;
  final String? timezone;

  // Settings
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool marketingEmails;

  // Social
  final Map<String, String>? socialLinks;

  // Karma/Points
  final int karmaPoints;

  // Verification
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isProfileComplete;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.phone,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.interests,
    this.preferences,
    this.language,
    this.timezone,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.marketingEmails = true,
    this.socialLinks,
    this.karmaPoints = 0,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isProfileComplete = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  // Helper methods
  String get displayName => fullName ?? email.split('@').first;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  bool get hasLocation => city != null || country != null;
  bool get hasInterests => interests != null && interests!.isNotEmpty;
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    var age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Copy with method
  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    String? language,
    String? timezone,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? marketingEmails,
    Map<String, String>? socialLinks,
    int? karmaPoints,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      socialLinks: socialLinks ?? this.socialLinks,
      karmaPoints: karmaPoints ?? this.karmaPoints,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        fullName,
        avatarUrl,
        bio,
        dateOfBirth,
        gender,
        city,
        country,
        latitude,
        longitude,
        interests,
        preferences,
        language,
        timezone,
        emailNotifications,
        pushNotifications,
        smsNotifications,
        marketingEmails,
        socialLinks,
        karmaPoints,
        isEmailVerified,
        isPhoneVerified,
        isProfileComplete,
        createdAt,
        updatedAt,
        lastLoginAt,
      ];
}

/// Organizer Profile entity
class OrganizerProfile extends Equatable {
  final String id;
  final String userId;
  final String? organizationName;
  final String? organizationType; // individual, company, nonprofit
  final String? bio;
  final String? websiteUrl;
  final Map<String, String>? socialLinks;

  // Verification
  final bool isVerified;
  final DateTime? verifiedAt;
  final List<String>? verificationDocuments;

  // Stats
  final int totalEventsHosted;
  final int totalTicketsSold;
  final double? averageRating;

  // Banking
  final String? stripeAccountId;
  final String? payoutMethod; // stripe, bank_transfer

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrganizerProfile({
    required this.id,
    required this.userId,
    this.organizationName,
    this.organizationType,
    this.bio,
    this.websiteUrl,
    this.socialLinks,
    this.isVerified = false,
    this.verifiedAt,
    this.verificationDocuments,
    this.totalEventsHosted = 0,
    this.totalTicketsSold = 0,
    this.averageRating,
    this.stripeAccountId,
    this.payoutMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper methods
  String get displayName => organizationName ?? 'Individual Organizer';
  bool get hasStripeAccount =>
      stripeAccountId != null && stripeAccountId!.isNotEmpty;
  bool get canReceivePayouts => hasStripeAccount && isVerified;

  @override
  List<Object?> get props => [
        id,
        userId,
        organizationName,
        organizationType,
        bio,
        websiteUrl,
        socialLinks,
        isVerified,
        verifiedAt,
        verificationDocuments,
        totalEventsHosted,
        totalTicketsSold,
        averageRating,
        stripeAccountId,
        payoutMethod,
        createdAt,
        updatedAt,
      ];
}
