import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_receivable_ledger_sheet.dart';
import 'package:tokona/features/customer/presentation/widgets/pay_kasbon_bottom_sheet.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMember = customer.isMember;
    final isGrosir = customer.isGrosir;

    final badgeColor = isMember
        ? const Color(0xFF6366F1)
        : isGrosir
            ? const Color(0xFFD97706)
            : const Color(0xFF64748B);

    final badgeBg = isMember
        ? const Color(0xFFEEF2FF)
        : isGrosir
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFF1F5F9);

    final avatarBg = isMember
        ? const Color(0xFFE0E7FF)
        : isGrosir
            ? const Color(0xFFFDE68A)
            : AppColors.primaryContainer;

    final avatarColor = isMember
        ? const Color(0xFF4338CA)
        : isGrosir
            ? const Color(0xFFB45309)
            : AppColors.primaryDark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => CustomerReceivableLedgerSheet.show(context, customer: customer),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      customer.name.trim().isNotEmpty ? customer.name.trim().substring(0, 1).toUpperCase() : 'C',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: avatarColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customer.name,
                              style: AppTypography.labelMedium.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              customer.typeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                customer.phone!,
                                style: AppTypography.bodySmall.copyWith(fontSize: 11.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      if (customer.address != null && customer.address!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                customer.address!,
                                style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      if (customer.hasReceivable) ...[
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => PayKasbonBottomSheet.show(context, customer: customer),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.payment_rounded, size: 12, color: AppColors.error),
                                const SizedBox(width: 4),
                                Text(
                                  'Kasbon: ${CurrencyFormatter.format(customer.receivableBalance)} (Bayar)',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) {
                    if (val == 'ledger') CustomerReceivableLedgerSheet.show(context, customer: customer);
                    if (val == 'pay') PayKasbonBottomSheet.show(context, customer: customer);
                    if (val == 'edit') onEdit?.call();
                    if (val == 'delete') onDelete?.call();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'ledger',
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_rounded, size: 17, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Buku Kasbon / Riwayat', style: TextStyle(fontSize: 12.5)),
                        ],
                      ),
                    ),
                    if (customer.hasReceivable)
                      const PopupMenuItem(
                        value: 'pay',
                        child: Row(
                          children: [
                            Icon(Icons.payment_rounded, size: 17, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Bayar Kasbon', style: TextStyle(fontSize: 12.5, color: AppColors.error)),
                          ],
                        ),
                      ),
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 17, color: AppColors.textPrimary),
                            SizedBox(width: 8),
                            Text('Ubah Data', style: TextStyle(fontSize: 12.5)),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 17, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(fontSize: 12.5, color: AppColors.error)),
                          ],
                        ),
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
}
