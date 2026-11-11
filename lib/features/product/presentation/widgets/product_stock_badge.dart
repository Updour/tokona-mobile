import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/domain/models/in_transit_device_item.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/widgets/stock_breakdown_sheet.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';

class ProductStockBadge extends ConsumerWidget {
  final ProductModel product;

  const ProductStockBadge({super.key, required this.product});

  String _formatQty(double qty) {
    return qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrders = ref.watch(activeOrdersProvider);
    final inTransitList = InTransitDeviceItem.fromActiveOrders(activeOrders, product.id);
    final totalPending = inTransitList.fold<double>(0.0, (sum, item) => sum + item.quantity);
    final hasPending = totalPending > 0;
    final isPhysicalZero = product.stockBase <= 0;

    Color bgColor;
    Color fgColor;
    Border? border;
    IconData? icon;
    String label;

    if (isPhysicalZero && hasPending) {
      bgColor = const Color(0xFFFEF3C7);
      fgColor = const Color(0xFFB45309);
      border = Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5), width: 1);
      icon = Icons.hourglass_top_rounded;
      label = '${_formatQty(totalPending)} ${product.baseUnit}';
    } else if (hasPending) {
      bgColor = const Color(0xFFF3E8FF);
      fgColor = const Color(0xFF7C3AED);
      border = Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4), width: 1);
      icon = Icons.devices_rounded;
      label = '${_formatQty(product.stockBase + totalPending)} ${product.baseUnit}';
    } else if (product.isLowStock) {
      bgColor = AppColors.errorContainer;
      fgColor = AppColors.error;
      label = '${_formatQty(product.stockBase)} ${product.baseUnit}';
    } else {
      bgColor = AppColors.successContainer;
      fgColor = AppColors.success;
      label = '${_formatQty(product.stockBase)} ${product.baseUnit}';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => StockBreakdownSheet.show(
          context,
          product: product,
          totalPending: totalPending,
          items: inTransitList,
        ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: fgColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
