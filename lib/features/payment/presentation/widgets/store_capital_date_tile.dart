import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';

class StoreCapitalDateTile extends StatelessWidget {
  final DateTime selectedDate;
  final bool isWithdrawal;
  final VoidCallback onTap;

  const StoreCapitalDateTile({
    super.key,
    required this.selectedDate,
    required this.isWithdrawal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');
    final color = isWithdrawal ? AppColors.error : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: color),
                const SizedBox(width: 8),
                Text(dateFormat.format(selectedDate), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            Text('Ubah', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
