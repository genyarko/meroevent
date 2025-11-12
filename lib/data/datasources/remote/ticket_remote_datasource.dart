import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/ticket_model.dart';

/// Remote data source for ticket operations with Supabase
abstract class TicketRemoteDataSource {
  Future<List<TicketTypeModel>> getTicketTypes(String eventId);
  Future<TicketTypeModel> getTicketType(String id);
  Future<TicketTypeModel> createTicketType(TicketTypeModel ticketType);
  Future<TicketTypeModel> updateTicketType(TicketTypeModel ticketType);
  Future<void> deleteTicketType(String id);

  Future<TicketOrderModel> createOrder(TicketOrderModel order);
  Future<TicketOrderModel> getOrder(String orderId);
  Future<List<TicketOrderModel>> getOrdersByUser(String userId);
  Future<void> updateOrderStatus(String orderId, String status);

  Future<List<TicketModel>> getOrderTickets(String orderId);
  Future<List<TicketModel>> getUserTickets(String userId);
  Future<TicketModel> getTicket(String ticketId);
  Future<TicketModel> getTicketByQRCode(String qrCode);
  Future<TicketModel> checkInTicket(String ticketId, String validatorId, String? location);
  Future<TicketModel> transferTicket(String ticketId, String toUserId, String toEmail);
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final SupabaseClient _client;

  TicketRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  @override
  Future<List<TicketTypeModel>> getTicketTypes(String eventId) async {
    try {
      final response = await _client
          .from('ticket_types')
          .select('*')
          .eq('event_id', eventId)
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => TicketTypeModel.fromJson(json as Map<String, dynamic>))
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
  Future<TicketTypeModel> getTicketType(String id) async {
    try {
      final response = await _client
          .from('ticket_types')
          .select('*')
          .eq('id', id)
          .single();

      return TicketTypeModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException(message: 'Ticket type not found');
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
  Future<TicketTypeModel> createTicketType(TicketTypeModel ticketType) async {
    try {
      final response = await _client
          .from('ticket_types')
          .insert(ticketType.toJson())
          .select()
          .single();

      return TicketTypeModel.fromJson(response);
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
  Future<TicketTypeModel> updateTicketType(TicketTypeModel ticketType) async {
    try {
      final response = await _client
          .from('ticket_types')
          .update(ticketType.toJson())
          .eq('id', ticketType.id)
          .select()
          .single();

      return TicketTypeModel.fromJson(response);
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
  Future<void> deleteTicketType(String id) async {
    try {
      await _client.from('ticket_types').delete().eq('id', id);
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
  Future<TicketOrderModel> createOrder(TicketOrderModel order) async {
    try {
      final response = await _client
          .from('ticket_orders')
          .insert(order.toJson())
          .select()
          .single();

      return TicketOrderModel.fromJson(response);
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
  Future<TicketOrderModel> getOrder(String orderId) async {
    try {
      final response = await _client
          .from('ticket_orders')
          .select('*')
          .eq('id', orderId)
          .single();

      return TicketOrderModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException(message: 'Order not found');
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
  Future<List<TicketOrderModel>> getOrdersByUser(String userId) async {
    try {
      final response = await _client
          .from('ticket_orders')
          .select('*')
          .eq('buyer_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TicketOrderModel.fromJson(json as Map<String, dynamic>))
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
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _client
          .from('ticket_orders')
          .update({'status': status})
          .eq('id', orderId);
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
  Future<List<TicketModel>> getOrderTickets(String orderId) async {
    try {
      final response = await _client
          .from('tickets')
          .select('*')
          .eq('order_id', orderId);

      return (response as List)
          .map((json) => TicketModel.fromJson(json as Map<String, dynamic>))
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
  Future<List<TicketModel>> getUserTickets(String userId) async {
    try {
      final response = await _client
          .from('tickets')
          .select('*')
          .eq('assigned_to_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TicketModel.fromJson(json as Map<String, dynamic>))
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
  Future<TicketModel> getTicket(String ticketId) async {
    try {
      final response = await _client
          .from('tickets')
          .select('*')
          .eq('id', ticketId)
          .single();

      return TicketModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException(message: 'Ticket not found');
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
  Future<TicketModel> getTicketByQRCode(String qrCode) async {
    try {
      final response = await _client
          .from('tickets')
          .select('*')
          .eq('qr_code', qrCode)
          .single();

      return TicketModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException(message: 'Ticket not found');
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
  Future<TicketModel> checkInTicket(
    String ticketId,
    String validatorId,
    String? location,
  ) async {
    try {
      final response = await _client
          .from('tickets')
          .update({
            'is_checked_in': true,
            'checked_in_at': DateTime.now().toIso8601String(),
            'checked_in_by': validatorId,
            'check_in_location': location,
            'status': 'used',
          })
          .eq('id', ticketId)
          .select()
          .single();

      return TicketModel.fromJson(response);
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
  Future<TicketModel> transferTicket(
    String ticketId,
    String toUserId,
    String toEmail,
  ) async {
    try {
      final response = await _client
          .from('tickets')
          .update({
            'assigned_to_id': toUserId,
            'assigned_email': toEmail,
            'is_transferred': true,
            'transferred_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ticketId)
          .select()
          .single();

      return TicketModel.fromJson(response);
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
