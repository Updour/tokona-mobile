import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';

class PaylaterSettlementAccountSheet extends StatefulWidget {
  final double amount;
  final List<PaymentAccountModel> accounts;

  const PaylaterSettlementAccountSheet({
    super.key,
    required this.amount,
    required this.accounts,
  });

  static Future<PaymentAccountModel?> show(
    BuildContext context, {
    required double amount,
    required List<PaymentAccountModel> accounts,
  }) {
    return showModalBottomSheet<PaymentAccountModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaylaterSettlementAccountSheet(amount: amount, accounts: accounts),
    );
  }

  @override
  State<PaylaterSettlementAccountSheet> createState() => _PaylaterSettlementAccountSheetState();
}

class _PaylaterSettlementAccountSheetState extends State<PaylaterSettlementAccountSheet> {
  PaymentAccountModel? _selected;

  @override
  void initState() {
    super.initState();
    final activeList = widget.accounts.where((a) => a.isActive).toList();
    if (activeList.isNotEmpty) {
      // Prioritaskan akun yang saldonya mencukupi
      _selected = activeList.firstWhere(
        (a) => a.currentBalance >= widget.amount,
        orElse: () => activeList.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeList = widget.accounts.where((a) => a.isActive).toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, size: 20, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pilih Sumber Kas / Bank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Saldo rekening terpilih akan otomatis dipotong', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nominal Pelunasan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                Text(
                  CurrencyFormatter.format(widget.amount),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Potong dari Rekening:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: activeList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final acc = activeList[idx];
                final isSelected = _selected?.id == acc.id;
                final isEnough = acc.currentBalance >= widget.amount;

                return InkWell(
                  onTap: () => setState(() => _selected = acc),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          size: 18,
                          color: isSelected ? const Color(0xFF16A34A) : AppColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(acc.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(
                                'Saldo: ${CurrencyFormatter.format(acc.currentBalance)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isEnough ? AppColors.textSecondary : const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isEnough)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Saldo kurang', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _selected == null
                ? null
                : () => Navigator.of(context).pop(_selected),
            icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
            label: const Text('Konfirmasi & Potong Saldo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

