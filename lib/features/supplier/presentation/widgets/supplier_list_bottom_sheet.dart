import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/modern_sheet_widgets.dart';
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
  bool _isSearchVisible = false;
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Color(0x180F172A), blurRadius: 28, offset: Offset(0, -6)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModernSheetHeader(
            title: 'Supplier',
            subtitle: '${state.suppliers.length} rekanan terdaftar',
            icon: Icons.local_shipping_rounded,
            onClose: () => Navigator.of(context).pop(),
            trailingAction: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isSearchVisible ? Icons.search_off_rounded : Icons.search_rounded,
                    color: _isSearchVisible ? AppColors.primary : const Color(0xFF64748B),
                    size: 20,
                  ),
                  tooltip: 'Cari',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    setState(() {
                      _isSearchVisible = !_isSearchVisible;
                      if (!_isSearchVisible && _searchController.text.isNotEmpty) {
                        _searchController.clear();
                        _onSearch('');
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person_add_rounded, color: AppColors.primary, size: 20),
                  tooltip: 'Tambah',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => AddSupplierBottomSheet.show(
                    context,
                    onCreate: (dto) => ref.read(supplierListProvider.notifier).createSupplier(storeId, dto),
                  ),
                ),
              ],
            ),
          ),
          if (_isSearchVisible) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              autofocus: true,
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
          ],
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
