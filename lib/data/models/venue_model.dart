import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/venue.dart';

part 'venue_model.g.dart';

/// Venue data model for JSON serialization
@JsonSerializable(explicitToJson: true)
class VenueModel {
  final String id;
  @JsonKey(name: 'owner_id')
  final String? ownerId;
  final String name;
  final String slug;
  final String? description;
  @JsonKey(name: 'venue_type')
  final String? venueType;
  final String address;
  final String city;
  @JsonKey(name: 'state_province')
  final String? stateProvince;
  final String country;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'total_capacity')
  final int? totalCapacity;
  @JsonKey(name: 'seating_capacity')
  final int? seatingCapacity;
  @JsonKey(name: 'standing_capacity')
  final int? standingCapacity;
  final Map<String, dynamic>? amenities;
  @JsonKey(name: 'accessibility_features')
  final Map<String, dynamic>? accessibilityFeatures;
  @JsonKey(name: 'parking_info')
  final String? parkingInfo;
  @JsonKey(name: 'public_transport_info')
  final String? publicTransportInfo;
  final List<String>? images;
  @JsonKey(name: 'floor_plan_url')
  final String? floorPlanUrl;
  @JsonKey(name: 'seating_chart_url')
  final String? seatingChartUrl;
  @JsonKey(name: 'virtual_tour_url')
  final String? virtualTourUrl;
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @JsonKey(name: 'website_url')
  final String? websiteUrl;
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @JsonKey(name: 'total_reviews')
  final int totalReviews;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const VenueModel({
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

  factory VenueModel.fromJson(Map<String, dynamic> json) =>
      _$VenueModelFromJson(json);

  Map<String, dynamic> toJson() => _$VenueModelToJson(this);

  Venue toEntity() => Venue(
        id: id,
        ownerId: ownerId,
        name: name,
        slug: slug,
        description: description,
        venueType: venueType,
        address: address,
        city: city,
        stateProvince: stateProvince,
        country: country,
        postalCode: postalCode,
        latitude: latitude,
        longitude: longitude,
        totalCapacity: totalCapacity,
        seatingCapacity: seatingCapacity,
        standingCapacity: standingCapacity,
        amenities: amenities,
        accessibilityFeatures: accessibilityFeatures,
        parkingInfo: parkingInfo,
        publicTransportInfo: publicTransportInfo,
        images: images,
        floorPlanUrl: floorPlanUrl,
        seatingChartUrl: seatingChartUrl,
        virtualTourUrl: virtualTourUrl,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        websiteUrl: websiteUrl,
        averageRating: averageRating,
        totalReviews: totalReviews,
        isVerified: isVerified,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory VenueModel.fromEntity(Venue entity) => VenueModel(
        id: entity.id,
        ownerId: entity.ownerId,
        name: entity.name,
        slug: entity.slug,
        description: entity.description,
        venueType: entity.venueType,
        address: entity.address,
        city: entity.city,
        stateProvince: entity.stateProvince,
        country: entity.country,
        postalCode: entity.postalCode,
        latitude: entity.latitude,
        longitude: entity.longitude,
        totalCapacity: entity.totalCapacity,
        seatingCapacity: entity.seatingCapacity,
        standingCapacity: entity.standingCapacity,
        amenities: entity.amenities,
        accessibilityFeatures: entity.accessibilityFeatures,
        parkingInfo: entity.parkingInfo,
        publicTransportInfo: entity.publicTransportInfo,
        images: entity.images,
        floorPlanUrl: entity.floorPlanUrl,
        seatingChartUrl: entity.seatingChartUrl,
        virtualTourUrl: entity.virtualTourUrl,
        contactEmail: entity.contactEmail,
        contactPhone: entity.contactPhone,
        websiteUrl: entity.websiteUrl,
        averageRating: entity.averageRating,
        totalReviews: entity.totalReviews,
        isVerified: entity.isVerified,
        isActive: entity.isActive,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
