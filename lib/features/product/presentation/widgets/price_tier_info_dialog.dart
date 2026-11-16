import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class PriceTierInfoDialog {
  PriceTierInfoDialog._();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _PriceTierInfoSheet(),
    );
  }
}

class _PriceTierInfoSheet extends StatefulWidget {
  const _PriceTierInfoSheet();

  @override
  State<_PriceTierInfoSheet> createState() => _PriceTierInfoSheetState();
}

class _PriceTierInfoSheetState extends State<_PriceTierInfoSheet> {
  int? _expandedIndex = 0;

  final List<Map<String, String>> _items = const [
    {
      'title': 'Bagaimana Cara Kerjanya?',
      'desc': 'Harga normal (pembelian 1 unit) diisi pada form utama Harga Jual Dasar di atas. Bagian grosir ini khusus diskon otomatis jika pelanggan membeli dalam jumlah banyak (misal beli 2 atau lebih).',
    },
    {
      'title': 'Otomatis di Kasir (POS)',
      'desc': 'Saat kasir menambah jumlah produk di keranjang belanja hingga mencapai atau melebihi batas minimal, harga satuan produk langsung otomatis berubah tanpa perlu hitung diskon manual.',
    },
    {
      'title': 'Bisa Bertingkat Banyak Level',
      'desc': 'Anda bisa menambahkan beberapa tingkatan harga sekaligus. Misalnya: beli ≥ 2 harga Rp 174.000, beli ≥ 5 harga Rp 173.000, beli ≥ 10 harga Rp 170.000.',
    },
    {
      'title': 'Kombinasi dengan Satuan Dasar',
      'desc': 'Harga grosir ini mengacu pada Satuan Dasar yang sedang Anda atur (misal per Dus, per Pcs, atau per Bal).',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.price_change_outlined,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Panduan Harga Grosir Bertingkat', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                    Text('Diskon kuantitas otomatis di kasir', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(_items.length, (i) {
                  final item = _items[i];
                  final isExp = _expandedIndex == i;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isExp ? AppColors.secondary.withOpacity(0.35) : AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _expandedIndex = isExp ? null : i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['title']!,
                                    style: AppTypography.labelMedium.copyWith(
                                      fontSize: 13,
                                      color: isExp ? AppColors.secondary : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: isExp ? AppColors.secondary : AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExp) ...[
                          const Divider(height: 1, color: AppColors.border),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                            child: Text(
                              item['desc']!,
                              style: AppTypography.bodySmall.copyWith(height: 1.4, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              onPressed: () => Navigator.pop(context),
              child: const Text('MENGERTI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
