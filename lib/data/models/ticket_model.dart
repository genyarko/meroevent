import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/ticket.dart';

part 'ticket_model.g.dart';

/// Ticket data model for JSON serialization
@JsonSerializable(explicitToJson: true)
class TicketModel {
  final String id;
  @JsonKey(name: 'ticket_number')
  final String ticketNumber;
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'ticket_type_id')
  final String ticketTypeId;
  @JsonKey(name: 'event_id')
  final String eventId;
  @JsonKey(name: 'assigned_to_id')
  final String? assignedToId;
  @JsonKey(name: 'assigned_email')
  final String? assignedEmail;
  @JsonKey(name: 'assigned_name')
  final String? assignedName;
  @JsonKey(name: 'qr_code')
  final String qrCode;
  @JsonKey(name: 'qr_code_url')
  final String? qrCodeUrl;
  @JsonKey(name: 'validation_code')
  final String? validationCode;
  @JsonKey(name: 'is_checked_in')
  final bool isCheckedIn;
  @JsonKey(name: 'checked_in_at')
  final DateTime? checkedInAt;
  @JsonKey(name: 'checked_in_by')
  final String? checkedInBy;
  @JsonKey(name: 'check_in_location')
  final String? checkInLocation;
  @JsonKey(name: 'seat_section')
  final String? seatSection;
  @JsonKey(name: 'seat_row')
  final String? seatRow;
  @JsonKey(name: 'seat_number')
  final String? seatNumber;
  final String status;
  @JsonKey(name: 'is_transferred')
  final bool isTransferred;
  @JsonKey(name: 'transferred_from')
  final String? transferredFrom;
  @JsonKey(name: 'transferred_at')
  final DateTime? transferredAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  const TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.orderId,
    required this.ticketTypeId,
    required this.eventId,
    this.assignedToId,
    this.assignedEmail,
    this.assignedName,
    required this.qrCode,
    this.qrCodeUrl,
    this.validationCode,
    this.isCheckedIn = false,
    this.checkedInAt,
    this.checkedInBy,
    this.checkInLocation,
    this.seatSection,
    this.seatRow,
    this.seatNumber,
    this.status = 'valid',
    this.isTransferred = false,
    this.transferredFrom,
    this.transferredAt,
    required this.createdAt,
    this.expiresAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketModelToJson(this);

  Ticket toEntity() => Ticket(
        id: id,
        ticketNumber: ticketNumber,
        orderId: orderId,
        ticketTypeId: ticketTypeId,
        eventId: eventId,
        assignedToId: assignedToId,
        assignedEmail: assignedEmail,
        assignedName: assignedName,
        qrCode: qrCode,
        qrCodeUrl: qrCodeUrl,
        validationCode: validationCode,
        isCheckedIn: isCheckedIn,
        checkedInAt: checkedInAt,
        checkedInBy: checkedInBy,
        checkInLocation: checkInLocation,
        seatSection: seatSection,
        seatRow: seatRow,
        seatNumber: seatNumber,
        status: status,
        isTransferred: isTransferred,
        transferredFrom: transferredFrom,
        transferredAt: transferredAt,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );

  factory TicketModel.fromEntity(Ticket entity) => TicketModel(
        id: entity.id,
        ticketNumber: entity.ticketNumber,
        orderId: entity.orderId,
        ticketTypeId: entity.ticketTypeId,
        eventId: entity.eventId,
        assignedToId: entity.assignedToId,
        assignedEmail: entity.assignedEmail,
        assignedName: entity.assignedName,
        qrCode: entity.qrCode,
        qrCodeUrl: entity.qrCodeUrl,
        validationCode: entity.validationCode,
        isCheckedIn: entity.isCheckedIn,
        checkedInAt: entity.checkedInAt,
        checkedInBy: entity.checkedInBy,
        checkInLocation: entity.checkInLocation,
        seatSection: entity.seatSection,
        seatRow: entity.seatRow,
        seatNumber: entity.seatNumber,
        status: entity.status,
        isTransferred: entity.isTransferred,
        transferredFrom: entity.transferredFrom,
        transferredAt: entity.transferredAt,
        createdAt: entity.createdAt,
        expiresAt: entity.expiresAt,
      );
}

