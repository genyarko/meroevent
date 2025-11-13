import 'package:equatable/equatable.dart';

/// Event entity representing a business event - matches Supabase schema
class Event extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? shortDescription;
  final String? category;
  final List<String>? tags;

  // Organizer info
  final String organizerId;
  final String? organizerName;
  final String? organizerEmail;
  final String? organizerPhone;

  // Location
  final String? location;
  final String? venue;
  final String? venueId;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  // Date and time
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String? timezone;

  // Media
  final String? imageUrl;
  final String? coverImageUrl;
  final String? videoUrl;
  final List<String>? galleryImages;

  // Ticketing
  final bool isFree;
  final double? minPrice;
  final double? maxPrice;
  final String currency;

  // Capacity
  final int? capacity;
  final int? remainingCapacity;
  final bool isSoldOut;
  final int maxTicketsPerPurchase; // Maximum tickets per purchase (default 10)

  // Status
  final String status; // draft, published, cancelled, completed
  final bool isPublished;
  final bool isFeatured;
  final bool isPrivate;

  // Additional info
  final String? ageRestriction;
  final String? dressCode;
  final String? refundPolicy;
  final String? termsAndConditions;
  final String? externalUrl;

  // Social engagement
  final int viewsCount;
  final int likesCount;
  final int sharesCount;
  final int attendeesCount;
  final int interestedCount;

  // Metadata
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? settings;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  const Event({
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
    this.maxTicketsPerPurchase = 10,
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

  // Helper methods
  bool get isDraft => status == 'draft';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isPast => endDatetime.isBefore(DateTime.now());
  bool get isUpcoming => startDatetime.isAfter(DateTime.now());
  bool get isOngoing =>
      startDatetime.isBefore(DateTime.now()) &&
      endDatetime.isAfter(DateTime.now());
  bool get hasCapacity => capacity == null || (remainingCapacity ?? 0) > 0;

  // Duration
  Duration get duration => endDatetime.difference(startDatetime);

  // Days until event
  int get daysUntilEvent => startDatetime.difference(DateTime.now()).inDays;

  // Copy with method
  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? shortDescription,
    String? category,
    List<String>? tags,
    String? organizerId,
    String? organizerName,
    String? organizerEmail,
    String? organizerPhone,
    String? location,
    String? venue,
    String? venueId,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    DateTime? startDatetime,
    DateTime? endDatetime,
    String? timezone,
    String? imageUrl,
    String? coverImageUrl,
    String? videoUrl,
    List<String>? galleryImages,
    bool? isFree,
    double? minPrice,
    double? maxPrice,
    String? currency,
    int? capacity,
    int? remainingCapacity,
    bool? isSoldOut,
    String? status,
    bool? isPublished,
    bool? isFeatured,
    bool? isPrivate,
    String? ageRestriction,
    String? dressCode,
    String? refundPolicy,
    String? termsAndConditions,
    String? externalUrl,
    int? viewsCount,
    int? likesCount,
    int? sharesCount,
    int? attendeesCount,
    int? interestedCount,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      organizerEmail: organizerEmail ?? this.organizerEmail,
      organizerPhone: organizerPhone ?? this.organizerPhone,
      location: location ?? this.location,
      venue: venue ?? this.venue,
      venueId: venueId ?? this.venueId,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startDatetime: startDatetime ?? this.startDatetime,
      endDatetime: endDatetime ?? this.endDatetime,
      timezone: timezone ?? this.timezone,
      imageUrl: imageUrl ?? this.imageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      isFree: isFree ?? this.isFree,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      currency: currency ?? this.currency,
      capacity: capacity ?? this.capacity,
      remainingCapacity: remainingCapacity ?? this.remainingCapacity,
      isSoldOut: isSoldOut ?? this.isSoldOut,
      status: status ?? this.status,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      isPrivate: isPrivate ?? this.isPrivate,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      dressCode: dressCode ?? this.dressCode,
      refundPolicy: refundPolicy ?? this.refundPolicy,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      externalUrl: externalUrl ?? this.externalUrl,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      sharesCount: sharesCount ?? this.sharesCount,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      interestedCount: interestedCount ?? this.interestedCount,
      metadata: metadata ?? this.metadata,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        shortDescription,
        category,
        tags,
        organizerId,
        organizerName,
        organizerEmail,
        organizerPhone,
        location,
        venue,
        venueId,
        address,
        city,
        state,
        country,
        postalCode,
        latitude,
        longitude,
        startDatetime,
        endDatetime,
        timezone,
        imageUrl,
        coverImageUrl,
        videoUrl,
        galleryImages,
        isFree,
        minPrice,
        maxPrice,
        currency,
        capacity,
        remainingCapacity,
        isSoldOut,
        status,
        isPublished,
        isFeatured,
        isPrivate,
        ageRestriction,
        dressCode,
        refundPolicy,
        termsAndConditions,
        externalUrl,
        viewsCount,
        likesCount,
        sharesCount,
        attendeesCount,
        interestedCount,
        metadata,
        settings,
        createdAt,
        updatedAt,
        publishedAt,
      ];
}
