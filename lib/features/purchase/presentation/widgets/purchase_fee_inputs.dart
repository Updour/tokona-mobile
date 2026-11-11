import 'package:flutter/material.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class PurchaseFeeInputs extends StatelessWidget {
  final TextEditingController serviceFeeController;
  final TextEditingController shippingFeeController;
  final VoidCallback onChanged;

  const PurchaseFeeInputs({
    super.key,
    required this.serviceFeeController,
    required this.shippingFeeController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: serviceFeeController,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyTextInputFormatter()],
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Biaya Layanan',
              prefixText: 'Rp ',
              hintText: '0',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: shippingFeeController,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyTextInputFormatter()],
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Ongkir (Opsi)',
              prefixText: 'Rp ',
              hintText: '0',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
