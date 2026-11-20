class AppPreferences {
  // 1. Notifikasi & Pengingat
  final String paylaterName;
  final int paylaterDueDay;
  final int paylaterRemindDaysBefore;
  final int paylaterRemindHour;
  final int kasbonRemindDaysBefore;
  final int bookingRemindMinutesBefore;
  final int deliveryHistoryDays;
  final bool hideEmptyNotificationTabs;
  final bool pushDeliveryEnabled;
  final bool pushPaylaterEnabled;

  // 2. Pengiriman & Lacak Resi
  final bool autoReceiveOnDelivered;
  final bool autoReceiveOnExpiredEstimate;
  final bool strictCourierPrefixDetection;

  // 4. Stok & Template WhatsApp
  final double defaultMinStockAlert;
  final String waBookingTemplate;
  final String waKasbonTemplate;
  final String waOrderTemplate;

  // 5. Printer Thermal Struk Kasir (ESC/POS)
  final int printerPaperWidth; // 58 atau 80 mm
  final bool autoPrintReceipt;
  final String printerFooterMessage;

  const AppPreferences({
    this.paylaterName = 'SPayLater',
    this.paylaterDueDay = 1,
    this.paylaterRemindDaysBefore = 2,
    this.paylaterRemindHour = 9,
    this.kasbonRemindDaysBefore = 3,
    this.bookingRemindMinutesBefore = 45,
    this.deliveryHistoryDays = 7,
    this.hideEmptyNotificationTabs = false,
    this.pushDeliveryEnabled = true,
    this.pushPaylaterEnabled = true,
    this.autoReceiveOnDelivered = true,
    this.autoReceiveOnExpiredEstimate = true,
    this.strictCourierPrefixDetection = true,
    this.defaultMinStockAlert = 5,
    this.waBookingTemplate = defaultBookingTemplate,
    this.waKasbonTemplate = defaultKasbonTemplate,
    this.waOrderTemplate = defaultOrderTemplate,
    this.printerPaperWidth = 58,
    this.autoPrintReceipt = false,
    this.printerFooterMessage = 'Terima kasih atas kunjungan Anda!',
  });

  static const String defaultBookingTemplate =
      'Halo Kak *{nama}*! 👋\n\n'
      'Mengingatkan pesanan Anda di *{toko}*:\n'
      '{daftar_barang}\n\n'
      '💰 Total: *{total}*\n'
      '📅 Jadwal: *{jadwal}*\n'
      '📍 Layanan: {metode}\n\n'
      'Pesanan sudah siap di toko. Ditunggu kedatangannya ya Kak. Terima kasih! 🙏';

  static const String defaultKasbonTemplate =
      'Halo Kak *{nama}*! 🙏\n'
      'Semoga selalu sehat dan lancar rezekinya.\n\n'
      'Kami dari *{toko}* menginformasikan tagihan nota kasbon:\n'
      '🧾 No. Nota: *{no_nota}*\n'
      '📅 Tanggal Belanja: {tanggal}\n'
      '⏰ Jatuh Tempo: *{jatuh_tempo}*\n'
      '💰 Total Tagihan: *{total}*\n\n'
      'Pembayaran bisa tunai di kasir atau transfer. Mohon konfirmasinya ya Kak. Terima kasih! 🙏';

  static const String defaultOrderTemplate =
      'Halo *{nama}*! 👋\n'
      'Pesanan dari *{toko}*:\n\n'
      '📦 Barang: *{barang}*\n'
      '🔢 Jumlah: *{jumlah} {satuan}*\n'
      '💵 Harga Satuan: {harga}\n'
      '💰 Total Beli: *{total}*\n\n'
      'Mohon konfirmasinya ya. Terima kasih! 🙏';

  static String renderTemplate(String template, Map<String, String> values) {
    var result = template;
    values.forEach((key, val) {
      result = result.replaceAll('{$key}', val);
    });
    return result;
  }

  bool isPaylaterWindowActive(DateTime now) {
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final due = paylaterDueDay.clamp(1, lastDay);
    final thisMonthDue = DateTime(now.year, now.month, due);
    final today = DateTime(now.year, now.month, now.day);
    final nextMonthLastDay = DateTime(now.year, now.month + 2, 0).day;
    final nextMonthDue = DateTime(now.year, now.month + 1, paylaterDueDay.clamp(1, nextMonthLastDay));

    final targetDue = today.isAfter(thisMonthDue) ? nextMonthDue : thisMonthDue;
    final diffDays = targetDue.difference(today).inDays;
    return diffDays >= 0 && diffDays <= paylaterRemindDaysBefore;
  }

  AppPreferences copyWith({
    String? paylaterName,
    int? paylaterDueDay,
    int? paylaterRemindDaysBefore,
    int? paylaterRemindHour,
    int? kasbonRemindDaysBefore,
    int? bookingRemindMinutesBefore,
    int? deliveryHistoryDays,
    bool? hideEmptyNotificationTabs,
    bool? pushDeliveryEnabled,
    bool? pushPaylaterEnabled,
    bool? autoReceiveOnDelivered,
    bool? autoReceiveOnExpiredEstimate,
    bool? strictCourierPrefixDetection,
    double? defaultMinStockAlert,
    String? waBookingTemplate,
    String? waKasbonTemplate,
    String? waOrderTemplate,
    int? printerPaperWidth,
    bool? autoPrintReceipt,
    String? printerFooterMessage,
  }) {
    return AppPreferences(
      paylaterName: paylaterName ?? this.paylaterName,
      paylaterDueDay: paylaterDueDay ?? this.paylaterDueDay,
      paylaterRemindDaysBefore: paylaterRemindDaysBefore ?? this.paylaterRemindDaysBefore,
      paylaterRemindHour: paylaterRemindHour ?? this.paylaterRemindHour,
      kasbonRemindDaysBefore: kasbonRemindDaysBefore ?? this.kasbonRemindDaysBefore,
      bookingRemindMinutesBefore: bookingRemindMinutesBefore ?? this.bookingRemindMinutesBefore,
      deliveryHistoryDays: deliveryHistoryDays ?? this.deliveryHistoryDays,
      hideEmptyNotificationTabs: hideEmptyNotificationTabs ?? this.hideEmptyNotificationTabs,
      pushDeliveryEnabled: pushDeliveryEnabled ?? this.pushDeliveryEnabled,
      pushPaylaterEnabled: pushPaylaterEnabled ?? this.pushPaylaterEnabled,
      autoReceiveOnDelivered: autoReceiveOnDelivered ?? this.autoReceiveOnDelivered,
      autoReceiveOnExpiredEstimate: autoReceiveOnExpiredEstimate ?? this.autoReceiveOnExpiredEstimate,
      strictCourierPrefixDetection: strictCourierPrefixDetection ?? this.strictCourierPrefixDetection,
      defaultMinStockAlert: defaultMinStockAlert ?? this.defaultMinStockAlert,
      waBookingTemplate: waBookingTemplate ?? this.waBookingTemplate,
      waKasbonTemplate: waKasbonTemplate ?? this.waKasbonTemplate,
      waOrderTemplate: waOrderTemplate ?? this.waOrderTemplate,
      printerPaperWidth: printerPaperWidth ?? this.printerPaperWidth,
      autoPrintReceipt: autoPrintReceipt ?? this.autoPrintReceipt,
      printerFooterMessage: printerFooterMessage ?? this.printerFooterMessage,
    );
  }

  Map<String, dynamic> toMap() => {
        'paylaterName': paylaterName,
        'paylaterDueDay': paylaterDueDay,
        'paylaterRemindDaysBefore': paylaterRemindDaysBefore,
        'paylaterRemindHour': paylaterRemindHour,
        'kasbonRemindDaysBefore': kasbonRemindDaysBefore,
        'bookingRemindMinutesBefore': bookingRemindMinutesBefore,
        'deliveryHistoryDays': deliveryHistoryDays,
        'hideEmptyNotificationTabs': hideEmptyNotificationTabs,
        'pushDeliveryEnabled': pushDeliveryEnabled,
        'pushPaylaterEnabled': pushPaylaterEnabled,
        'autoReceiveOnDelivered': autoReceiveOnDelivered,
        'autoReceiveOnExpiredEstimate': autoReceiveOnExpiredEstimate,
        'strictCourierPrefixDetection': strictCourierPrefixDetection,
        'defaultMinStockAlert': defaultMinStockAlert,
        'waBookingTemplate': waBookingTemplate,
        'waKasbonTemplate': waKasbonTemplate,
        'waOrderTemplate': waOrderTemplate,
        'printerPaperWidth': printerPaperWidth,
        'autoPrintReceipt': autoPrintReceipt,
        'printerFooterMessage': printerFooterMessage,
      };

  factory AppPreferences.fromMap(Map<String, dynamic> map) {
    return AppPreferences(
      paylaterName: (map['paylaterName'] as String?)?.trim().isNotEmpty == true ? map['paylaterName'] as String : 'SPayLater',
      paylaterDueDay: (map['paylaterDueDay'] as num? ?? 1).toInt().clamp(1, 28),
      paylaterRemindDaysBefore: (map['paylaterRemindDaysBefore'] as num? ?? 2).toInt().clamp(0, 15),
      paylaterRemindHour: (map['paylaterRemindHour'] as num? ?? 9).toInt().clamp(0, 23),
      kasbonRemindDaysBefore: (map['kasbonRemindDaysBefore'] as num? ?? 3).toInt().clamp(1, 30),
      bookingRemindMinutesBefore: (map['bookingRemindMinutesBefore'] as num? ?? 45).toInt().clamp(5, 240),
      deliveryHistoryDays: (map['deliveryHistoryDays'] as num? ?? 7).toInt().clamp(1, 60),
      hideEmptyNotificationTabs: map['hideEmptyNotificationTabs'] as bool? ?? false,
      pushDeliveryEnabled: map['pushDeliveryEnabled'] as bool? ?? true,
      pushPaylaterEnabled: map['pushPaylaterEnabled'] as bool? ?? true,
      autoReceiveOnDelivered: map['autoReceiveOnDelivered'] as bool? ?? true,
      autoReceiveOnExpiredEstimate: map['autoReceiveOnExpiredEstimate'] as bool? ?? true,
      strictCourierPrefixDetection: map['strictCourierPrefixDetection'] as bool? ?? true,
      defaultMinStockAlert: (map['defaultMinStockAlert'] as num? ?? 5).toDouble().clamp(0, 99999),
      waBookingTemplate: (map['waBookingTemplate'] as String?)?.isNotEmpty == true ? map['waBookingTemplate'] as String : defaultBookingTemplate,
      waKasbonTemplate: (map['waKasbonTemplate'] as String?)?.isNotEmpty == true ? map['waKasbonTemplate'] as String : defaultKasbonTemplate,
      waOrderTemplate: (map['waOrderTemplate'] as String?)?.isNotEmpty == true ? map['waOrderTemplate'] as String : defaultOrderTemplate,
      printerPaperWidth: (map['printerPaperWidth'] as num? ?? 58).toInt() == 80 ? 80 : 58,
      autoPrintReceipt: map['autoPrintReceipt'] as bool? ?? false,
      printerFooterMessage: (map['printerFooterMessage'] as String?) ?? 'Terima kasih atas kunjungan Anda!',
    );
  }
}
