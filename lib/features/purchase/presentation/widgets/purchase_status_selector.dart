import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class PurchaseStatusSelector extends StatelessWidget {
  final String status;
  final int poDays;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<int> onPoDaysChanged;

  const PurchaseStatusSelector({
    super.key,
    required this.status,
    required this.poDays,
    required this.onStatusChanged,
    required this.onPoDaysChanged,
  });

  static const List<int> defaultPoOptions = [1, 2, 3, 5, 7];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule_send_outlined, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Status Pengadaan Barang',
                style: AppTypography.labelMedium.copyWith(fontSize: 12.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatusPill(
                label: 'Diterima',
                subLabel: 'Stok Langsung Masuk',
                icon: Icons.check_circle_outline_rounded,
                isSelected: status == 'received',
                onTap: () => onStatusChanged('received'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusPill(
                label: 'PO (1-7 Hari)',
                subLabel: 'Indent Menunggu Kirim',
                icon: Icons.hourglass_top_rounded,
                isSelected: status == 'pre_order',
                onTap: () => onStatusChanged('pre_order'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusPill(
                label: 'Dikirim',
                subLabel: 'Dalam Perjalanan',
                icon: Icons.local_shipping_outlined,
                isSelected: status == 'shipping',
                onTap: () => onStatusChanged('shipping'),
              ),
            ),
          ],
        ),
        if (status == 'pre_order') ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Pilih Durasi Pre-Order (PO):',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estimasi: ${_calculateTargetDate(poDays)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: defaultPoOptions.map((days) {
                      final isSel = poDays == days;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            '$days Hari',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel ? Colors.white : const Color(0xFF92400E),
                            ),
                          ),
                          selected: isSel,
                          selectedColor: const Color(0xFFD97706),
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSel ? const Color(0xFFD97706) : const Color(0xFFFDE68A),
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) onPoDaysChanged(days);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusPill({
    required String label,
    required String subLabel,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primaryDark : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: TextStyle(fontSize: 8.5, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTargetDate(int days) {
    final target = DateTime.now().add(Duration(days: days));
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${target.day} ${months[target.month - 1]}';
  }
}
