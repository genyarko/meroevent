import 'package:equatable/equatable.dart';

/// Event entity representing a business event
class Event extends Equatable {
  final String id;
  final String organizerId;
  final String title;
  final String slug;
  final String? description;
  final String? shortDescription;
  final String category;
  final String? subcategory;
  final String status; // draft, published, cancelled, completed

  // Timing
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String timezone;
  final bool isRecurring;
  final Map<String, dynamic>? recurrenceRule;

  // Location
  final String? venueId;
  final bool isOnline;
  final bool isHybrid;
  final String? onlineUrl;
  final String? locationName;
  final String? address;
  final String? city;
  final String? stateProvince;
  final String country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  // Media
  final String? coverImageUrl;
  final String? thumbnailUrl;
  final List<String>? galleryImages;
  final String? videoUrl;

  // Capacity & Pricing
  final int? maxCapacity;
  final int currentAttendees;
  final double? minTicketPrice;
  final double? maxTicketPrice;
  final String currency;

  // Features
  final Map<String, dynamic>? features;
  final List<String>? tags;
  final int? ageRestriction;
  final String? dressCode;

  // SEO & Discovery
  final String? metaTitle;
  final String? metaDescription;

  // Social & Engagement
  final int viewCount;
  final int likeCount;
  final int shareCount;
  final double? averageRating;
  final int totalReviews;

  // Settings
  final bool isPrivate;
  final bool requiresApproval;
  final bool allowWaitlist;
  final bool showAttendees;
  final bool allowRefunds;
  final String? refundPolicy;
  final String? termsConditions;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  const Event({
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

  // Helper methods
  bool get isPublished => status == 'published';
  bool get isDraft => status == 'draft';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isPast => endDateTime.isBefore(DateTime.now());
  bool get isUpcoming => startDateTime.isAfter(DateTime.now());
  bool get isOngoing =>
      startDateTime.isBefore(DateTime.now()) &&
      endDateTime.isAfter(DateTime.now());
  bool get isFree => minTicketPrice == null || minTicketPrice == 0;
  bool get hasCapacity => maxCapacity == null || currentAttendees < maxCapacity!;
  bool get isSoldOut =>
      maxCapacity != null && currentAttendees >= maxCapacity!;

  // Duration
  Duration get duration => endDateTime.difference(startDateTime);

  // Days until event
  int get daysUntilEvent => startDateTime.difference(DateTime.now()).inDays;

  // Copy with method
  Event copyWith({
    String? id,
    String? organizerId,
    String? title,
    String? slug,
    String? description,
    String? shortDescription,
    String? category,
    String? subcategory,
    String? status,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? timezone,
    bool? isRecurring,
    Map<String, dynamic>? recurrenceRule,
    String? venueId,
    bool? isOnline,
    bool? isHybrid,
    String? onlineUrl,
    String? locationName,
    String? address,
    String? city,
    String? stateProvince,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? coverImageUrl,
    String? thumbnailUrl,
    List<String>? galleryImages,
    String? videoUrl,
    int? maxCapacity,
    int? currentAttendees,
    double? minTicketPrice,
    double? maxTicketPrice,
    String? currency,
    Map<String, dynamic>? features,
    List<String>? tags,
    int? ageRestriction,
    String? dressCode,
    String? metaTitle,
    String? metaDescription,
    int? viewCount,
    int? likeCount,
    int? shareCount,
    double? averageRating,
    int? totalReviews,
    bool? isPrivate,
    bool? requiresApproval,
    bool? allowWaitlist,
    bool? showAttendees,
    bool? allowRefunds,
    String? refundPolicy,
    String? termsConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return Event(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      status: status ?? this.status,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      timezone: timezone ?? this.timezone,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      venueId: venueId ?? this.venueId,
      isOnline: isOnline ?? this.isOnline,
      isHybrid: isHybrid ?? this.isHybrid,
      onlineUrl: onlineUrl ?? this.onlineUrl,
      locationName: locationName ?? this.locationName,
      address: address ?? this.address,
      city: city ?? this.city,
      stateProvince: stateProvince ?? this.stateProvince,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      videoUrl: videoUrl ?? this.videoUrl,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      minTicketPrice: minTicketPrice ?? this.minTicketPrice,
      maxTicketPrice: maxTicketPrice ?? this.maxTicketPrice,
      currency: currency ?? this.currency,
      features: features ?? this.features,
      tags: tags ?? this.tags,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      dressCode: dressCode ?? this.dressCode,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isPrivate: isPrivate ?? this.isPrivate,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      allowWaitlist: allowWaitlist ?? this.allowWaitlist,
      showAttendees: showAttendees ?? this.showAttendees,
      allowRefunds: allowRefunds ?? this.allowRefunds,
      refundPolicy: refundPolicy ?? this.refundPolicy,
      termsConditions: termsConditions ?? this.termsConditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        organizerId,
        title,
        slug,
        description,
        shortDescription,
        category,
        subcategory,
        status,
        startDateTime,
        endDateTime,
        timezone,
        isRecurring,
        recurrenceRule,
        venueId,
        isOnline,
        isHybrid,
        onlineUrl,
        locationName,
        address,
        city,
        stateProvince,
        country,
        postalCode,
        latitude,
        longitude,
        coverImageUrl,
        thumbnailUrl,
        galleryImages,
        videoUrl,
        maxCapacity,
        currentAttendees,
        minTicketPrice,
        maxTicketPrice,
        currency,
        features,
        tags,
        ageRestriction,
        dressCode,
        metaTitle,
        metaDescription,
        viewCount,
        likeCount,
        shareCount,
        averageRating,
        totalReviews,
        isPrivate,
        requiresApproval,
        allowWaitlist,
        showAttendees,
        allowRefunds,
        refundPolicy,
        termsConditions,
        createdAt,
        updatedAt,
        publishedAt,
      ];
}
