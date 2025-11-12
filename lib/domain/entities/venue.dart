import 'package:equatable/equatable.dart';

/// Venue entity representing an event location
class Venue extends Equatable {
  final String id;
  final String? ownerId;
  final String name;
  final String slug;
  final String? description;
  final String? venueType; // stadium, theater, conference_center, etc.

  // Location
  final String address;
  final String city;
  final String? stateProvince;
  final String country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  // Capacity
  final int? totalCapacity;
  final int? seatingCapacity;
  final int? standingCapacity;

  // Features
  final Map<String, dynamic>? amenities;
  final Map<String, dynamic>? accessibilityFeatures;
  final String? parkingInfo;
  final String? publicTransportInfo;

  // Media
  final List<String>? images;
  final String? floorPlanUrl;
  final String? seatingChartUrl;
  final String? virtualTourUrl;

  // Contact
  final String? contactEmail;
  final String? contactPhone;
  final String? websiteUrl;

  // Ratings
  final double? averageRating;
  final int totalReviews;

  // Status
  final bool isVerified;
  final bool isActive;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const Venue({
    required this.id,
    this.ownerId,
    required this.name,
    required this.slug,
    this.description,
    this.venueType,
    required this.address,
    required this.city,
    this.stateProvince,
    required this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.totalCapacity,
    this.seatingCapacity,
    this.standingCapacity,
    this.amenities,
    this.accessibilityFeatures,
    this.parkingInfo,
    this.publicTransportInfo,
    this.images,
    this.floorPlanUrl,
    this.seatingChartUrl,
    this.virtualTourUrl,
    this.contactEmail,
    this.contactPhone,
    this.websiteUrl,
    this.averageRating,
    this.totalReviews = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper methods
  String get fullAddress {
    final parts = <String>[
      address,
      city,
      if (stateProvince != null) stateProvince!,
      if (postalCode != null) postalCode!,
      country,
    ];
    return parts.join(', ');
  }

  bool get hasImages => images != null && images!.isNotEmpty;
  bool get hasSeatingChart => seatingChartUrl != null;
  bool get hasFloorPlan => floorPlanUrl != null;
  bool get hasVirtualTour => virtualTourUrl != null;
  bool get hasLocation => latitude != null && longitude != null;
  bool get hasCapacityInfo =>
      totalCapacity != null ||
      seatingCapacity != null ||
      standingCapacity != null;

  // Copy with method
  Venue copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? slug,
    String? description,
    String? venueType,
    String? address,
    String? city,
    String? stateProvince,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    int? totalCapacity,
    int? seatingCapacity,
    int? standingCapacity,
    Map<String, dynamic>? amenities,
    Map<String, dynamic>? accessibilityFeatures,
    String? parkingInfo,
    String? publicTransportInfo,
    List<String>? images,
    String? floorPlanUrl,
    String? seatingChartUrl,
    String? virtualTourUrl,
    String? contactEmail,
    String? contactPhone,
    String? websiteUrl,
    double? averageRating,
    int? totalReviews,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Venue(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      venueType: venueType ?? this.venueType,
      address: address ?? this.address,
      city: city ?? this.city,
      stateProvince: stateProvince ?? this.stateProvince,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      seatingCapacity: seatingCapacity ?? this.seatingCapacity,
      standingCapacity: standingCapacity ?? this.standingCapacity,
      amenities: amenities ?? this.amenities,
      accessibilityFeatures:
          accessibilityFeatures ?? this.accessibilityFeatures,
      parkingInfo: parkingInfo ?? this.parkingInfo,
      publicTransportInfo: publicTransportInfo ?? this.publicTransportInfo,
      images: images ?? this.images,
      floorPlanUrl: floorPlanUrl ?? this.floorPlanUrl,
      seatingChartUrl: seatingChartUrl ?? this.seatingChartUrl,
      virtualTourUrl: virtualTourUrl ?? this.virtualTourUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        slug,
        description,
        venueType,
        address,
        city,
        stateProvince,
        country,
        postalCode,
        latitude,
        longitude,
        totalCapacity,
        seatingCapacity,
        standingCapacity,
        amenities,
        accessibilityFeatures,
        parkingInfo,
        publicTransportInfo,
        images,
        floorPlanUrl,
        seatingChartUrl,
        virtualTourUrl,
        contactEmail,
        contactPhone,
        websiteUrl,
        averageRating,
        totalReviews,
        isVerified,
        isActive,
        createdAt,
        updatedAt,
      ];
}
