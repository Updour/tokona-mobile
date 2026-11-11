import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';

class AlertNotificationState {
  final int overdueKasbonCount;
  final int dueSoonKasbonCount;
  final int lowStockCount;
  final int outOfStockCount;

  const AlertNotificationState({
    this.overdueKasbonCount = 0,
    this.dueSoonKasbonCount = 0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
  });

  int get totalUrgentKasbon => overdueKasbonCount + dueSoonKasbonCount;
  int get totalUrgentStock => lowStockCount + outOfStockCount;
  bool get hasOverdueKasbon => overdueKasbonCount > 0;
  bool get hasUrgentKasbon => totalUrgentKasbon > 0;
  bool get hasUrgentStock => totalUrgentStock > 0;
}

final alertNotificationProvider = Provider<AlertNotificationState>((ref) {
  final saleState = ref.watch(saleHistoryControllerProvider);
  final productState = ref.watch(productListProvider);
  final now = DateTime.now();

  int overdue = 0;
  int dueSoon = 0;

  for (final s in saleState.sales) {
    if (!s.isKasbon || s.isVoided) continue;
    if (s.dueDate != null) {
      if (now.isAfter(s.dueDate!)) {
        overdue++;
      } else {
        final diff = s.dueDate!.difference(now).inDays;
        if (diff >= 0 && diff <= 7) {
          dueSoon++;
        }
      }
    }
  }

  int lowStock = 0;
  int outOfStock = 0;
  for (final p in productState.products) {
    if (p.isOutOfStock) {
      outOfStock++;
    } else if (p.isLowStock) {
      lowStock++;
    }
  }

  return AlertNotificationState(
    overdueKasbonCount: overdue,
    dueSoonKasbonCount: dueSoon,
    lowStockCount: lowStock,
    outOfStockCount: outOfStock,
  );
});

