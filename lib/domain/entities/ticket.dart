import 'package:equatable/equatable.dart';

/// Ticket entity representing an individual ticket
class Ticket extends Equatable {
  final String id;
  final String ticketNumber;
  final String orderId;
  final String ticketTypeId;
  final String eventId;

  // Assignment
  final String? assignedToId;
  final String? assignedEmail;
  final String? assignedName;

  // QR Code & Validation
  final String qrCode;
  final String? qrCodeUrl;
  final String? validationCode;

  // Check-in
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final String? checkedInBy;
  final String? checkInLocation;

  // Seat (if applicable)
  final String? seatSection;
  final String? seatRow;
  final String? seatNumber;

  // Status
  final String status; // valid, used, cancelled, transferred
  final bool isTransferred;
  final String? transferredFrom;
  final DateTime? transferredAt;

  // Timestamps
  final DateTime createdAt;
  final DateTime? expiresAt;

  const Ticket({
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

  // Helper methods
  bool get isValid => status == 'valid' && !isCheckedIn;
  bool get isUsed => status == 'used' || isCheckedIn;
  bool get isCancelled => status == 'cancelled';
  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get hasSeating =>
      seatSection != null || seatRow != null || seatNumber != null;
  String? get fullSeatInfo =>
      hasSeating ? '$seatSection-$seatRow-$seatNumber' : null;

  // Copy with method
  Ticket copyWith({
    String? id,
    String? ticketNumber,
    String? orderId,
    String? ticketTypeId,
    String? eventId,
    String? assignedToId,
    String? assignedEmail,
    String? assignedName,
    String? qrCode,
    String? qrCodeUrl,
    String? validationCode,
    bool? isCheckedIn,
    DateTime? checkedInAt,
    String? checkedInBy,
    String? checkInLocation,
    String? seatSection,
    String? seatRow,
    String? seatNumber,
    String? status,
    bool? isTransferred,
    String? transferredFrom,
    DateTime? transferredAt,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      orderId: orderId ?? this.orderId,
      ticketTypeId: ticketTypeId ?? this.ticketTypeId,
      eventId: eventId ?? this.eventId,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedEmail: assignedEmail ?? this.assignedEmail,
      assignedName: assignedName ?? this.assignedName,
      qrCode: qrCode ?? this.qrCode,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      validationCode: validationCode ?? this.validationCode,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedInBy: checkedInBy ?? this.checkedInBy,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      seatSection: seatSection ?? this.seatSection,
      seatRow: seatRow ?? this.seatRow,
      seatNumber: seatNumber ?? this.seatNumber,
      status: status ?? this.status,
      isTransferred: isTransferred ?? this.isTransferred,
      transferredFrom: transferredFrom ?? this.transferredFrom,
      transferredAt: transferredAt ?? this.transferredAt,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ticketNumber,
        orderId,
        ticketTypeId,
        eventId,
        assignedToId,
        assignedEmail,
        assignedName,
        qrCode,
        qrCodeUrl,
        validationCode,
        isCheckedIn,
        checkedInAt,
        checkedInBy,
        checkInLocation,
        seatSection,
        seatRow,
        seatNumber,
        status,
        isTransferred,
        transferredFrom,
        transferredAt,
        createdAt,
        expiresAt,
      ];
}

/// Ticket Type entity representing a ticket category
class TicketType extends Equatable {
  final String id;
  final String eventId;
  final String name;
  final String? description;
  final double price;

  // Inventory
  final int totalQuantity;
  final int availableQuantity;
  final int minPurchase;
  final int maxPurchase;

  // Timing
  final DateTime? saleStartDate;
  final DateTime? saleEndDate;

  // Features
  final Map<String, dynamic>? includesPerks;
  final bool isTransferable;
  final bool isRefundable;
  final bool requiresApproval;

  // Display
  final int displayOrder;
  final String? colorCode;
  final String? icon;

  // Status
  final String status; // active, sold_out, hidden
  final DateTime createdAt;

  const TicketType({
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

  // Helper methods
  bool get isActive => status == 'active';
  bool get isSoldOut => status == 'sold_out' || availableQuantity <= 0;
  bool get isHidden => status == 'hidden';
  bool get isFree => price == 0;
  bool get isOnSale {
    final now = DateTime.now();
    if (saleStartDate != null && now.isBefore(saleStartDate!)) return false;
    if (saleEndDate != null && now.isAfter(saleEndDate!)) return false;
    return true;
  }

  int get soldQuantity => totalQuantity - availableQuantity;
  double get percentageSold =>
      totalQuantity > 0 ? (soldQuantity / totalQuantity) * 100 : 0;

  // Copy with method
  TicketType copyWith({
    String? id,
    String? eventId,
    String? name,
    String? description,
    double? price,
    int? totalQuantity,
    int? availableQuantity,
    int? minPurchase,
    int? maxPurchase,
    DateTime? saleStartDate,
    DateTime? saleEndDate,
    Map<String, dynamic>? includesPerks,
    bool? isTransferable,
    bool? isRefundable,
    bool? requiresApproval,
    int? displayOrder,
    String? colorCode,
    String? icon,
    String? status,
    DateTime? createdAt,
  }) {
    return TicketType(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      minPurchase: minPurchase ?? this.minPurchase,
      maxPurchase: maxPurchase ?? this.maxPurchase,
      saleStartDate: saleStartDate ?? this.saleStartDate,
      saleEndDate: saleEndDate ?? this.saleEndDate,
      includesPerks: includesPerks ?? this.includesPerks,
      isTransferable: isTransferable ?? this.isTransferable,
      isRefundable: isRefundable ?? this.isRefundable,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      displayOrder: displayOrder ?? this.displayOrder,
      colorCode: colorCode ?? this.colorCode,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        name,
        description,
        price,
        totalQuantity,
        availableQuantity,
        minPurchase,
        maxPurchase,
        saleStartDate,
        saleEndDate,
        includesPerks,
        isTransferable,
        isRefundable,
        requiresApproval,
        displayOrder,
        colorCode,
        icon,
        status,
        createdAt,
      ];
}

/// Ticket Order entity representing a purchase transaction
class TicketOrder extends Equatable {
  final String id;
  final String orderNumber;
  final String eventId;
  final String buyerId;

  // Payment
  final String? paymentMethod; // card, karma, mixed
  final String paymentStatus; // pending, processing, completed, failed, refunded
  final String? stripePaymentIntentId;
  final int karmaUsed;

  // Amounts
  final double subtotal;
  final double taxAmount;
  final double serviceFee;
  final double discountAmount;
  final double totalAmount;
  final String currency;

  // Discount
  final String? promoCode;
  final String? discountId;

  // Status
  final String status; // pending, confirmed, cancelled, refunded
  final String? confirmationCode;

  // Metadata
  final String buyerEmail;
  final String? buyerPhone;
  final Map<String, dynamic>? billingAddress;
  final String? notes;

  // Timestamps
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? refundedAt;

  const TicketOrder({
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

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';
  bool get isPaymentCompleted => paymentStatus == 'completed';
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentFailed => paymentStatus == 'failed';
  bool get hasDiscount => discountAmount > 0;
  bool get usedKarma => karmaUsed > 0;

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        eventId,
        buyerId,
        paymentMethod,
        paymentStatus,
        stripePaymentIntentId,
        karmaUsed,
        subtotal,
        taxAmount,
        serviceFee,
        discountAmount,
        totalAmount,
        currency,
        promoCode,
        discountId,
        status,
        confirmationCode,
        buyerEmail,
        buyerPhone,
        billingAddress,
        notes,
        createdAt,
        completedAt,
        cancelledAt,
        refundedAt,
      ];
}
