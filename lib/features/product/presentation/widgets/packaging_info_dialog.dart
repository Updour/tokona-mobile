import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class PackagingInfoDialog {
  PackagingInfoDialog._();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _PackagingInfoSheet(),
    );
  }
}

class _PackagingInfoSheet extends StatefulWidget {
  const _PackagingInfoSheet();

  @override
  State<_PackagingInfoSheet> createState() => _PackagingInfoSheetState();
}

class _PackagingInfoSheetState extends State<_PackagingInfoSheet> {
  int? _expandedIndex = 0;

  final List<Map<String, String>> _items = const [
    {
      'title': 'Apa itu Satuan Kemasan Bertingkat?',
      'desc': 'Fitur untuk menjual satu produk dalam berbagai wujud/kemasan tanpa membuat data barang ganda. Contoh: rokok dijual bungkus dan slop, atau mi instan dijual pcs dan kardus/dus.',
    },
    {
      'title': 'Bagaimana Pengurangan Stoknya?',
      'desc': 'Stok selalu dipusatkan pada Satuan Dasar. Jika 1 Dus (isi 40 Pcs) terjual di kasir, stok dasar otomatis berkurang 40 Pcs. Anda tidak perlu repot konversi manual.',
    },
    {
      'title': 'Perhitungan Modal HPP & Laba',
      'desc': 'HPP kemasan dihitung otomatis dari (HPP Satuan Dasar × Isi Konversi). Keuntungan dan laporan laba kotor toko tetap tercatat sangat akurat.',
    },
    {
      'title': 'Barcode Khusus Kemasan',
      'desc': 'Tiap kemasan bisa memiliki barcode sendiri. Saat kasir scan barcode dus, kasir langsung mencatat penjualan dus tanpa salah hitung.',
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
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primaryDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Panduan Satuan Kemasan', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                    Text('Pelajari sistem multi-kemasan Tokona', style: AppTypography.bodySmall),
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
                      border: Border.all(color: isExp ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
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
                                      color: isExp ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: isExp ? AppColors.primary : AppColors.textSecondary,
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
              onPressed: () => Navigator.pop(context),
              child: const Text('MENGERTI'),
            ),
          ),
        ],
      ),
    );
  }
}
