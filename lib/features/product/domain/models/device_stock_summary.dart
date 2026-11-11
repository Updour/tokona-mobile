class DeviceStockSummary {
  final String deviceName;
  final int totalProducts;
  final double totalStock;
  final int lowStockCount;

  const DeviceStockSummary({
    required this.deviceName,
    required this.totalProducts,
    required this.totalStock,
    this.lowStockCount = 0,
  });

  bool get isUntagged =>
      deviceName.isEmpty ||
      deviceName.toLowerCase() == 'tanpa device' ||
      deviceName.toLowerCase() == 'lainnya';

  factory DeviceStockSummary.fromMap(Map<String, dynamic> map) {
    return DeviceStockSummary(
      deviceName: (map['device_name'] as String?)?.trim().isNotEmpty == true
          ? (map['device_name'] as String).trim()
          : 'Tanpa Device',
      totalProducts: (map['total_sku'] as num?)?.toInt() ?? 0,
      totalStock: (map['total_stock'] as num?)?.toDouble() ?? 0.0,
      lowStockCount: (map['low_stock_count'] as num?)?.toInt() ?? 0,
    );
  }
}

