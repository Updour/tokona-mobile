import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';

class PurchaseInstallmentCard extends StatelessWidget {
  final int selectedTenor;
  final TextEditingController installmentController;
  final double itemsTotal;
  final ValueChanged<int> onTenorChanged;
  final VoidCallback onChanged;

  const PurchaseInstallmentCard({
    super.key,
    required this.selectedTenor,
    required this.installmentController,
    required this.itemsTotal,
    required this.onTenorChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final monthly = CurrencyFormatter.parse(installmentController.text);
    final totalPayable = selectedTenor > 1 ? (monthly > 0 ? monthly * selectedTenor : itemsTotal) : itemsTotal;
    final totalInterest = (totalPayable - itemsTotal).clamp(0.0, double.infinity);
    final interestPct = itemsTotal > 0 ? (totalInterest / itemsTotal) * 100 : 0.0;
    final isHighInterest = interestPct > 10.0;

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.credit_score_rounded, size: 18, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Skema Cicilan / BNPL Shopee', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                    Text('Bisa ubah dari 1 bulan ke 3 atau 6 bulan', style: TextStyle(fontSize: 10.5, color: Color(0xFFB45309))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTenorChip(1, '1 Bulan (Tempo)'),
              const SizedBox(width: 6),
              _buildTenorChip(3, '3 Bulan'),
              const SizedBox(width: 6),
              _buildTenorChip(6, '6 Bulan'),
              const SizedBox(width: 6),
              _buildTenorChip(12, '12 Bulan'),
            ],
          ),
          if (selectedTenor > 1) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cicilan per Bulan (Sesuai Shopee)*',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: installmentController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyTextInputFormatter()],
                        onChanged: (_) => onChanged(),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          prefixText: 'Rp ',
                          prefixStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFDE68A))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFDE68A))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: isHighInterest ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: isHighInterest ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  Icon(
                    isHighInterest ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                    size: 15,
                    color: isHighInterest ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Bunga/Biaya Cicilan: ${CurrencyFormatter.format(totalInterest)} (+${interestPct.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isHighInterest ? const Color(0xFF991B1B) : const Color(0xFF166534),
                          ),
                        ),
                        Text(
                          isHighInterest
                              ? 'Beban cicilan tinggi. Pastikan margin untung barang menutup biaya ini.'
                              : 'Beban cicilan masih tergolong wajar untuk perputaran stok.',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isHighInterest ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTenorChip(int tenor, String label) {
    final isSelected = selectedTenor == tenor;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTenorChanged(tenor);
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD97706) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? const Color(0xFFB45309) : const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF78350F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
