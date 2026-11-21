import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_picker_sheet.dart';

class PosCartCustomerBar extends StatelessWidget {
  final TextEditingController controller;
  final CustomerModel? selectedCustomer;
  final ValueChanged<CustomerModel?> onCustomerChanged;

  const PosCartCustomerBar({
    super.key,
    required this.controller,
    required this.selectedCustomer,
    required this.onCustomerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = selectedCustomer != null && selectedCustomer!.phone != null && selectedCustomer!.phone!.trim().isNotEmpty;

    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selectedCustomer != null ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Icon(
            selectedCustomer != null ? Icons.person_rounded : Icons.person_outline_rounded,
            size: 16,
            color: selectedCustomer != null ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  onChanged: (val) {
                    if (selectedCustomer != null && val != selectedCustomer!.name) {
                      onCustomerChanged(null);
                    }
                  },
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Nama pelanggan (opsional / kasbon)',
                    hintStyle: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                    border: InputBorder.none,
                  ),
                ),
                if (hasPhone)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 11, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          selectedCustomer!.phone!.trim(),
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (selectedCustomer != null)
            GestureDetector(
              onTap: () {
                controller.clear();
                onCustomerChanged(null);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(right: 4),
                decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, size: 12, color: AppColors.textSecondary),
              ),
            ),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              CustomerPickerSheet.show(
                context,
                selectedCustomer: selectedCustomer,
                onCustomerSelected: (c) {
                  controller.text = c?.name ?? '';
                  onCustomerChanged(c);
                },
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.contacts_rounded, size: 13, color: AppColors.primaryDark),
                  SizedBox(width: 3),
                  Text('Pilih', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

