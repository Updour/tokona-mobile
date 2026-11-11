import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/supplier/domain/models/supplier_model.dart';
import 'package:tokona/features/supplier/presentation/controllers/supplier_controller.dart';
import 'package:tokona/features/supplier/presentation/widgets/add_supplier_bottom_sheet.dart';
import 'package:tokona/features/supplier/presentation/widgets/supplier_card.dart';

class SupplierListBottomSheet extends ConsumerStatefulWidget {
  final ValueChanged<SupplierModel>? onSelect;

  const SupplierListBottomSheet({super.key, this.onSelect});

  static Future<SupplierModel?> show(BuildContext context, {ValueChanged<SupplierModel>? onSelect}) {
    return showModalBottomSheet<SupplierModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SupplierListBottomSheet(onSelect: onSelect),
    );
  }

  @override
  ConsumerState<SupplierListBottomSheet> createState() => _SupplierListBottomSheetState();
}

class _SupplierListBottomSheetState extends ConsumerState<SupplierListBottomSheet> {
  final _searchController = TextEditingController();
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        ref.read(supplierListProvider.notifier).loadSuppliers(storeId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final storeId = ref.read(authProvider).currentStore?.id;
    if (storeId != null) {
      ref.read(supplierListProvider.notifier).loadSuppliers(storeId, type: _selectedType, searchQuery: query);
    }
  }

  void _changeType(String type) {
    setState(() => _selectedType = type);
    final storeId = ref.read(authProvider).currentStore?.id;
    if (storeId != null) {
      ref.read(supplierListProvider.notifier).loadSuppliers(storeId, type: type, searchQuery: _searchController.text);
    }
  }

  Future<void> _handleDelete(String id, String name) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Hapus Supplier',
      message: 'Hapus data supplier "$name"?',
      confirmText: 'Hapus',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed == true) {
      ref.read(supplierListProvider.notifier).deleteSupplier(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierListProvider);
    final storeId = ref.watch(authProvider).currentStore?.id ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Master Supplier & Distributor', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('Daftar distributor resmi dan toko online', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.add_rounded, size: 20),
                tooltip: 'Tambah Supplier',
                onPressed: () => AddSupplierBottomSheet.show(
                  context,
                  onCreate: (dto) => ref.read(supplierListProvider.notifier).createSupplier(storeId, dto),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Cari nama supplier, toko, atau sales...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFilterChip('Semua', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip('Offline', 'offline'),
              const SizedBox(width: 8),
              _buildFilterChip('Online (Marketplace)', 'online'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.suppliers.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: state.suppliers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final s = state.suppliers[idx];
                          return SupplierCard(
                            supplier: s,
                            onTap: () {
                              if (widget.onSelect != null) {
                                widget.onSelect!(s);
                                Navigator.of(context).pop(s);
                              }
                            },
                            onEdit: () => AddSupplierBottomSheet.show(
                              context,
                              supplierToEdit: s,
                              onUpdate: (dto) => ref.read(supplierListProvider.notifier).updateSupplier(s.id, dto),
                            ),
                            onDelete: () => _handleDelete(s.id, s.name),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedType == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
      selected: isSelected,
      onSelected: (_) => _changeType(value),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.business_outlined, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text('Belum Ada Supplier', style: AppTypography.labelMedium),
          const SizedBox(height: 2),
          Text('Tambahkan distributor atau supplier online Anda', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
