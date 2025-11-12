import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';
import 'json_converters.dart';

part 'user_model.g.dart';

/// User data model for JSON serialization
/// Merged model supporting both dating app and event management app
@JsonSerializable(explicitToJson: true)
class UserModel {
  // Core Identity
  final String id;
  final String email;
  final String? phone;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? bio;
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;
  final String? gender;

  // Location (used by both apps)
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  // Dating App Specific
  @JsonKey(name: 'icebreaker_prompts')
  @IcebreakerPromptsConverter()
  final List<String>? icebreakerPrompts;
  @JsonKey(name: 'relationship_intent')
  final String? relationshipIntent;
  @JsonKey(name: 'education_level')
  final String? educationLevel;
  @JsonKey(name: 'communication_style')
  final String? communicationStyle;
  @JsonKey(name: 'lifestyle_choice')
  final String? lifestyleChoice;
  @JsonKey(name: 'lockdown_enabled', defaultValue: false)
  final bool lockdownEnabled;
  @JsonKey(name: 'image_urls')
  @ImageUrlsConverter()
  final List<String>? imageUrls;

  // Dating App - Login Streaks
  @JsonKey(name: 'last_login_date')
  final DateTime? lastLoginDate;
  @JsonKey(name: 'consecutive_login_days', defaultValue: 0)
  final int consecutiveLoginDays;
  @JsonKey(name: 'total_login_days', defaultValue: 0)
  final int totalLoginDays;
  @JsonKey(name: 'match_probability_boost', defaultValue: 1.0)
  final double matchProbabilityBoost;

  // Premium (shared)
  @JsonKey(name: 'is_premium', defaultValue: false)
  final bool isPremium;
  @JsonKey(name: 'premium_expires_at')
  final DateTime? premiumExpiresAt;

  // Event App Specific
  @InterestsConverter()
  final List<String>? interests;
  final Map<String, dynamic>? preferences;
  final String? language;
  final String? timezone;
  @JsonKey(name: 'social_links')
  final Map<String, String>? socialLinks;
  @JsonKey(name: 'karma_points', defaultValue: 0)
  final int karmaPoints;

  // Notifications (shared)
  @JsonKey(name: 'email_notifications', defaultValue: true)
  final bool emailNotifications;
  @JsonKey(name: 'push_notifications', defaultValue: true)
  final bool pushNotifications;
  @JsonKey(name: 'sms_notifications', defaultValue: false)
  final bool smsNotifications;
  @JsonKey(name: 'marketing_emails', defaultValue: true)
  final bool marketingEmails;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  // Verification
  @JsonKey(name: 'is_email_verified', defaultValue: false)
  final bool isEmailVerified;
  @JsonKey(name: 'is_phone_verified', defaultValue: false)
  final bool isPhoneVerified;
  @JsonKey(name: 'is_profile_complete', defaultValue: false)
  final bool isProfileComplete;

  // Timestamps
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;

