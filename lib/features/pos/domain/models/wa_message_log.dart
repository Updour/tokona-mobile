class WaMessageLog {
  final String id;
  final String recipientName;
  final String phone;
  final String category; // 'booking', 'kasbon', 'order', 'manual'
  final String message;
  final String status; // 'sent', 'pending', 'failed'
  final String? errorReason;
  final String? referenceId;
  final DateTime createdAt;
  final DateTime? sentAt;

  const WaMessageLog({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.category,
    required this.message,
    required this.status,
    this.errorReason,
    this.referenceId,
    required this.createdAt,
    this.sentAt,
  });

  bool get isSent => status == 'sent';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';

  String get categoryLabel {
    switch (category) {
      case 'booking':
        return 'Booking';
      case 'kasbon':
        return 'Kasbon';
      case 'order':
        return 'Order Beli';
      default:
        return 'Manual';
    }
  }

  WaMessageLog copyWith({
    String? status,
    String? errorReason,
    DateTime? sentAt,
    String? message,
    String? phone,
  }) {
    return WaMessageLog(
      id: id,
      recipientName: recipientName,
      phone: phone ?? this.phone,
      category: category,
      message: message ?? this.message,
      status: status ?? this.status,
      errorReason: errorReason ?? this.errorReason,
      referenceId: referenceId,
      createdAt: createdAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'recipientName': recipientName,
        'phone': phone,
        'category': category,
        'message': message,
        'status': status,
        'errorReason': errorReason,
        'referenceId': referenceId,
        'createdAt': createdAt.toIso8601String(),
        'sentAt': sentAt?.toIso8601String(),
      };

  factory WaMessageLog.fromMap(Map<String, dynamic> map) {
    return WaMessageLog(
      id: map['id']?.toString() ?? '',
      recipientName: map['recipientName']?.toString() ?? 'Pelanggan',
      phone: map['phone']?.toString() ?? '',
      category: map['category']?.toString() ?? 'manual',
      message: map['message']?.toString() ?? '',
      status: map['status']?.toString() ?? 'sent',
      errorReason: map['errorReason']?.toString(),
      referenceId: map['referenceId']?.toString(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      sentAt: map['sentAt'] != null ? DateTime.tryParse(map['sentAt'].toString()) : null,
    );
  }
}
