import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/supplier/domain/models/supplier_model.dart';
import 'package:tokona/features/supplier/presentation/widgets/supplier_list_bottom_sheet.dart';

class PurchaseSupplierField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: purchaseType == 'online' ? 'Nama Toko Online' : 'Nama Distributor',
        hintText: purchaseType == 'online' ? 'Toko Murah Jaya' : 'PT Wings Surya',
        prefixIcon: const Icon(Icons.business_outlined, size: 20),
        suffixIcon: IconButton(
          icon: const Icon(Icons.contacts_outlined, color: AppColors.primary, size: 20),
          tooltip: 'Pilih dari Master Supplier',
          onPressed: () async {
            final selected = await SupplierListBottomSheet.show(context);
            if (selected != null) {
              onSupplierSelected(selected);
            }
          },
        ),
      ),
    );
  }
}
