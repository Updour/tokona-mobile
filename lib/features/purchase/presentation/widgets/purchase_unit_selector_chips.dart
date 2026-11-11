import 'package:flutter/material.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

class PurchaseUnitSelectorChips extends StatelessWidget {
  final ProductModel product;
  final ProductUnitModel? selectedUnit;
  final ValueChanged<ProductUnitModel?> onUnitSelected;

  const PurchaseUnitSelectorChips({
    super.key,
    required this.product,
    required this.selectedUnit,
    required this.onUnitSelected,
  });

  @override
  Widget build(BuildContext context) {
    final units = product.units;

    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: Text('Satuan Dasar (${product.baseUnit})'),
          selected: selectedUnit == null,
          onSelected: (selected) {
            if (selected) onUnitSelected(null);
          },
        ),
        ...units.map((u) {
          return ChoiceChip(
            label: Text('${u.unitName} (${u.conversionFactor.toStringAsFixed(0)} ${product.baseUnit})'),
            selected: selectedUnit?.id == u.id,
            onSelected: (selected) {
              if (selected) onUnitSelected(u);
            },
          );
        }),
      ],
    );
  }
}
