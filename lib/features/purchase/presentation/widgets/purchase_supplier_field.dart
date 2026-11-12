import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/supplier/domain/models/supplier_model.dart';
import 'package:tokona/features/supplier/presentation/controllers/supplier_controller.dart';
import 'package:tokona/features/supplier/presentation/widgets/supplier_list_bottom_sheet.dart';

class PurchaseSupplierField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String purchaseType;
  final ValueChanged<SupplierModel> onSupplierSelected;

  const PurchaseSupplierField({
    super.key,
    required this.controller,
    required this.purchaseType,
    required this.onSupplierSelected,
  });

  @override
  ConsumerState<PurchaseSupplierField> createState() => _PurchaseSupplierFieldState();
}

class _PurchaseSupplierFieldState extends ConsumerState<PurchaseSupplierField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allSuppliers = ref.watch(supplierListProvider).suppliers;
    final currentText = widget.controller.text.trim();

    final filtered = allSuppliers.where((s) {
      if (widget.purchaseType == 'online') {
        if (s.type != 'online') return false;
      } else {
        if (s.type == 'online') return false;
      }
      if (currentText.isEmpty) return true;
      return s.name.toLowerCase().contains(currentText.toLowerCase());
    }).take(8).toList();

    final hasExactMatch = allSuppliers.any((s) => s.name.trim().toLowerCase() == currentText.toLowerCase());
    final isNewSupplier = currentText.length >= 2 && !hasExactMatch;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.purchaseType == 'online' ? 'Nama Toko Online / Supplier' : 'Nama Distributor / Toko',
            hintText: widget.purchaseType == 'online' ? 'Contoh: Toko Murah Jaya' : 'Contoh: PT Wings Surya',
            prefixIcon: const Icon(Icons.business_outlined, size: 20),
            suffixIcon: IconButton(
              icon: const Icon(Icons.contacts_outlined, color: AppColors.primary, size: 20),
              tooltip: 'Pilih dari Master Supplier',
              onPressed: () async {
                final selected = await SupplierListBottomSheet.show(context);
                if (selected != null) {
                  widget.onSupplierSelected(selected);
                }
              },
            ),
          ),
        ),
        if (isNewSupplier) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 13, color: Color(0xFF0D9488)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Distributor baru akan otomatis tersimpan ke Master Supplier saat disimpan',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF0D9488)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        if (filtered.isNotEmpty && !hasExactMatch) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final s = filtered[index];
                return ActionChip(
                  label: Text(s.name, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                  avatar: Icon(
                    s.isOnline ? Icons.store_mall_directory_rounded : Icons.local_shipping_outlined,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  backgroundColor: AppColors.surfaceInput,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                  ),
                  onPressed: () => widget.onSupplierSelected(s),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
