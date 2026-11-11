import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/product/domain/models/in_transit_device_item.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';

class ProductDeviceTagsRow extends ConsumerWidget {
  final ProductModel product;

  const ProductDeviceTagsRow({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrders = ref.watch(activeOrdersProvider);
    final inTransitList = InTransitDeviceItem.fromActiveOrders(activeOrders, product.id);
    final physicalTags = product.deviceTags;

    if (physicalTags.isEmpty && inTransitList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...physicalTags.map((tag) => _buildPhysicalBadge(tag)),
            ...inTransitList.map((item) => _buildInTransitBadge(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalBadge(String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone_android_rounded, size: 10, color: Color(0xFF6366F1)),
          const SizedBox(width: 2.5),
          Text(
            tag,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  Widget _buildInTransitBadge(InTransitDeviceItem item) {
    final qtyStr = item.quantity % 1 == 0 ? item.quantity.toInt().toString() : item.quantity.toStringAsFixed(1);
    
    final Color badgeColor;
    final Color bgColor;
    final IconData icon;
    final String statusText;

    if (item.isShipping) {
      badgeColor = const Color(0xFF0284C7);
      bgColor = const Color(0xFFE0F2FE);
      icon = Icons.local_shipping_rounded;
      statusText = 'Dikirim';
    } else if (item.isPreOrder) {
      badgeColor = const Color(0xFF7C3AED);
      bgColor = const Color(0xFFF3E8FF);
      icon = Icons.hourglass_top_rounded;
      statusText = 'PO';
    } else {
      badgeColor = const Color(0xFFD97706);
      bgColor = const Color(0xFFFEF3C7);
      icon = Icons.storefront_rounded;
      statusText = 'Belanja';
    }

    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: badgeColor),
          const SizedBox(width: 3.5),
          Text(
            '${item.deviceTag} • $statusText $qtyStr',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor),
          ),
        ],
      ),
    );
  }
}
