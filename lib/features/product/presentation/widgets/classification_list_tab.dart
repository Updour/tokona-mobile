import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/product/presentation/controllers/classification_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';

class ClassificationListTab extends ConsumerWidget {
  final List<String> items;
  final List<String> defaultList;
  final bool isCategory;
  final String storeId;

  const ClassificationListTab({
    super.key,
    required this.items,
    required this.defaultList,
    required this.isCategory,
    required this.storeId,
  });

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isCategory ? 'Tambah Kategori' : 'Tambah Tipe Barang', style: AppTypography.headingSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isCategory ? 'Contoh: Makanan, Minuman' : 'Contoh: Titipan, Konsinyasi',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border)),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      final notifier = ref.read(classificationProvider.notifier);
      if (isCategory) {
        await notifier.addCategory(storeId, result);
        if (context.mounted) AppToast.showSuccess(context, 'Kategori $result berhasil ditambahkan');
      } else {
        await notifier.addProductType(storeId, result);
        if (context.mounted) AppToast.showSuccess(context, 'Tipe $result berhasil ditambahkan');
      }
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isCategory ? 'Edit Kategori' : 'Edit Tipe Barang', style: AppTypography.headingSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border)),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentName && context.mounted) {
      final notifier = ref.read(classificationProvider.notifier);
      if (isCategory) {
        await notifier.updateCategory(storeId, currentName, result);
        if (context.mounted) AppToast.showSuccess(context, 'Kategori diperbarui menjadi $result');
      } else {
        await notifier.updateProductType(storeId, currentName, result);
        if (context.mounted) AppToast.showSuccess(context, 'Tipe barang diperbarui menjadi $result');
      }
      ref.read(productListProvider.notifier).loadProducts(storeId);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String name) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: isCategory ? 'Hapus Kategori' : 'Hapus Tipe Barang',
      message: 'Hapus "$name"? Produk dengan klasifikasi ini akan diubah ke default.',
      confirmText: 'Hapus',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final notifier = ref.read(classificationProvider.notifier);
      if (isCategory) {
        await notifier.deleteCategory(storeId, name);
        if (context.mounted) AppToast.showSuccess(context, 'Kategori $name dihapus');
      } else {
        await notifier.deleteProductType(storeId, name);
        if (context.mounted) AppToast.showSuccess(context, 'Tipe barang $name dihapus');
      }
      ref.read(productListProvider.notifier).loadProducts(storeId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${items.length} ${isCategory ? "kategori" : "tipe"} terdaftar',
              style: AppTypography.bodySmall.copyWith(fontSize: 11.5, color: AppColors.textSecondary),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.add_rounded, size: 15, color: Colors.white),
              label: Text(
                isCategory ? 'Tambah Kategori' : 'Tambah Tipe',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final name = items[index];
              final isDefault = defaultList.contains(name);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDefault ? AppColors.surface : const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                      ),
                      child: Icon(
                        isCategory ? Icons.category_rounded : Icons.style_rounded,
                        size: 17,
                        color: isDefault ? AppColors.textSecondary : const Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isDefault ? AppColors.surface : const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDefault ? 'Bawaan' : 'Kustom',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isDefault ? AppColors.textSecondary : const Color(0xFF0F766E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: () => _showEditDialog(context, ref, name),
                    ),
                    if (!isDefault)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        onPressed: () => _confirmDelete(context, ref, name),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
