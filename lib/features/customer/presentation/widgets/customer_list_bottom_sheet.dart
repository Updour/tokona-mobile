import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/customer/presentation/widgets/add_customer_bottom_sheet.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_card.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_filter_chip_bar.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_kasbon_banner.dart';

class CustomerListBottomSheet extends ConsumerStatefulWidget {
  const CustomerListBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomerListBottomSheet(),
    );
  }

  @override
  ConsumerState<CustomerListBottomSheet> createState() => _CustomerListBottomSheetState();
}

class _CustomerListBottomSheetState extends ConsumerState<CustomerListBottomSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = ref.read(authProvider).currentStore;
      if (store != null) {
        ref.read(customerListProvider.notifier).loadCustomers(store.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerModel> _filterCustomers(List<CustomerModel> list) {
    return list.where((c) {
      if (_selectedFilter == 'kasbon') {
        if (!c.hasReceivable) return false;
      } else if (_selectedFilter != 'all' && c.customerType != _selectedFilter) {
        return false;
      }
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      final nameMatch = c.name.toLowerCase().contains(q);
      final phoneMatch = c.phone != null && c.phone!.toLowerCase().contains(q);
      final addressMatch = c.address != null && c.address!.toLowerCase().contains(q);
      return nameMatch || phoneMatch || addressMatch;
    }).toList();
  }

  Future<void> _handleDelete(CustomerModel customer) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Hapus Pelanggan',
      message: 'Apakah Anda yakin ingin menghapus data "${customer.name}"? Riwayat kasbon akan ikut terhapus.',
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed == true && mounted) {
      final ok = await ref.read(customerListProvider.notifier).deleteCustomer(customer.id);
      if (mounted && ok) {
        AppToast.showSuccess(context, 'Data pelanggan berhasil dihapus');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authProvider).currentStore;
    final state = ref.watch(customerListProvider);
    final filtered = _filterCustomers(state.customers);
    final totalKasbon = state.customers.fold<double>(0.0, (acc, c) => acc + c.receivableBalance);

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 16),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data Pelanggan', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        'Kelola langganan toko, member, dan piutang kasbon',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: store == null
                      ? null
                      : () => AddCustomerBottomSheet.show(
                            context,
                            onCreate: (dto) => ref
                                .read(customerListProvider.notifier)
                                .createCustomer(store.id, dto),
                          ),
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Tambah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            CustomerKasbonBanner(
              totalKasbon: totalKasbon,
              onTap: () => setState(() => _selectedFilter = 'kasbon'),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Cari nama, no. HP, atau alamat...',
                  hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                ),
              ),
            ),
            const SizedBox(height: 10),
            CustomerFilterChipBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: (key) => setState(() => _selectedFilter = key),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final c = filtered[idx];
                            return CustomerCard(
                              customer: c,
                              onEdit: () => AddCustomerBottomSheet.show(
                                context,
                                customerToEdit: c,
                                onUpdate: (dto) => ref
                                    .read(customerListProvider.notifier)
                                    .updateCustomer(c.id, dto),
                              ),
                              onDelete: () => _handleDelete(c),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline_rounded, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ? 'Pelanggan Tidak Ditemukan' : 'Belum Ada Pelanggan',
            style: AppTypography.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tidak ada pelanggan yang cocok dengan "$_searchQuery"'
                : 'Tekan "+ Tambah" di atas untuk mendaftarkan pelanggan pertama',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
