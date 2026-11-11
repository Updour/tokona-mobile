import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/device_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_device_dialog.dart';

class ProductDeviceSelector extends ConsumerWidget {
  final String? selectedDevice;
  final ValueChanged<String?> onDeviceSelected;

  const ProductDeviceSelector({
    super.key,
    required this.selectedDevice,
    required this.onDeviceSelected,
  });

  static const List<String> fallbackDevices = ['HP 1', 'HP 2', 'HP 3'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(authProvider).currentStore;
    final deviceList = ref.watch(deviceListProvider);
    final devices = deviceList.isEmpty ? fallbackDevices : deviceList;

    if (deviceList.isEmpty && store != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(deviceListProvider.notifier).loadDevices(store.id);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_android_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Device', style: AppTypography.labelMedium.copyWith(fontSize: 12.5)),
              ],
            ),
            InkWell(
              onTap: () async {
                final name = await AddDeviceDialog.show(context);
                if (name != null && store != null) {
                  final added = await ref.read(deviceListProvider.notifier).addDevice(store.id, name);
                  if (added != null) onDeviceSelected(added);
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 2),
                    Text(
                      'Tambah HP',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip(
                label: 'Tanpa Device',
                icon: Icons.block_rounded,
                isSelected: selectedDevice == null || selectedDevice!.isEmpty,
                onTap: () => onDeviceSelected(null),
              ),
              ...devices.map((dev) {
                final isSelected = selectedDevice == dev;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _buildChip(
                    label: dev,
                    icon: Icons.phone_android_rounded,
                    isSelected: isSelected,
                    onTap: () => onDeviceSelected(dev),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 13,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceElevated,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      ),
      onSelected: (_) => onTap(),
    );
  }
}

