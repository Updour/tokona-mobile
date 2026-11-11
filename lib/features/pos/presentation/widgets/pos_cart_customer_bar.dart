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
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
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
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
              ),
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