/// Ticket Type data model
@JsonSerializable(explicitToJson: true)
class TicketTypeModel {
  final String id;
  @JsonKey(name: 'event_id')
  final String eventId;
  final String name;
  final String? description;
  final double price;
  @JsonKey(name: 'total_quantity')
  final int totalQuantity;
  @JsonKey(name: 'available_quantity')
  final int availableQuantity;
  @JsonKey(name: 'min_purchase')
  final int minPurchase;
  @JsonKey(name: 'max_purchase')
  final int maxPurchase;
  @JsonKey(name: 'sale_start_date')
  final DateTime? saleStartDate;
  @JsonKey(name: 'sale_end_date')
  final DateTime? saleEndDate;
  @JsonKey(name: 'includes_perks')
  final Map<String, dynamic>? includesPerks;
  @JsonKey(name: 'is_transferable')
  final bool isTransferable;
  @JsonKey(name: 'is_refundable')
  final bool isRefundable;
  @JsonKey(name: 'requires_approval')
  final bool requiresApproval;
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @JsonKey(name: 'color_code')
  final String? colorCode;
  final String? icon;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const TicketTypeModel({
    required this.id,
    required this.eventId,
    required this.name,
    this.description,
    required this.price,
    required this.totalQuantity,
    required this.availableQuantity,
    this.minPurchase = 1,
    this.maxPurchase = 10,
    this.saleStartDate,
    this.saleEndDate,
    this.includesPerks,
    this.isTransferable = true,
    this.isRefundable = true,
    this.requiresApproval = false,
    this.displayOrder = 0,
    this.colorCode,
    this.icon,
    this.status = 'active',
    required this.createdAt,
  });

  factory TicketTypeModel.fromJson(Map<String, dynamic> json) =>
      _$TicketTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketTypeModelToJson(this);

  TicketType toEntity() => TicketType(
        id: id,
        eventId: eventId,
        name: name,
        description: description,
        price: price,
        totalQuantity: totalQuantity,
        availableQuantity: availableQuantity,
        minPurchase: minPurchase,
        maxPurchase: maxPurchase,
        saleStartDate: saleStartDate,
        saleEndDate: saleEndDate,
        includesPerks: includesPerks,
        isTransferable: isTransferable,
        isRefundable: isRefundable,
        requiresApproval: requiresApproval,
        displayOrder: displayOrder,
        colorCode: colorCode,
        icon: icon,
        status: status,
        createdAt: createdAt,
      );

  factory TicketTypeModel.fromEntity(TicketType entity) => TicketTypeModel(
        id: entity.id,
        eventId: entity.eventId,
        name: entity.name,
        description: entity.description,
        price: entity.price,
        totalQuantity: entity.totalQuantity,
        availableQuantity: entity.availableQuantity,
        minPurchase: entity.minPurchase,
        maxPurchase: entity.maxPurchase,
        saleStartDate: entity.saleStartDate,
        saleEndDate: entity.saleEndDate,
        includesPerks: entity.includesPerks,
        isTransferable: entity.isTransferable,
        isRefundable: entity.isRefundable,
        requiresApproval: entity.requiresApproval,
        displayOrder: entity.displayOrder,
        colorCode: entity.colorCode,
        icon: entity.icon,
        status: entity.status,
        createdAt: entity.createdAt,
      );
}

