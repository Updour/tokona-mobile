class TopProductModel {
  final String productId;
  final String productName;
  final String? category;
  final double quantitySold;
  final double revenue;
  final double profit;

  const TopProductModel({
    required this.productId,
    required this.productName,
    this.category,
    required this.quantitySold,
    required this.revenue,
    required this.profit,
  });
}
