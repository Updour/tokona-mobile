import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/device_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_device_dialog.dart';

class DeviceManagementSheet extends ConsumerStatefulWidget {
  const DeviceManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DeviceManagementSheet(),
    );
  }

  @override
  ConsumerState<DeviceManagementSheet> createState() => _DeviceManagementSheetState();
}

class _DeviceManagementSheetState extends ConsumerState<DeviceManagementSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = ref.read(authProvider).currentStore;
      if (store != null) {
        ref.read(deviceListProvider.notifier).loadDevices(store.id);
      }
    });
  }

  Future<void> _handleEdit(String dev) async {
    final updated = await AddDeviceDialog.show(context, initialName: dev);
    if (updated != null && updated != dev) {
      final store = ref.read(authProvider).currentStore;
      if (store != null) {
        await ref.read(deviceListProvider.notifier).updateDevice(store.id, dev, updated);
        if (mounted) {
          HapticFeedback.lightImpact();
          AppToast.showSuccess(context, 'Nama HP berhasil diubah');
        }
      }
    }
  }

  Future<void> _handleDelete(String dev) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Hapus Device HP',
      message: 'Hapus penanda perangkat "$dev"? Riwayat belanja lama tetap aman.',
      confirmText: 'Hapus',
      isDestructive: true,
    );
    if (confirmed == true) {
      final store = ref.read(authProvider).currentStore;
      if (store != null) {
        await ref.read(deviceListProvider.notifier).deleteDevice(store.id, dev);
        if (mounted) {
          HapticFeedback.lightImpact();
          AppToast.showSuccess(context, 'Perangkat $dev berhasil dihapus');
        }
      }
    }
  }

  Future<void> _handleAdd() async {
    final name = await AddDeviceDialog.show(context);
    if (name != null) {
      final store = ref.read(authProvider).currentStore;
      if (store != null) {
        await ref.read(deviceListProvider.notifier).addDevice(store.id, name);
        if (mounted) {
          HapticFeedback.lightImpact();
          AppToast.showSuccess(context, 'Perangkat $name berhasil ditambahkan');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(deviceListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Master Device HP Belanja', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${devices.length} perangkat HP terdaftar', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: devices.isEmpty
                ? const Center(child: Text('Belum ada perangkat HP', style: TextStyle(color: AppColors.textMuted)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: devices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final dev = devices[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.phone_android_rounded, size: 18, color: AppColors.primaryDark),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dev, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Akun belanja marketplace',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                              onPressed: () => _handleEdit(dev),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                              onPressed: () => _handleDelete(dev),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleAdd,
                icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                label: const Text(
                  'Tambah Device HP Baru',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 38,
        height: 4,
        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}
