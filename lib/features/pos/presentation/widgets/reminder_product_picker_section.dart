import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/pos/domain/models/cart_item_model.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_manual_qty_dialog.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

class ReminderProductPickerSection extends StatelessWidget {
  final List<ProductModel> products;
  final List<CartItemModel> selectedItems;
  final ValueChanged<List<CartItemModel>> onItemsChanged;

  const ReminderProductPickerSection({
    super.key,
    required this.products,
    required this.selectedItems,
    required this.onItemsChanged,
  });

  void _addOrIncrement(ProductModel product) {
    final idx = selectedItems.indexWhere((it) => it.product.id == product.id && it.selectedUnit == null);
    final next = List<CartItemModel>.from(selectedItems);
    if (idx >= 0) {
      next[idx] = next[idx].copyWith(quantity: next[idx].quantity + 1);
    } else {
      next.add(CartItemModel(product: product, quantity: 1));
    }
    onItemsChanged(next);
  }

  void _updateQty(int index, double qty) {
    final next = List<CartItemModel>.from(selectedItems);
    if (qty <= 0) {
      next.removeAt(index);
    } else {
      next[index] = next[index].copyWith(quantity: qty);
    }
    onItemsChanged(next);
  }

  void _changeUnit(int index, ProductUnitModel? unit) {
    final next = List<CartItemModel>.from(selectedItems);
    next[index] = next[index].copyWith(selectedUnit: unit, clearUnit: unit == null);
    onItemsChanged(next);
  }

  Future<void> _openProductSelector(BuildContext context) async {
    String query = '';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = products.where((p) {
            if (query.isEmpty) return true;
            return p.name.toLowerCase().contains(query) || (p.sku?.toLowerCase().contains(query) ?? false);
          }).toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.72,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 10),
                const Text('Pilih Produk Pesanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                TextField(
                  autofocus: true,
                  onChanged: (v) => setModalState(() => query = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari nama produk...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Produk tidak ditemukan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)))
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final p = filtered[i];
                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              title: Text(p.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                              subtitle: Text(
                                '${CurrencyFormatter.format(p.baseSellingPrice)} / ${p.baseUnit} • Stok: ${p.stockBase.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              trailing: const Icon(Icons.add_circle_rounded, color: Color(0xFF059669), size: 22),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _addOrIncrement(p);
                                Navigator.of(ctx).pop();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 16, color: Color(0xFF059669)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('Produk & Jumlah (Otomatis Total)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              ),
              InkWell(
                onTap: () => _openProductSelector(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF6EE7B7)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 14, color: Color(0xFF047857)),
                      SizedBox(width: 3),
                      Text('Pilih Produk', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF047857))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (selectedItems.isEmpty) ...[
            const SizedBox(height: 6),
            const Text(
              'Opsional: pilih produk dari katalog agar catatan & total bayar terhitung otomatis.',
              style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
            ),
          ] else ...[
            const SizedBox(height: 8),
            ...selectedItems.asMap().entries.map((entry) => _buildItemRow(context, entry.key, entry.value)),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, int idx, CartItemModel item) {
    final qtyStr = item.quantity == item.quantity.roundToDouble() ? item.quantity.toInt().toString() : item.quantity.toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${CurrencyFormatter.format(item.unitPrice)} / ${item.unitName} → ${CurrencyFormatter.format(item.subtotal)}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF047857), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _updateQty(idx, item.quantity - 1),
                    child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.textSecondary)),
                  ),
                  InkWell(
                    onTap: () async {
                      final maxVal = item.product.stockBase > 0 ? (item.product.stockBase / item.conversionFactor) : 9999.0;
                      final val = await PosManualQtyDialog.show(
                        context,
                        productName: item.product.name,
                        unitName: item.unitName,
                        initialQty: item.quantity,
                        maxStock: maxVal < item.quantity ? 9999.0 : maxVal,
                      );
                      if (val != null) _updateQty(idx, val);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                      child: Text(qtyStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                  ),
                  InkWell(
                    onTap: () => _updateQty(idx, item.quantity + 1),
                    child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF059669))),
                  ),
                ],
              ),
            ],
          ),
          if (item.product.units.isNotEmpty) ...[
            const SizedBox(height: 5),
            Wrap(
              spacing: 5,
              children: [
                _unitPill(item.product.baseUnit, item.selectedUnit == null, () => _changeUnit(idx, null)),
                ...item.product.units.map((u) => _unitPill(u.unitName, item.selectedUnit?.id == u.id, () => _changeUnit(idx, u))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _unitPill(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: active ? AppColors.primaryDark : AppColors.textSecondary)),
      ),
    );
  }
}
