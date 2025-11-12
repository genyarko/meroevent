import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/event.dart';

part 'event_model.g.dart';

/// Event data model for JSON serialization - matches Supabase schema
@JsonSerializable(explicitToJson: true)
class EventModel {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  final String? category;
  final List<String>? tags;

  // Organizer info
  @JsonKey(name: 'organizer_id')
  final String organizerId;
  @JsonKey(name: 'organizer_name')
  final String? organizerName;
  @JsonKey(name: 'organizer_email')
  final String? organizerEmail;
  @JsonKey(name: 'organizer_phone')
  final String? organizerPhone;

  // Location
  final String? location;
  final String? venue;
  @JsonKey(name: 'venue_id')
  final String? venueId;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  // Date and time
  @JsonKey(name: 'start_datetime')
  final DateTime startDatetime;
  @JsonKey(name: 'end_datetime')
  final DateTime endDatetime;
  final String? timezone;

  // Media
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'gallery_images')
  final List<String>? galleryImages;

  // Ticketing
  @JsonKey(name: 'is_free')
  final bool isFree;
  @JsonKey(name: 'min_price')
  final double? minPrice;
  @JsonKey(name: 'max_price')
  final double? maxPrice;
  final String currency;

  // Capacity
  final int? capacity;
  @JsonKey(name: 'remaining_capacity')
  final int? remainingCapacity;
  @JsonKey(name: 'is_sold_out')
  final bool isSoldOut;

  // Status
  final String status;
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'is_private')
  final bool isPrivate;

  // Additional info
  @JsonKey(name: 'age_restriction')
  final String? ageRestriction;
  @JsonKey(name: 'dress_code')
  final String? dressCode;
  @JsonKey(name: 'refund_policy')
  final String? refundPolicy;
  @JsonKey(name: 'terms_and_conditions')
  final String? termsAndConditions;
  @JsonKey(name: 'external_url')
  final String? externalUrl;

  // Social engagement
  @JsonKey(name: 'views_count')
  final int viewsCount;
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'shares_count')
  final int sharesCount;
  @JsonKey(name: 'attendees_count')
  final int attendeesCount;
  @JsonKey(name: 'interested_count')
  final int interestedCount;

  // Metadata
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? settings;

  // Timestamps
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    this.shortDescription,
    this.category,
    this.tags,
    required this.organizerId,
    this.organizerName,
    this.organizerEmail,
    this.organizerPhone,
    this.location,
    this.venue,
    this.venueId,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    required this.startDatetime,
    required this.endDatetime,
    this.timezone,
    this.imageUrl,
    this.coverImageUrl,
    this.videoUrl,
    this.galleryImages,
    this.isFree = false,
    this.minPrice,
    this.maxPrice,
    this.currency = 'USD',
    this.capacity,
    this.remainingCapacity,
    this.isSoldOut = false,
    required this.status,
    this.isPublished = false,
    this.isFeatured = false,
    this.isPrivate = false,
    this.ageRestriction,
    this.dressCode,
    this.refundPolicy,
    this.termsAndConditions,
    this.externalUrl,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.sharesCount = 0,
    this.attendeesCount = 0,
    this.interestedCount = 0,
    this.metadata,
    this.settings,
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
      title: title,
      description: description,
      shortDescription: shortDescription,
      category: category,
      tags: tags,
      organizerId: organizerId,
      organizerName: organizerName,
      organizerEmail: organizerEmail,
      organizerPhone: organizerPhone,
      location: location,
      venue: venue,
      venueId: venueId,
      address: address,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
      startDatetime: startDatetime,
      endDatetime: endDatetime,
      timezone: timezone,
      imageUrl: imageUrl,
      coverImageUrl: coverImageUrl,
      videoUrl: videoUrl,
      galleryImages: galleryImages,
      isFree: isFree,
      minPrice: minPrice,
      maxPrice: maxPrice,
      currency: currency,
      capacity: capacity,
      remainingCapacity: remainingCapacity,
      isSoldOut: isSoldOut,
      status: status,
      isPublished: isPublished,
      isFeatured: isFeatured,
      isPrivate: isPrivate,
      ageRestriction: ageRestriction,
      dressCode: dressCode,
      refundPolicy: refundPolicy,
      termsAndConditions: termsAndConditions,
      externalUrl: externalUrl,
      viewsCount: viewsCount,
      likesCount: likesCount,
      sharesCount: sharesCount,
      attendeesCount: attendeesCount,
      interestedCount: interestedCount,
      metadata: metadata,
      settings: settings,
      createdAt: createdAt,
      updatedAt: updatedAt,
      publishedAt: publishedAt,
    );
  }

  /// Create from domain entity
  factory EventModel.fromEntity(Event entity) {
    return EventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      shortDescription: entity.shortDescription,
      category: entity.category,
      tags: entity.tags,
      organizerId: entity.organizerId,
      organizerName: entity.organizerName,
      organizerEmail: entity.organizerEmail,
      organizerPhone: entity.organizerPhone,
      location: entity.location,
      venue: entity.venue,
      venueId: entity.venueId,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      postalCode: entity.postalCode,
      latitude: entity.latitude,
      longitude: entity.longitude,
      startDatetime: entity.startDatetime,
      endDatetime: entity.endDatetime,
      timezone: entity.timezone,
      imageUrl: entity.imageUrl,
      coverImageUrl: entity.coverImageUrl,
      videoUrl: entity.videoUrl,
      galleryImages: entity.galleryImages,
      isFree: entity.isFree,
      minPrice: entity.minPrice,
      maxPrice: entity.maxPrice,
      currency: entity.currency,
      capacity: entity.capacity,
      remainingCapacity: entity.remainingCapacity,
      isSoldOut: entity.isSoldOut,
      status: entity.status,
      isPublished: entity.isPublished,
      isFeatured: entity.isFeatured,
      isPrivate: entity.isPrivate,
      ageRestriction: entity.ageRestriction,
      dressCode: entity.dressCode,
      refundPolicy: entity.refundPolicy,
      termsAndConditions: entity.termsAndConditions,
      externalUrl: entity.externalUrl,
      viewsCount: entity.viewsCount,
      likesCount: entity.likesCount,
      sharesCount: entity.sharesCount,
      attendeesCount: entity.attendeesCount,
      interestedCount: entity.interestedCount,
      metadata: entity.metadata,
      settings: entity.settings,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      publishedAt: entity.publishedAt,
    );
  }
}
