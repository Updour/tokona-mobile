import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';
import 'package:tokona/features/payment/presentation/widgets/add_store_capital_bottom_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_management_sheet.dart';

class PaymentStoreWalletCard extends ConsumerStatefulWidget {
  final List<PaymentAccountModel> accounts;
  final double totalBalance;

  const PaymentStoreWalletCard({
    super.key,
    required this.accounts,
    required this.totalBalance,
  });

  @override
  ConsumerState<PaymentStoreWalletCard> createState() => _PaymentStoreWalletCardState();
}

class _PaymentStoreWalletCardState extends ConsumerState<PaymentStoreWalletCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authProvider).currentStore;
    final storeName = store?.name ?? 'Toko Saya';

    final cashBalance = widget.accounts
        .where((a) => a.type == 'cash')
        .fold<double>(0.0, (sum, a) => sum + a.currentBalance);
    final bankBalance = widget.accounts
        .where((a) => a.type == 'bank')
        .fold<double>(0.0, (sum, a) => sum + a.currentBalance);
    final ewalletBalance = widget.accounts
        .where((a) => a.type == 'ewallet' || a.type == 'qris')
        .fold<double>(0.0, (sum, a) => sum + a.currentBalance);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF334155),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        storeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.contactless_rounded, color: Colors.white70, size: 22),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'KAS & MODAL TOKO',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isBalanceVisible = !_isBalanceVisible);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _isBalanceVisible ? CurrencyFormatter.format(widget.totalBalance) : 'Rp ••••••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSubBalance('Kas Laci', cashBalance, const Color(0xFF34D399)),
                    Container(width: 1, height: 24, color: Colors.white12),
                    _buildSubBalance('Bank', bankBalance, const Color(0xFF60A5FA)),
                    Container(width: 1, height: 24, color: Colors.white12),
                    _buildSubBalance('QRIS/E-Wallet', ewalletBalance, const Color(0xFFA78BFA)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.add_circle_outline_rounded,
                label: 'Tambah Modal',
                color: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                onTap: () => AddStoreCapitalBottomSheet.show(context, initialType: 'TAMBAH_MODAL'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.remove_circle_outline_rounded,
                label: 'Tarik Kas',
                color: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEF2F2),
                onTap: () => AddStoreCapitalBottomSheet.show(context, initialType: 'TARIK_MODAL'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.history_rounded,
                label: 'Riwayat Arus',
                color: const Color(0xFF4338CA),
                bgColor: const Color(0xFFEEF2FF),
                onTap: () => StoreCapitalManagementSheet.show(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubBalance(String label, double amount, Color accentColor) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 5, height: 5, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _isBalanceVisible ? CurrencyFormatter.format(amount) : '••••••',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