  const UserModel({
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
    this.icebreakerPrompts,
    this.relationshipIntent,
    this.educationLevel,
    this.communicationStyle,
    this.lifestyleChoice,
    this.lockdownEnabled = false,
    this.imageUrls,
    this.lastLoginDate,
    this.consecutiveLoginDays = 0,
    this.totalLoginDays = 0,
    this.matchProbabilityBoost = 1.0,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.interests,
    this.preferences,
    this.language,
    this.timezone,
    this.socialLinks,
    this.karmaPoints = 0,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.marketingEmails = true,
    this.fcmToken,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isProfileComplete = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(
        id: id,
        email: email,
        phone: phone,
        fullName: fullName,
        avatarUrl: avatarUrl,
        bio: bio,
        dateOfBirth: dateOfBirth,
        gender: gender,
        city: city,
        country: country,
        latitude: latitude,
        longitude: longitude,
        icebreakerPrompts: icebreakerPrompts,
        relationshipIntent: relationshipIntent,
        educationLevel: educationLevel,
        communicationStyle: communicationStyle,
        lifestyleChoice: lifestyleChoice,
        lockdownEnabled: lockdownEnabled,
        imageUrls: imageUrls,
        lastLoginDate: lastLoginDate,
        consecutiveLoginDays: consecutiveLoginDays,
        totalLoginDays: totalLoginDays,
        matchProbabilityBoost: matchProbabilityBoost,
        isPremium: isPremium,
        premiumExpiresAt: premiumExpiresAt,
        interests: interests,
        preferences: preferences,
        language: language,
        timezone: timezone,
        socialLinks: socialLinks,
        karmaPoints: karmaPoints,
        emailNotifications: emailNotifications,
        pushNotifications: pushNotifications,
        smsNotifications: smsNotifications,
        marketingEmails: marketingEmails,
        fcmToken: fcmToken,
        isEmailVerified: isEmailVerified,
        isPhoneVerified: isPhoneVerified,
        isProfileComplete: isProfileComplete,
        createdAt: createdAt,
        updatedAt: updatedAt,
        lastLoginAt: lastLoginAt,
      );

  factory UserModel.fromEntity(User entity) => UserModel(
        id: entity.id,
        email: entity.email,
        phone: entity.phone,
        fullName: entity.fullName,
        avatarUrl: entity.avatarUrl,
        bio: entity.bio,
        dateOfBirth: entity.dateOfBirth,
        gender: entity.gender,
        city: entity.city,
        country: entity.country,
        latitude: entity.latitude,
        longitude: entity.longitude,
        icebreakerPrompts: entity.icebreakerPrompts,
        relationshipIntent: entity.relationshipIntent,
        educationLevel: entity.educationLevel,
        communicationStyle: entity.communicationStyle,
        lifestyleChoice: entity.lifestyleChoice,
        lockdownEnabled: entity.lockdownEnabled,
        imageUrls: entity.imageUrls,
        lastLoginDate: entity.lastLoginDate,
        consecutiveLoginDays: entity.consecutiveLoginDays,
        totalLoginDays: entity.totalLoginDays,
        matchProbabilityBoost: entity.matchProbabilityBoost,
        isPremium: entity.isPremium,
        premiumExpiresAt: entity.premiumExpiresAt,
        interests: entity.interests,
        preferences: entity.preferences,
        language: entity.language,
        timezone: entity.timezone,
        socialLinks: entity.socialLinks,
        karmaPoints: entity.karmaPoints,
        emailNotifications: entity.emailNotifications,
        pushNotifications: entity.pushNotifications,
        smsNotifications: entity.smsNotifications,
        marketingEmails: entity.marketingEmails,
        fcmToken: entity.fcmToken,
        isEmailVerified: entity.isEmailVerified,
        isPhoneVerified: entity.isPhoneVerified,
        isProfileComplete: entity.isProfileComplete,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        lastLoginAt: entity.lastLoginAt,
      );
}

/// Organizer Profile data model
@JsonSerializable(explicitToJson: true)
class OrganizerProfileModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'organization_name')
  final String? organizationName;
  @JsonKey(name: 'organization_type')
  final String? organizationType;
  final String? bio;
  @JsonKey(name: 'website_url')
  final String? websiteUrl;
  @JsonKey(name: 'social_links')
  final Map<String, String>? socialLinks;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'verified_at')
  final DateTime? verifiedAt;
  @JsonKey(name: 'verification_documents')
  final List<String>? verificationDocuments;
  @JsonKey(name: 'total_events_hosted')
  final int totalEventsHosted;
  @JsonKey(name: 'total_tickets_sold')
  final int totalTicketsSold;
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @JsonKey(name: 'stripe_account_id')
  final String? stripeAccountId;
  @JsonKey(name: 'payout_method')
  final String? payoutMethod;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const OrganizerProfileModel({
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

  factory OrganizerProfileModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizerProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizerProfileModelToJson(this);

  OrganizerProfile toEntity() => OrganizerProfile(
        id: id,
        userId: userId,
        organizationName: organizationName,
        organizationType: organizationType,
        bio: bio,
        websiteUrl: websiteUrl,
        socialLinks: socialLinks,
        isVerified: isVerified,
        verifiedAt: verifiedAt,
        verificationDocuments: verificationDocuments,
        totalEventsHosted: totalEventsHosted,
        totalTicketsSold: totalTicketsSold,
        averageRating: averageRating,
        stripeAccountId: stripeAccountId,
        payoutMethod: payoutMethod,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory OrganizerProfileModel.fromEntity(OrganizerProfile entity) =>
      OrganizerProfileModel(
        id: entity.id,
        userId: entity.userId,
        organizationName: entity.organizationName,
        organizationType: entity.organizationType,
        bio: entity.bio,
        websiteUrl: entity.websiteUrl,
        socialLinks: entity.socialLinks,
        isVerified: entity.isVerified,
        verifiedAt: entity.verifiedAt,
        verificationDocuments: entity.verificationDocuments,
        totalEventsHosted: entity.totalEventsHosted,
        totalTicketsSold: entity.totalTicketsSold,
        averageRating: entity.averageRating,
        stripeAccountId: entity.stripeAccountId,
        payoutMethod: entity.payoutMethod,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
