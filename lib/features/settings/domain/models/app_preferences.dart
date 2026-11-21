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

  // 5. Printer Thermal Struk Kasir (ESC/POS) & Layout Kustom
  final int printerPaperWidth; // 58 atau 80 mm
  final int printerColumnWidth; // 32 untuk 58mm, 48 untuk 80mm, atau kustom
  final bool autoPrintReceipt;
  final String? printerHeaderTitle; // Override nama toko di struk (opsional)
  final String? printerHeaderSubtitle; // Slogan/sub-header toko
  final bool printerShowAddress;
  final String? printerAddress; // Custom address di struk
  final bool printerShowPhone;
  final String? printerPhone; // Custom telp di struk
  final String? printerCustomHeader; // Catatan pembuka struk (welcome note)
  final bool printerShowCashier;
  final bool printerShowCustomer;
  final bool printerShowDateTime;
  final bool printerShowInvoiceNumber;
  final String printerFooterMessage; // Pesan terima kasih utama
  final String? printerFooterPolicy; // Kebijakan toko / garansi
  final String? printerFooterSocial; // Akun sosmed / website
  final int printerFeedLines; // Baris kosong sebelum potong kertas (1-6)
  final bool printerAutoCut;
  final bool printerMonospaceWhatsApp; // Format WhatsApp monospace receipt style

  // 6. Sinkronisasi Cloud
  final int syncIntervalSeconds;

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
    this.printerColumnWidth = 32,
    this.autoPrintReceipt = false,
    this.printerHeaderTitle,
    this.printerHeaderSubtitle,
    this.printerShowAddress = true,
    this.printerAddress,
    this.printerShowPhone = true,
    this.printerPhone,
    this.printerCustomHeader,
    this.printerShowCashier = true,
    this.printerShowCustomer = true,
    this.printerShowDateTime = true,
    this.printerShowInvoiceNumber = true,
    this.printerFooterMessage = 'Terima kasih atas kunjungan Anda!',
    this.printerFooterPolicy = 'Barang yang sudah dibeli tidak dapat ditukar/dikembalikan',
    this.printerFooterSocial,
    this.printerFeedLines = 3,
    this.printerAutoCut = false,
    this.printerMonospaceWhatsApp = true,
    this.syncIntervalSeconds = 30,
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
    int? printerColumnWidth,
    bool? autoPrintReceipt,
    String? printerHeaderTitle,
    String? printerHeaderSubtitle,
    bool? printerShowAddress,
    String? printerAddress,
    bool? printerShowPhone,
    String? printerPhone,
    String? printerCustomHeader,
    bool? printerShowCashier,
    bool? printerShowCustomer,
    bool? printerShowDateTime,
    bool? printerShowInvoiceNumber,
    String? printerFooterMessage,
    String? printerFooterPolicy,
    String? printerFooterSocial,
    int? printerFeedLines,
    bool? printerAutoCut,
    bool? printerMonospaceWhatsApp,
    int? syncIntervalSeconds,
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
      printerColumnWidth: printerColumnWidth ?? this.printerColumnWidth,
      autoPrintReceipt: autoPrintReceipt ?? this.autoPrintReceipt,
      printerHeaderTitle: printerHeaderTitle ?? this.printerHeaderTitle,
      printerHeaderSubtitle: printerHeaderSubtitle ?? this.printerHeaderSubtitle,
      printerShowAddress: printerShowAddress ?? this.printerShowAddress,
      printerAddress: printerAddress ?? this.printerAddress,
      printerShowPhone: printerShowPhone ?? this.printerShowPhone,
      printerPhone: printerPhone ?? this.printerPhone,
      printerCustomHeader: printerCustomHeader ?? this.printerCustomHeader,
      printerShowCashier: printerShowCashier ?? this.printerShowCashier,
      printerShowCustomer: printerShowCustomer ?? this.printerShowCustomer,
      printerShowDateTime: printerShowDateTime ?? this.printerShowDateTime,
      printerShowInvoiceNumber: printerShowInvoiceNumber ?? this.printerShowInvoiceNumber,
      printerFooterMessage: printerFooterMessage ?? this.printerFooterMessage,
      printerFooterPolicy: printerFooterPolicy ?? this.printerFooterPolicy,
      printerFooterSocial: printerFooterSocial ?? this.printerFooterSocial,
      printerFeedLines: printerFeedLines ?? this.printerFeedLines,
      printerAutoCut: printerAutoCut ?? this.printerAutoCut,
      printerMonospaceWhatsApp: printerMonospaceWhatsApp ?? this.printerMonospaceWhatsApp,
      syncIntervalSeconds: syncIntervalSeconds ?? this.syncIntervalSeconds,
    );
  }

  Map<String, dynamic> toMap() => {
        'paylaterName': paylaterName, 'paylaterDueDay': paylaterDueDay,
        'paylaterRemindDaysBefore': paylaterRemindDaysBefore, 'paylaterRemindHour': paylaterRemindHour,
        'kasbonRemindDaysBefore': kasbonRemindDaysBefore, 'bookingRemindMinutesBefore': bookingRemindMinutesBefore,
        'deliveryHistoryDays': deliveryHistoryDays, 'hideEmptyNotificationTabs': hideEmptyNotificationTabs,
        'pushDeliveryEnabled': pushDeliveryEnabled, 'pushPaylaterEnabled': pushPaylaterEnabled,
        'autoReceiveOnDelivered': autoReceiveOnDelivered, 'autoReceiveOnExpiredEstimate': autoReceiveOnExpiredEstimate,
        'strictCourierPrefixDetection': strictCourierPrefixDetection, 'defaultMinStockAlert': defaultMinStockAlert,
        'waBookingTemplate': waBookingTemplate, 'waKasbonTemplate': waKasbonTemplate, 'waOrderTemplate': waOrderTemplate,
        'printerPaperWidth': printerPaperWidth, 'printerColumnWidth': printerColumnWidth, 'autoPrintReceipt': autoPrintReceipt,
        'printerHeaderTitle': printerHeaderTitle, 'printerHeaderSubtitle': printerHeaderSubtitle,
        'printerShowAddress': printerShowAddress, 'printerAddress': printerAddress,
        'printerShowPhone': printerShowPhone, 'printerPhone': printerPhone, 'printerCustomHeader': printerCustomHeader,
        'printerShowCashier': printerShowCashier, 'printerShowCustomer': printerShowCustomer,
        'printerShowDateTime': printerShowDateTime, 'printerShowInvoiceNumber': printerShowInvoiceNumber,
        'printerFooterMessage': printerFooterMessage, 'printerFooterPolicy': printerFooterPolicy,
        'printerFooterSocial': printerFooterSocial, 'printerFeedLines': printerFeedLines,
        'printerAutoCut': printerAutoCut, 'printerMonospaceWhatsApp': printerMonospaceWhatsApp,
        'syncIntervalSeconds': syncIntervalSeconds,
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
      printerColumnWidth: (map['printerColumnWidth'] as num? ?? ((map['printerPaperWidth'] as num? ?? 58).toInt() == 80 ? 48 : 32)).toInt().clamp(28, 54),
      autoPrintReceipt: map['autoPrintReceipt'] as bool? ?? false,
      printerHeaderTitle: map['printerHeaderTitle'] as String?,
      printerHeaderSubtitle: map['printerHeaderSubtitle'] as String?,
      printerShowAddress: map['printerShowAddress'] as bool? ?? true,
      printerAddress: map['printerAddress'] as String?,
      printerShowPhone: map['printerShowPhone'] as bool? ?? true,
      printerPhone: map['printerPhone'] as String?,
      printerCustomHeader: map['printerCustomHeader'] as String?,
      printerShowCashier: map['printerShowCashier'] as bool? ?? true,
      printerShowCustomer: map['printerShowCustomer'] as bool? ?? true,
      printerShowDateTime: map['printerShowDateTime'] as bool? ?? true,
      printerShowInvoiceNumber: map['printerShowInvoiceNumber'] as bool? ?? true,
      printerFooterMessage: (map['printerFooterMessage'] as String?) ?? 'Terima kasih atas kunjungan Anda!',
      printerFooterPolicy: (map['printerFooterPolicy'] as String?) ?? 'Barang yang sudah dibeli tidak dapat ditukar/dikembalikan',
      printerFooterSocial: map['printerFooterSocial'] as String?,
      printerFeedLines: (map['printerFeedLines'] as num? ?? 3).toInt().clamp(1, 6),
      printerAutoCut: map['printerAutoCut'] as bool? ?? false,
      printerMonospaceWhatsApp: map['printerMonospaceWhatsApp'] as bool? ?? true,
      syncIntervalSeconds: (map['syncIntervalSeconds'] as num? ?? 30).toInt().clamp(10, 86400),
    );
  }
}
