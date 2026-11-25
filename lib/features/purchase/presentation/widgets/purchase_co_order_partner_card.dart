import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class PurchaseCoOrderPartnerCard extends StatelessWidget {
  final TextEditingController coPartnerController;
  final TextEditingController coTrackingController;
  final String platform;
  final ValueChanged<String> onPlatformChanged;

  const PurchaseCoOrderPartnerCard({
    super.key,
    required this.coPartnerController,
    required this.coTrackingController,
    required this.platform,
    required this.onPlatformChanged,
  });

  static const List<String> _platforms = ['Shopee', 'Tokopedia', 'TikTok Shop', 'Lazada'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.handshake_outlined, size: 16, color: Color(0xFFD97706)),
                  SizedBox(width: 6),
                  Text(
                    'Tujuan Co-Order Rekan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Hitung Otomatis',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 1. Nama Rekan / Pemesan (Atas)
          TextField(
            controller: coPartnerController,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              labelText: 'Nama Rekan / Pemesan *',
              hintText: ' Budi / Toko Barokah',
              prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          const SizedBox(height: 8),

          // 2. No. Resi (Bawah)
          TextField(
            controller: coTrackingController,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              labelText: 'No. Resi Pengiriman (Opsional)',
              hintText: ' SPXID04829104 / J&T Cargo',
              prefixIcon: Icon(Icons.local_shipping_outlined, size: 17),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          const SizedBox(height: 8),

          // 3. Marketplace (Horizontally Scrollable Chips - Anti Overflow)
          Row(
            children: [
              const Text(
                'Marketplace:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _platforms.map((p) {
                      final isSelected = platform == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: ChoiceChip(
                          label: Text(
                            p,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFD97706),
                          backgroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          onSelected: (_) => onPlatformChanged(p),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
