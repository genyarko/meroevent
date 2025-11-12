import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/event_model.dart';

/// Remote data source for event operations with Supabase
abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents({
    String? category,
    String? search,
    String? status,
    double? latitude,
    double? longitude,
    int? radiusKm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  Future<EventModel> getEventById(String id);
  Future<EventModel> getEventBySlug(String slug);
  Future<List<EventModel>> getEventsByOrganizer(
    String organizerId, {
    String? status,
    int? limit,
    int? offset,
  });
  Future<List<EventModel>> getNearbyEvents({
    required double latitude,
    required double longitude,
    int radiusKm = 10,
    int? limit,
  });
  Future<List<EventModel>> getFeaturedEvents({int? limit});
  Future<EventModel> createEvent(EventModel event);
  Future<EventModel> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);
  Future<void> incrementViewCount(String id);
  Future<void> incrementShareCount(String id);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final SupabaseClient _client;

  EventRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  @override
  Future<List<EventModel>> getEvents({
    String? category,
    String? search,
    String? status,
    double? latitude,
    double? longitude,
    int? radiusKm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client
          .from('events')
          .select('*')
          .order('start_datetime', ascending: true);

      // Apply filters
      if (category != null) {
        query = query.eq('category', category);
      }

      if (status != null) {
        query = query.eq('status', status);
      } else {
        // Default to published events only
        query = query.eq('status', 'published');
      }

      if (search != null && search.isNotEmpty) {
        query = query.textSearch('search_vector', search);
      }

      if (startDate != null) {
        query = query.gte('start_datetime', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('end_datetime', endDate.toIso8601String());
      }

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventModel> getEventById(String id) async {
    try {
      final response = await _client
          .from('events')
          .select('*')
          .eq('id', id)
          .single();

      return EventModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException(message: 'Event not found');
      }
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventModel> getEventBySlug(String slug) async {
    try {
      final response = await _client
          .from('events')
          .select('*')
          .eq('slug', slug)
          .eq('status', 'published')
          .single();

      return EventModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException(message: 'Event not found');
      }
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<EventModel>> getEventsByOrganizer(
    String organizerId, {
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client
          .from('events')
          .select('*')
          .eq('organizer_id', organizerId)
          .order('created_at', ascending: false);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<EventModel>> getNearbyEvents({
    required double latitude,
    required double longitude,
    int radiusKm = 10,
    int? limit,
  }) async {
    try {
      // Use PostGIS function for nearby events
      final response = await _client.rpc('nearby_events', params: {
        'lat': latitude,
        'lng': longitude,
        'radius_km': radiusKm,
        'result_limit': limit ?? 20,
      });

      return (response as List)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<EventModel>> getFeaturedEvents({int? limit}) async {
    try {
      final response = await _client
          .from('events')
          .select('*')
          .eq('status', 'published')
          .order('view_count', ascending: false)
          .order('like_count', ascending: false)
          .limit(limit ?? 10);

      return (response as List)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    try {
      final response = await _client
          .from('events')
          .insert(event.toJson())
          .select()
          .single();

      return EventModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    try {
      final response = await _client
          .from('events')
          .update(event.toJson())
          .eq('id', event.id)
          .select()
          .single();

      return EventModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await _client.from('events').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> incrementViewCount(String id) async {
    try {
      await _client.rpc('increment_view_count', params: {'event_id': id});
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> incrementShareCount(String id) async {
    try {
      await _client.rpc('increment_share_count', params: {'event_id': id});
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