/// Ticket Order data model
@JsonSerializable(explicitToJson: true)
class TicketOrderModel {
  final String id;
  @JsonKey(name: 'order_number')
  final String orderNumber;
  @JsonKey(name: 'event_id')
  final String eventId;
  @JsonKey(name: 'buyer_id')
  final String buyerId;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @JsonKey(name: 'stripe_payment_intent_id')
  final String? stripePaymentIntentId;
  @JsonKey(name: 'karma_used')
  final int karmaUsed;
  final double subtotal;
  @JsonKey(name: 'tax_amount')
  final double taxAmount;
  @JsonKey(name: 'service_fee')
  final double serviceFee;
  @JsonKey(name: 'discount_amount')
  final double discountAmount;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  final String currency;
  @JsonKey(name: 'promo_code')
  final String? promoCode;
  @JsonKey(name: 'discount_id')
  final String? discountId;
  final String status;
  @JsonKey(name: 'confirmation_code')
  final String? confirmationCode;
  @JsonKey(name: 'buyer_email')
  final String buyerEmail;
  @JsonKey(name: 'buyer_phone')
  final String? buyerPhone;
  @JsonKey(name: 'billing_address')
  final Map<String, dynamic>? billingAddress;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  @JsonKey(name: 'refunded_at')
  final DateTime? refundedAt;

  const TicketOrderModel({
    required this.id,
    required this.orderNumber,
    required this.eventId,
    required this.buyerId,
    this.paymentMethod,
    this.paymentStatus = 'pending',
    this.stripePaymentIntentId,
    this.karmaUsed = 0,
    required this.subtotal,
    this.taxAmount = 0,
    this.serviceFee = 0,
    this.discountAmount = 0,
    required this.totalAmount,
    this.currency = 'USD',
    this.promoCode,
    this.discountId,
    this.status = 'pending',
    this.confirmationCode,
    required this.buyerEmail,
    this.buyerPhone,
    this.billingAddress,
    this.notes,
    required this.createdAt,
    this.completedAt,
    this.cancelledAt,
    this.refundedAt,
  });

  factory TicketOrderModel.fromJson(Map<String, dynamic> json) =>
      _$TicketOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketOrderModelToJson(this);

  TicketOrder toEntity() => TicketOrder(
        id: id,
        orderNumber: orderNumber,
        eventId: eventId,
        buyerId: buyerId,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        stripePaymentIntentId: stripePaymentIntentId,
        karmaUsed: karmaUsed,
        subtotal: subtotal,
        taxAmount: taxAmount,
        serviceFee: serviceFee,
        discountAmount: discountAmount,
        totalAmount: totalAmount,
        currency: currency,
        promoCode: promoCode,
        discountId: discountId,
        status: status,
        confirmationCode: confirmationCode,
        buyerEmail: buyerEmail,
        buyerPhone: buyerPhone,
        billingAddress: billingAddress,
        notes: notes,
        createdAt: createdAt,
        completedAt: completedAt,
        cancelledAt: cancelledAt,
        refundedAt: refundedAt,
      );

  factory TicketOrderModel.fromEntity(TicketOrder entity) => TicketOrderModel(
        id: entity.id,
        orderNumber: entity.orderNumber,
        eventId: entity.eventId,
        buyerId: entity.buyerId,
        paymentMethod: entity.paymentMethod,
        paymentStatus: entity.paymentStatus,
        stripePaymentIntentId: entity.stripePaymentIntentId,
        karmaUsed: entity.karmaUsed,
        subtotal: entity.subtotal,
        taxAmount: entity.taxAmount,
        serviceFee: entity.serviceFee,
        discountAmount: entity.discountAmount,
        totalAmount: entity.totalAmount,
        currency: entity.currency,
        promoCode: entity.promoCode,
        discountId: entity.discountId,
        status: entity.status,
        confirmationCode: entity.confirmationCode,
        buyerEmail: entity.buyerEmail,
        buyerPhone: entity.buyerPhone,
        billingAddress: entity.billingAddress,
        notes: entity.notes,
        createdAt: entity.createdAt,
        completedAt: entity.completedAt,
        cancelledAt: entity.cancelledAt,
        refundedAt: entity.refundedAt,
      );
}
