class ProductValuationModel {
  final int totalSku;
  final double totalPhysicalStock;
  final double totalAssetCost;
  final double totalPotentialRevenue;
  final int outOfStockCount;
  final int lowStockCount;

  const ProductValuationModel({
    this.totalSku = 0,
    this.totalPhysicalStock = 0,
    this.totalAssetCost = 0,
    this.totalPotentialRevenue = 0,
    this.outOfStockCount = 0,
    this.lowStockCount = 0,
  });

  double get potentialProfit => totalPotentialRevenue - totalAssetCost;

  double get profitMarginPercentage {
    if (totalPotentialRevenue <= 0) return 0;
    return (potentialProfit / totalPotentialRevenue) * 100;
  }
}

