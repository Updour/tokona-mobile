class CapturedNotificationEvent {
  final String packageName;
  final String title;
  final String text;
  final String subText;
  final DateTime timestamp;

  const CapturedNotificationEvent({
    required this.packageName,
    required this.title,
    required this.text,
    required this.subText,
    required this.timestamp,
  });

  bool get isShopee => packageName.toLowerCase().contains('shopee');

  bool get isDeliveryUpdate {
    final lower = '$title $text $subText'.toLowerCase();
    return lower.contains('dikirim') ||
        lower.contains('dalam perjalanan') ||
        lower.contains('menuju') ||
        lower.contains('transit') ||
        lower.contains('antar');
  }

  bool get isDelivered {
    final lower = '$title $text $subText'.toLowerCase();
    return lower.contains('telah diterima') ||
        lower.contains('berhasil terkirim') ||
        lower.contains('sampai di tujuan') ||
        lower.contains('diterima oleh') ||
        lower.contains('paket telah diantar');
  }

  /// Ekstraksi nomor resi standar (SPX, J&T, JNE, SiCepat)
  String? extractTrackingNumber() {
    final combined = '$title $text $subText';
    // Pola umum resi: SPXID..., JP..., JT..., SOC..., dsb.
    final regResi = RegExp(
      r'\b(SPXID[A-Z0-9]{8,16}|JP[0-9]{10,14}|JT[0-9]{10,14}|[A-Z]{3,4}[0-9]{9,16}|00[0-9]{10,12})\b',
      caseSensitive: false,
    );
    final match = regResi.firstMatch(combined);
    return match?.group(0);
  }

  /// Ekstraksi nomor pesanan Shopee (biasanya format 24... atau gabungan angka/huruf)
  String? extractOrderNumber() {
    final combined = '$title $text $subText';
    final regOrder = RegExp(r'\b(2[0-9]{12,18}[A-Z0-9]*)\b');
    final match = regOrder.firstMatch(combined);
    return match?.group(0);
  }

  factory CapturedNotificationEvent.fromMap(Map<dynamic, dynamic> map) {
    return CapturedNotificationEvent(
      packageName: map['packageName']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      subText: map['subText']?.toString() ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
