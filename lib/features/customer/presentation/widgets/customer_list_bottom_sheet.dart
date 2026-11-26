import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/services/native_contact_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/domain/dtos/create_customer_dto.dart';
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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const CustomerListBottomSheet(),
    );
  }

  @override
  ConsumerState<CustomerListBottomSheet> createState() => _CustomerListBottomSheetState();
}

class _CustomerListBottomSheetState extends ConsumerState<CustomerListBottomSheet> {
  final _searchController = TextEditingController();
  bool _isSearchVisible = false;
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

  Future<void> _handleImportContact(String storeId) async {
    final picked = await NativeContactService.pickContact();
    if (picked == null || !mounted) return;
    final existing = ref.read(customerListProvider).customers;
    final isDup = existing.any((c) =>
        (picked.phone.isNotEmpty && c.phone?.trim() == picked.phone) ||
        c.name.trim().toLowerCase() == picked.name.trim().toLowerCase());
    if (isDup) {
      AppToast.showWarning(context, 'Kontak "${picked.name}" sudah terdaftar');
      return;
    }
    final created = await ref.read(customerListProvider.notifier).createCustomer(
          storeId,
          CreateCustomerDto(name: picked.name, phone: picked.phone.isEmpty ? null : picked.phone),
        );
    if (!mounted) return;
    if (created != null) {
      AppToast.showSuccess(context, '"${created.name}" disimpan ke data pelanggan');
    }
  }

  Future<void> _handleDelete(CustomerModel customer) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Hapus Pelanggan',
      message: 'Hapus data "${customer.name}"? Riwayat kasbon ikut terhapus.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed == true && mounted) {
      final ok = await ref.read(customerListProvider.notifier).deleteCustomer(customer.id);
      if (mounted && ok) {
        AppToast.showSuccess(context, 'Data pelanggan dihapus');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authProvider).currentStore;
    final state = ref.watch(customerListProvider);
    final filtered = _filterCustomers(state.customers);
    final totalKasbon = state.customers.fold<double>(0.0, (acc, c) => acc + c.receivableBalance);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Color(0x180F172A), blurRadius: 28, offset: Offset(0, -6)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 14),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(color: const Color(0xFFCBD5E1).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text('Pelanggan', style: AppTypography.headingSmall.copyWith(fontSize: 16, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                      child: Text('${filtered.length}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isSearchVisible ? Icons.search_off_rounded : Icons.search_rounded, color: _isSearchVisible ? AppColors.primary : const Color(0xFF64748B), size: 19),
                tooltip: 'Cari',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                onPressed: () {
                  setState(() {
                    _isSearchVisible = !_isSearchVisible;
                    if (!_isSearchVisible && _searchQuery.isNotEmpty) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.contact_phone_rounded, color: Color(0xFF0D9488), size: 18),
                tooltip: 'Import Kontak',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                onPressed: store == null ? null : () => _handleImportContact(store.id),
              ),
              const SizedBox(width: 3),
              InkWell(
                onTap: store == null
                    ? null
                    : () => AddCustomerBottomSheet.show(
                          context,
                          onCreate: (dto) => ref.read(customerListProvider.notifier).createCustomer(store.id, dto),
                        ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_rounded, size: 12, color: Colors.white),
                      SizedBox(width: 2),
                      Text('Tambah', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 19),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          if (_isSearchVisible) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cari nama, no. HP, alamat...',
                  hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 15, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          CustomerKasbonBanner(
            totalKasbon: totalKasbon,
            onTap: () => setState(() => _selectedFilter = 'kasbon'),
          ),
          CustomerFilterChipBar(
            selectedFilter: _selectedFilter,
            onFilterChanged: (key) => setState(() => _selectedFilter = key),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (ctx, idx) {
                          final c = filtered[idx];
                          return CustomerCard(
                            customer: c,
                            onEdit: () => AddCustomerBottomSheet.show(
                              context,
                              customerToEdit: c,
                              onUpdate: (dto) => ref.read(customerListProvider.notifier).updateCustomer(c.id, dto),
                            ),
                            onDelete: () => _handleDelete(c),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline_rounded, size: 36, color: Color(0xFF94A3B8)),
          const SizedBox(height: 6),
          Text(_searchQuery.isNotEmpty ? 'Pelanggan Tidak Ditemukan' : 'Belum Ada Pelanggan', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(_searchQuery.isNotEmpty ? 'Tidak ada hasil untuk "$_searchQuery"' : 'Gunakan tombol Tambah atau Import Kontak', style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
