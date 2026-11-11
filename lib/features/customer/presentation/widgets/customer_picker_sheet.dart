import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/customer/presentation/widgets/add_customer_bottom_sheet.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_anonymous_tile.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_filter_chip_bar.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_picker_empty_state.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_picker_tile.dart';

class CustomerPickerSheet extends ConsumerStatefulWidget {
  final CustomerModel? selectedCustomer;
  final ValueChanged<CustomerModel?> onCustomerSelected;

  const CustomerPickerSheet({
    super.key,
    this.selectedCustomer,
    required this.onCustomerSelected,
  });

  static Future<void> show(
    BuildContext context, {
    CustomerModel? selectedCustomer,
    required ValueChanged<CustomerModel?> onCustomerSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerPickerSheet(
        selectedCustomer: selectedCustomer,
        onCustomerSelected: onCustomerSelected,
      ),
    );
  }

  @override
  ConsumerState<CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends ConsumerState<CustomerPickerSheet> {
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
      if (_selectedFilter != 'all' && c.customerType != _selectedFilter) {
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

  Future<void> _handleAddNewCustomer() async {
    final store = ref.read(authProvider).currentStore;
    if (store == null) return;

    final created = await AddCustomerBottomSheet.show(
      context,
      onCreate: (dto) => ref.read(customerListProvider.notifier).createCustomer(store.id, dto),
    );

    if (created != null && mounted) {
      Navigator.of(context).pop();
      widget.onCustomerSelected(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListProvider);
    final filtered = _filterCustomers(state.customers);

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 16),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
                      Text('Pilih Pelanggan Kasir', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        'Pilih member langganan atau pelanggan grosir',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
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
                        hintText: 'Cari nama pelanggan, no. HP...',
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
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _handleAddNewCustomer,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Baru',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomerFilterChipBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: (key) => setState(() => _selectedFilter = key),
            ),
            const SizedBox(height: 12),
            CustomerAnonymousTile(
              isSelected: widget.selectedCustomer == null,
              onTap: () {
                Navigator.of(context).pop();
                widget.onCustomerSelected(null);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? CustomerPickerEmptyState(searchQuery: _searchQuery)
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (ctx, idx) {
                            final c = filtered[idx];
                            return CustomerPickerTile(
                              customer: c,
                              isSelected: widget.selectedCustomer?.id == c.id,
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onCustomerSelected(c);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
