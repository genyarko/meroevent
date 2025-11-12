import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/event.dart';

part 'event_model.g.dart';

/// Event data model for JSON serialization
@JsonSerializable(explicitToJson: true)
class EventModel {
  final String id;
  @JsonKey(name: 'organizer_id')
  final String organizerId;
  final String title;
  final String slug;
  final String? description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  final String category;
  final String? subcategory;
  final String status;

  // Timing
  @JsonKey(name: 'start_datetime')
  final DateTime startDateTime;
  @JsonKey(name: 'end_datetime')
  final DateTime endDateTime;
  final String timezone;
  @JsonKey(name: 'is_recurring')
  final bool isRecurring;
  @JsonKey(name: 'recurrence_rule')
  final Map<String, dynamic>? recurrenceRule;

  // Location
  @JsonKey(name: 'venue_id')
  final String? venueId;
  @JsonKey(name: 'is_online')
  final bool isOnline;
  @JsonKey(name: 'is_hybrid')
  final bool isHybrid;
  @JsonKey(name: 'online_url')
  final String? onlineUrl;
  @JsonKey(name: 'location_name')
  final String? locationName;
  final String? address;
  final String? city;
  @JsonKey(name: 'state_province')
  final String? stateProvince;
  final String country;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  // Media
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'gallery_images')
  final List<String>? galleryImages;
  @JsonKey(name: 'video_url')
  final String? videoUrl;

  // Capacity & Pricing
  @JsonKey(name: 'max_capacity')
  final int? maxCapacity;
  @JsonKey(name: 'current_attendees')
  final int currentAttendees;
  @JsonKey(name: 'min_ticket_price')
  final double? minTicketPrice;
  @JsonKey(name: 'max_ticket_price')
  final double? maxTicketPrice;
  final String currency;

  // Features
  final Map<String, dynamic>? features;
  final List<String>? tags;
  @JsonKey(name: 'age_restriction')
  final int? ageRestriction;
  @JsonKey(name: 'dress_code')
  final String? dressCode;

  // SEO
  @JsonKey(name: 'meta_title')
  final String? metaTitle;
  @JsonKey(name: 'meta_description')
  final String? metaDescription;

  // Social & Engagement
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'like_count')
  final int likeCount;
  @JsonKey(name: 'share_count')
  final int shareCount;
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @JsonKey(name: 'total_reviews')
  final int totalReviews;

  // Settings
  @JsonKey(name: 'is_private')
  final bool isPrivate;
  @JsonKey(name: 'requires_approval')
  final bool requiresApproval;
  @JsonKey(name: 'allow_waitlist')
  final bool allowWaitlist;
  @JsonKey(name: 'show_attendees')
  final bool showAttendees;
  @JsonKey(name: 'allow_refunds')
  final bool allowRefunds;
  @JsonKey(name: 'refund_policy')
  final String? refundPolicy;
  @JsonKey(name: 'terms_conditions')
  final String? termsConditions;

  // Timestamps
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  const EventModel({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.slug,
    this.description,
    this.shortDescription,
    required this.category,
    this.subcategory,
    required this.status,
    required this.startDateTime,
    required this.endDateTime,
    required this.timezone,
    this.isRecurring = false,
    this.recurrenceRule,
    this.venueId,
    this.isOnline = false,
    this.isHybrid = false,
    this.onlineUrl,
    this.locationName,
    this.address,
    this.city,
    this.stateProvince,
    required this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.coverImageUrl,
    this.thumbnailUrl,
    this.galleryImages,
    this.videoUrl,
    this.maxCapacity,
    this.currentAttendees = 0,
    this.minTicketPrice,
    this.maxTicketPrice,
    this.currency = 'USD',
    this.features,
    this.tags,
    this.ageRestriction,
    this.dressCode,
    this.metaTitle,
    this.metaDescription,
    this.viewCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.averageRating,
    this.totalReviews = 0,
    this.isPrivate = false,
    this.requiresApproval = false,
    this.allowWaitlist = true,
    this.showAttendees = true,
    this.allowRefunds = true,
    this.refundPolicy,
    this.termsConditions,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  /// Convert from JSON
  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  /// Convert to domain entity
  Event toEntity() {
    return Event(
      id: id,
      organizerId: organizerId,
      title: title,
      slug: slug,
      description: description,
      shortDescription: shortDescription,
      category: category,
      subcategory: subcategory,
      status: status,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      timezone: timezone,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      venueId: venueId,
      isOnline: isOnline,
      isHybrid: isHybrid,
      onlineUrl: onlineUrl,
      locationName: locationName,
      address: address,
      city: city,
      stateProvince: stateProvince,
      country: country,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
      coverImageUrl: coverImageUrl,
      thumbnailUrl: thumbnailUrl,
      galleryImages: galleryImages,
      videoUrl: videoUrl,
      maxCapacity: maxCapacity,
      currentAttendees: currentAttendees,
      minTicketPrice: minTicketPrice,
      maxTicketPrice: maxTicketPrice,
      currency: currency,
      features: features,
      tags: tags,
      ageRestriction: ageRestriction,
      dressCode: dressCode,
      metaTitle: metaTitle,
      metaDescription: metaDescription,
      viewCount: viewCount,
      likeCount: likeCount,
      shareCount: shareCount,
      averageRating: averageRating,
      totalReviews: totalReviews,
      isPrivate: isPrivate,
      requiresApproval: requiresApproval,
      allowWaitlist: allowWaitlist,
      showAttendees: showAttendees,
      allowRefunds: allowRefunds,
      refundPolicy: refundPolicy,
      termsConditions: termsConditions,
      createdAt: createdAt,
      updatedAt: updatedAt,
      publishedAt: publishedAt,
    );
  }

  /// Create from domain entity
  factory EventModel.fromEntity(Event entity) {
    return EventModel(
      id: entity.id,
      organizerId: entity.organizerId,
      title: entity.title,
      slug: entity.slug,
      description: entity.description,
      shortDescription: entity.shortDescription,
      category: entity.category,
      subcategory: entity.subcategory,
      status: entity.status,
      startDateTime: entity.startDateTime,
      endDateTime: entity.endDateTime,
      timezone: entity.timezone,
      isRecurring: entity.isRecurring,
      recurrenceRule: entity.recurrenceRule,
      venueId: entity.venueId,
      isOnline: entity.isOnline,
      isHybrid: entity.isHybrid,
      onlineUrl: entity.onlineUrl,
      locationName: entity.locationName,
      address: entity.address,
      city: entity.city,
      stateProvince: entity.stateProvince,
      country: entity.country,
      postalCode: entity.postalCode,
      latitude: entity.latitude,
      longitude: entity.longitude,
      coverImageUrl: entity.coverImageUrl,
      thumbnailUrl: entity.thumbnailUrl,
      galleryImages: entity.galleryImages,
      videoUrl: entity.videoUrl,
      maxCapacity: entity.maxCapacity,
      currentAttendees: entity.currentAttendees,
      minTicketPrice: entity.minTicketPrice,
      maxTicketPrice: entity.maxTicketPrice,
      currency: entity.currency,
      features: entity.features,
      tags: entity.tags,
      ageRestriction: entity.ageRestriction,
      dressCode: entity.dressCode,
      metaTitle: entity.metaTitle,
      metaDescription: entity.metaDescription,
      viewCount: entity.viewCount,
      likeCount: entity.likeCount,
      shareCount: entity.shareCount,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
      isPrivate: entity.isPrivate,
      requiresApproval: entity.requiresApproval,
      allowWaitlist: entity.allowWaitlist,
      showAttendees: entity.showAttendees,
      allowRefunds: entity.allowRefunds,
      refundPolicy: entity.refundPolicy,
      termsConditions: entity.termsConditions,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      publishedAt: entity.publishedAt,
    );
  }
}
