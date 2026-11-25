import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class PurchaseCoOrderSettingsCard extends StatelessWidget {
  final bool addToStock;
  final ValueChanged<bool> onAddToStockChanged;
  final bool isFundedByPartner;
  final ValueChanged<bool> onFundedChanged;

  const PurchaseCoOrderSettingsCard({
    super.key,
    required this.addToStock,
    required this.onAddToStockChanged,
    required this.isFundedByPartner,
    required this.onFundedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fisik langsung kirim ke rekan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    Text('Stok toko bertambah 0 pcs (Aman)', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.82,
                child: Switch.adaptive(
                  value: !addToStock,
                  activeThumbColor: const Color(0xFF16A34A),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (val) => onAddToStockChanged(!val),
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Modal didanai rekan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    Text('Saldo kas toko berkurang Rp 0 (Aman)', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.82,
                child: Switch.adaptive(
                  value: isFundedByPartner,
                  activeThumbColor: const Color(0xFF16A34A),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: onFundedChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
