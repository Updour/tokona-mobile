class ReportSummaryModel {
  final double totalRevenue;
  final double totalCogs;
  final double grossProfit;
  final double profitMargin;
  final int transactionCount;
  final double averageBasket;
  final double totalPurchaseSpend;
  final double totalPendingRefund;

  const ReportSummaryModel({
    required this.totalRevenue,
    required this.totalCogs,
    required this.grossProfit,
    required this.profitMargin,
    required this.transactionCount,
    required this.averageBasket,
    required this.totalPurchaseSpend,
    required this.totalPendingRefund,
  });

  factory ReportSummaryModel.empty() {
    return const ReportSummaryModel(
      totalRevenue: 0.0,
      totalCogs: 0.0,
      grossProfit: 0.0,
      profitMargin: 0.0,
      transactionCount: 0,
      averageBasket: 0.0,
      totalPurchaseSpend: 0.0,
      totalPendingRefund: 0.0,
    );
  }
}
