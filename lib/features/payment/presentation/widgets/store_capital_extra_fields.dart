import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_date_tile.dart';

class StoreCapitalExtraFields extends StatelessWidget {
  final bool isWithdrawal;
  final DateTime selectedDate;
  final VoidCallback onPickDate;
  final TextEditingController sourceController;
  final TextEditingController notesController;

  const StoreCapitalExtraFields({
    super.key,
    required this.isWithdrawal,
    required this.selectedDate,
    required this.onPickDate,
    required this.sourceController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StoreCapitalDateTile(
          selectedDate: selectedDate,
          isWithdrawal: isWithdrawal,
          onTap: onPickDate,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: sourceController,
          decoration: InputDecoration(
            labelText: isWithdrawal ? 'Diterima oleh' : 'Sumber dana',
            hintText: isWithdrawal ? 'Nama penerima' : 'Kas pribadi / Jasa / Lainnya',
            prefixIcon: const Icon(Icons.source_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Catatan',
            hintText: 'Tulis catatan singkat...',
            prefixIcon: Icon(Icons.notes_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}
