import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';

class SaleHistoryCard extends StatelessWidget {
  final SaleModel sale;
  final VoidCallback onTap;

  const SaleHistoryCard({
    super.key,
    required this.sale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final isVoid = sale.isVoided;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVoid
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isVoid
                                ? AppColors.errorContainer
                                : AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isVoid ? Icons.cancel_outlined : Icons.receipt_long_rounded,
                            size: 16,
                            color: isVoid ? AppColors.error : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sale.invoiceNumber,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              dateFormat.format(sale.createdAt),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sale.customerName != null && sale.customerName!.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  sale.customerName!,
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            '${sale.items.length} jenis barang (${sale.totalItemQuantity.toStringAsFixed(0)} item)',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(sale.finalAmount),
                          style: AppTypography.headingSmall.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isVoid ? AppColors.textMuted : AppColors.primary,
                            decoration: isVoid ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                sale.paymentMethod,
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                              ),
                            ),
                            if (!isVoid && sale.totalProfit > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                'Laba +${CurrencyFormatter.format(sale.totalProfit)}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (sale.isVoided) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'DIBATALKAN',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.error),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'SELESAI',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success),
      ),
    );
  }
}

