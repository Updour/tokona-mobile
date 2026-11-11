import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class PosKasbonDueDateCard extends StatelessWidget {
  final DateTime selectedDueDate;
  final ValueChanged<DateTime> onDueDateChanged;

  const PosKasbonDueDateCard({
    super.key,
    required this.selectedDueDate,
    required this.onDueDateChanged,
  });

  Future<void> _pickCustomDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      onDueDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final daysDiff = selectedDueDate.difference(DateTime.now()).inDays + 1;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_note_rounded, size: 16, color: Color(0xFFB45309)),
              const SizedBox(width: 6),
              Text(
                'Jatuh Tempo Kasbon',
                style: AppTypography.labelMedium.copyWith(
                  color: const Color(0xFF92400E),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$daysDiff Hari Lagi',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildShortcutChip('7 Hari', 7),
              const SizedBox(width: 6),
              _buildShortcutChip('14 Hari', 14),
              const SizedBox(width: 6),
              _buildShortcutChip('30 Hari', 30),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => _pickCustomDate(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 13, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text('Kalender', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Batas Pelunasan: ${dateFormat.format(selectedDueDate)}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutChip(String label, int days) {
    final targetDate = DateTime.now().add(Duration(days: days));
    final isSelected = selectedDueDate.year == targetDate.year &&
        selectedDueDate.month == targetDate.month &&
        selectedDueDate.day == targetDate.day;

    return GestureDetector(
      onTap: () => onDueDateChanged(targetDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD97706) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFB45309) : AppColors.border,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

