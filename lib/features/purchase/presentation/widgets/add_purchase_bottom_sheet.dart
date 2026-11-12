import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/proof_photo_picker.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_dto.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_purchase_header.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_channel_selector.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_device_chips.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_fee_inputs.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_item_list_section.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_payment_account_chips.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_product_selector.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_status_selector.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_submit_button.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_summary_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_supplier_field.dart';
import 'package:tokona/features/supplier/domain/dtos/create_supplier_dto.dart';
import 'package:tokona/features/supplier/domain/models/supplier_model.dart';
import 'package:tokona/features/supplier/presentation/controllers/supplier_controller.dart';

class AddPurchaseBottomSheet extends ConsumerStatefulWidget {
  const AddPurchaseBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddPurchaseBottomSheet(),
    );
  }

  @override
  ConsumerState<AddPurchaseBottomSheet> createState() => _AddPurchaseBottomSheetState();
}

class _AddPurchaseBottomSheetState extends ConsumerState<AddPurchaseBottomSheet> {
  final _supplierController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _notesController = TextEditingController();
  final _serviceFeeController = TextEditingController();
  final _shippingFeeController = TextEditingController();

  String? _supplierId;
  String _purchaseType = 'offline';
  String _platform = 'Shopee';
  String _deviceTag = 'HP 1';
  String _paymentAccount = 'SeaBank';
  String _status = 'received';
  String? _proofImagePath;
  int _poDays = 3;

  final List<CreatePurchaseItemDto> _items = [];
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = ref.read(authProvider).currentStore;
      if (store != null) ref.read(supplierListProvider.notifier).loadSuppliers(store.id);
    });
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _invoiceController.dispose();
    _notesController.dispose();
    _serviceFeeController.dispose();
    _shippingFeeController.dispose();
    super.dispose();
  }

  double get _itemsTotal => _items.fold(0.0, (acc, item) => acc + item.subtotal);
  double get _serviceFee => CurrencyFormatter.parse(_serviceFeeController.text);
  double get _shippingFee => CurrencyFormatter.parse(_shippingFeeController.text);

  Future<void> _handleSubmit() async {
    final authState = ref.read(authProvider);
    final store = authState.currentStore;
    final user = authState.currentUser;

    if (store == null || user == null) {
      AppToast.showError(context, 'Sesi toko tidak ditemukan. Silakan login kembali.');
      return;
    }
    if (_items.isEmpty) {
      AppToast.showWarning(context, 'Pilih minimal 1 barang belanjaan');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      String? effectiveSupplierId = _supplierId;
      final rawSupplierName = _supplierController.text.trim();
      if (rawSupplierName.isNotEmpty) {
        final suppliers = ref.read(supplierListProvider).suppliers;
        final match = suppliers.where((s) => s.name.trim().toLowerCase() == rawSupplierName.toLowerCase()).firstOrNull;
        if (match != null) {
          effectiveSupplierId = match.id;
        } else {
          try {
            final created = await ref.read(supplierRepositoryProvider).createSupplier(
              store.id,
              CreateSupplierDto(
                name: rawSupplierName,
                type: _purchaseType,
                platform: _purchaseType == 'online' ? _platform : null,
              ),
            );
            effectiveSupplierId = created.id;
            ref.read(supplierListProvider.notifier).loadSuppliers(store.id);
          } catch (_) {}
        }
      }

      final dto = CreatePurchaseDto(
        storeId: store.id, userId: user.id,
        invoiceNumber: _invoiceController.text.trim().isEmpty ? null : _invoiceController.text.trim(),
        supplierId: effectiveSupplierId, supplierName: rawSupplierName.isEmpty ? null : rawSupplierName,
        purchaseType: _purchaseType, platform: _purchaseType == 'online' ? _platform : null,
        deviceTag: _purchaseType == 'online' ? _deviceTag : null, paymentAccount: _paymentAccount,
        serviceFee: _serviceFee, shippingFee: _shippingFee, status: _status,
        poDays: _status == 'pre_order' ? _poDays : null,
        estimatedArrival: _status == 'pre_order' ? DateTime.now().add(Duration(days: _poDays)) : null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        imagePath: _proofImagePath,
        items: _items,
      );

      final result = await ref.read(purchaseControllerProvider.notifier).recordPurchase(dto);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (result != null) {
        final msg = _status == 'received' ? 'Pembelian berhasil disimpan.' : 'Pesanan dicatat via $_paymentAccount ($_deviceTag).';
        AppToast.showSuccess(context, msg);
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop();
      } else {
        final errorMsg = ref.read(purchaseControllerProvider).errorMessage ?? 'Gagal menyimpan pembelian';
        setState(() => _errorMessage = errorMsg);
        AppToast.showError(context, errorMsg);
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isSubmitting = false; _errorMessage = e.toString(); });
        AppToast.showError(context, 'Terjadi kendala: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider).products;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AddPurchaseHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PurchaseChannelSelector(
                      purchaseType: _purchaseType,
                      platform: _platform,
                      onTypeChanged: (type) => setState(() => _purchaseType = type),
                      onPlatformChanged: (p) => setState(() => _platform = p),
                    ),
                    const SizedBox(height: 12),
                    PurchaseSupplierField(
                      controller: _supplierController,
                      purchaseType: _purchaseType,
                      onSupplierSelected: (selected) {
                        setState(() {
                          _supplierId = selected.id;
                          _supplierController.text = selected.name;
                          _purchaseType = selected.type;
                          if (selected.platform != null) _platform = selected.platform!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _invoiceController,
                      decoration: const InputDecoration(
                        labelText: 'No. Faktur / Nota Toko (Opsional)',
                        hintText: 'Otomatis: INV-[TOKO]-[PRODUK]-[ACAK]',
                        prefixIcon: Icon(Icons.receipt_outlined, size: 20),
                      ),
                    ),
                    if (_purchaseType == 'online') ...[
                      const SizedBox(height: 12),
                      PurchaseDeviceChips(selectedDevice: _deviceTag, onDeviceSelected: (d) => setState(() => _deviceTag = d)),
                    ],
                    const SizedBox(height: 12),
                    PurchasePaymentAccountChips(selectedAccount: _paymentAccount, onAccountSelected: (acc) => setState(() => _paymentAccount = acc)),
                    const SizedBox(height: 14),
                    PurchaseStatusSelector(
                      status: _status,
                      poDays: _poDays,
                      onStatusChanged: (s) => setState(() => _status = s),
                      onPoDaysChanged: (d) => setState(() => _poDays = d),
                    ),
                    const SizedBox(height: 14),
                    PurchaseProductSelector(products: products, onAddItem: (item) => setState(() => _items.add(item))),
                    PurchaseItemListSection(
                      items: _items,
                      onEditItem: (idx, updated) => setState(() => _items[idx] = updated),
                      onRemoveItem: (idx) => setState(() => _items.removeAt(idx)),
                    ),
                    if (_purchaseType == 'online') ...[
                      const SizedBox(height: 12),
                      PurchaseFeeInputs(
                        serviceFeeController: _serviceFeeController,
                        shippingFeeController: _shippingFeeController,
                        onChanged: () => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: 14),
                    PurchaseSummaryCard(
                      itemsTotal: _itemsTotal,
                      serviceFee: _serviceFee,
                      shippingFee: _shippingFee,
                      isOnline: _purchaseType == 'online',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        hintText: 'Nomor pesanan faktur distributor',
                        prefixIcon: Icon(Icons.description_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ProofPhotoPicker(
                      imagePath: _proofImagePath,
                      label: _purchaseType == 'online' ? 'Foto Bukti Nota / Faktur Marketplace' : 'Foto Nota Faktur / Fisik Barang',
                      hint: 'Ambil foto kamera atau pilih galeri (opsional)',
                      onImagePicked: (p) => setState(() => _proofImagePath = p),
                    ),
                    const SizedBox(height: 16),
                    PurchaseSubmitButton(
                      isSubmitting: _isSubmitting,
                      errorMessage: _errorMessage,
                      onSubmit: _handleSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
