import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_dto.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_purchase_header.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_purchase_payload_builder.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_channel_selector.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_co_order_form.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_regular_form.dart';
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
  final _supplierController = TextEditingController(), _invoiceController = TextEditingController();
  final _notesController = TextEditingController(), _serviceFeeController = TextEditingController();
  final _shippingFeeController = TextEditingController(), _installmentController = TextEditingController();
  final _shippingDiscountController = TextEditingController(), _voucherDiscountController = TextEditingController();
  final _coPartnerController = TextEditingController(), _coProfitController = TextEditingController();
  final _coProductNameController = TextEditingController(), _coQtyController = TextEditingController(text: '1');
  final _coCostController = TextEditingController(), _coPricePerUnitController = TextEditingController();
  final _coTotalReceivedController = TextEditingController(), _coTrackingController = TextEditingController(), _coNotesController = TextEditingController();
  ProductModel? _coSelectedProduct;

  String? _supplierId;
  String _purchaseType = 'offline', _platform = 'Shopee', _deviceTag = 'HP 1', _paymentAccount = 'SeaBank', _status = 'received';
  String? _proofImagePath;
  int _poDays = 3, _installmentMonths = 1;
  DateTime? _estArrivalStart, _estArrivalEnd;
  bool _addToStock = false, _isFundedByPartner = true, _isSubmitting = false;
  final List<CreatePurchaseItemDto> _items = [];
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
    for (final c in [
      _supplierController, _invoiceController, _notesController, _serviceFeeController,
      _shippingFeeController, _shippingDiscountController, _voucherDiscountController,
      _installmentController, _coPartnerController, _coProfitController,
      _coProductNameController, _coQtyController, _coCostController,
      _coPricePerUnitController, _coTotalReceivedController, _coTrackingController, _coNotesController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double get _itemsTotal => _items.fold(0.0, (acc, item) => acc + item.subtotal);
  double get _serviceFee => CurrencyFormatter.parse(_serviceFeeController.text);
  double get _shippingFee => CurrencyFormatter.parse(_shippingFeeController.text);
  double get _shippingDiscount => CurrencyFormatter.parse(_shippingDiscountController.text);
  double get _voucherDiscount => CurrencyFormatter.parse(_voucherDiscountController.text);

  double get _coQty => double.tryParse(_coQtyController.text) ?? 1.0;
  double get _coTotalCost => CurrencyFormatter.parse(_coCostController.text);
  double get _coPricePerUnit => CurrencyFormatter.parse(_coPricePerUnitController.text);
  double get _coTotalReceived => CurrencyFormatter.parse(_coTotalReceivedController.text);
  double get _coProfit => _coTotalReceived - _coTotalCost;
  double get _coMarginPct => _coTotalReceived > 0 ? (_coProfit / _coTotalReceived) * 100 : 0.0;

  void _onCoPriceChanged(String val) {
    _coTotalReceivedController.text = CurrencyFormatter.formatNumber(_coQty * CurrencyFormatter.parse(val));
    setState(() {});
  }

  void _onCoTotalChanged(String val) {
    final t = CurrencyFormatter.parse(val);
    _coPricePerUnitController.text = CurrencyFormatter.formatNumber(_coQty > 0 ? (t / _coQty) : 0.0);
    setState(() {});
  }

  void _onCoQtyChanged(String val) {
    final q = double.tryParse(val) ?? 1.0;
    final p = CurrencyFormatter.parse(_coPricePerUnitController.text);
    if (p > 0) _coTotalReceivedController.text = CurrencyFormatter.formatNumber(q * p);
    setState(() {});
  }

  Future<void> _handleSubmit() async {
    final auth = ref.read(authProvider);
    final store = auth.currentStore;
    final user = auth.currentUser;
    if (store == null || user == null) return AppToast.showError(context, 'Sesi toko tidak ditemukan.');

    final isCo = _purchaseType == 'co_order';
    if (isCo) {
      if (_coPartnerController.text.trim().isEmpty) return AppToast.showWarning(context, 'Masukkan nama rekan');
      if (_coProductNameController.text.trim().isEmpty && _coSelectedProduct == null) return AppToast.showWarning(context, 'Masukkan nama barang');
      if (_coTotalCost <= 0) return AppToast.showWarning(context, 'Masukkan modal belanja checkout');
    } else if (_items.isEmpty) {
      return AppToast.showWarning(context, 'Pilih minimal 1 barang belanjaan');
    }

    setState(() { _isSubmitting = true; _errorMessage = null; });
    try {
      final supId = isCo ? null : await AddPurchasePayloadBuilder.resolveSupplierId(
        ref: ref, storeId: store.id, rawSupplierName: _supplierController.text.trim(),
        purchaseType: _purchaseType, platform: _platform, existingSupplierId: _supplierId,
      );
      final effItems = isCo ? await AddPurchasePayloadBuilder.resolveCoOrderItems(
        ref: ref, storeId: store.id, selectedProduct: _coSelectedProduct,
        rawProductName: _coProductNameController.text.trim(), qty: _coQty,
        totalCost: _coTotalCost, pricePerUnit: _coPricePerUnit,
      ) : List<CreatePurchaseItemDto>.from(_items);

      final isOnlineOrCo = _purchaseType == 'online' || isCo;
      final dto = CreatePurchaseDto(
        storeId: store.id, userId: user.id,
        invoiceNumber: isCo ? null : (_invoiceController.text.trim().isEmpty ? null : _invoiceController.text.trim()),
        supplierId: supId,
        supplierName: isCo ? '$_platform (Co-Order)' : (_supplierController.text.trim().isEmpty ? null : _supplierController.text.trim()),
        purchaseType: _purchaseType, platform: isOnlineOrCo ? _platform : null,
        deviceTag: isOnlineOrCo ? _deviceTag : null,
        paymentAccount: (isCo && _isFundedByPartner) ? 'Dana Rekan' : _paymentAccount,
        serviceFee: isCo ? 0.0 : _serviceFee, shippingFee: isCo ? 0.0 : _shippingFee,
        status: isCo ? 'shipping' : _status,
        poDays: isCo ? null : (_status == 'pre_order' ? _poDays : null),
        estimatedArrival: _status != 'received' ? (_estArrivalStart ?? DateTime.now().add(Duration(days: _status == 'pre_order' ? _poDays : 2))) : null,
        estimatedArrivalEnd: _status != 'received' ? (_estArrivalEnd ?? DateTime.now().add(Duration(days: _status == 'pre_order' ? _poDays + 3 : 4))) : null,
        notes: isCo ? (_coNotesController.text.trim().isEmpty ? null : _coNotesController.text.trim()) : (_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
        imagePath: isCo ? null : _proofImagePath,
        trackingNumber: isCo ? (_coTrackingController.text.trim().isEmpty ? null : _coTrackingController.text.trim()) : null,
        installmentMonths: isCo ? 1 : _installmentMonths,
        monthlyInstallment: isCo ? 0.0 : CurrencyFormatter.parse(_installmentController.text),
        coPartner: isCo ? _coPartnerController.text.trim() : null,
        coProfit: isCo ? _coProfit : CurrencyFormatter.parse(_coProfitController.text),
        addToStock: isCo ? _addToStock : true,
        shippingDiscount: isCo ? 0.0 : _shippingDiscount, voucherDiscount: isCo ? 0.0 : _voucherDiscount,
        items: effItems,
      );

      final res = await ref.read(purchaseControllerProvider.notifier).recordPurchase(dto);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (res != null) {
        AppToast.showSuccess(context, isCo ? 'Co-Order Rekan berhasil dicatat!' : 'Pembelian berhasil disimpan.');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.of(context).pop();
      } else {
        final err = ref.read(purchaseControllerProvider).errorMessage ?? 'Gagal menyimpan';
        setState(() => _errorMessage = err);
        AppToast.showError(context, err);
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
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                      purchaseType: _purchaseType, platform: _platform,
                      onTypeChanged: (t) => setState(() {
                        _purchaseType = t;
                        if (t == 'co_order') {
                          _addToStock = false; _isFundedByPartner = true;
                          if (_status == 'received') _status = 'shipping';
                        }
                      }),
                      onPlatformChanged: (p) => setState(() => _platform = p),
                    ),
                    const SizedBox(height: 14),
                    if (_purchaseType == 'co_order')
                      PurchaseCoOrderForm(
                        products: products,
                        coPartnerController: _coPartnerController, coTrackingController: _coTrackingController,
                        platform: _platform, onPlatformChanged: (p) => setState(() => _platform = p),
                        coProductNameController: _coProductNameController, coSelectedProduct: _coSelectedProduct,
                        onProductSelected: (p) => setState(() {
                          _coSelectedProduct = p;
                          if (p != null) {
                            _coProductNameController.text = p.name;
                            if (p.baseCostPrice > 0 && _coCostController.text.isEmpty) {
                              _coCostController.text = CurrencyFormatter.formatNumber(p.baseCostPrice * _coQty);
                            }
                            if (p.baseSellingPrice > 0 && _coPricePerUnitController.text.isEmpty) {
                              _coPricePerUnitController.text = CurrencyFormatter.formatNumber(p.baseSellingPrice);
                              _onCoPriceChanged(_coPricePerUnitController.text);
                            }
                          }
                        }),
                        coQtyController: _coQtyController, coCostController: _coCostController,
                        coPricePerUnitController: _coPricePerUnitController, coTotalReceivedController: _coTotalReceivedController,
                        coQty: _coQty, coTotalCost: _coTotalCost, coTotalReceived: _coTotalReceived,
                        coProfit: _coProfit, coMarginPercent: _coMarginPct,
                        isFundedByPartner: _isFundedByPartner, onFundedChanged: (v) => setState(() => _isFundedByPartner = v),
                        addToStock: _addToStock, onAddToStockChanged: (v) => setState(() => _addToStock = v),
                        coNotesController: _coNotesController, isSubmitting: _isSubmitting,
                        isFormValid: _coPartnerController.text.trim().isNotEmpty && (_coProductNameController.text.trim().isNotEmpty || _coSelectedProduct != null) && _coTotalCost > 0,
                        onSubmit: _handleSubmit, onQtyChanged: _onCoQtyChanged,
                        onPricePerUnitChanged: _onCoPriceChanged, onTotalReceivedChanged: _onCoTotalChanged,
                      )
                    else
                      PurchaseRegularForm(
                        supplierController: _supplierController, purchaseType: _purchaseType,
                        onSupplierSelected: (s) => setState(() {
                          _supplierId = s.id; _supplierController.text = s.name;
                          _purchaseType = s.type; if (s.platform != null) _platform = s.platform!;
                        }),
                        invoiceController: _invoiceController, deviceTag: _deviceTag,
                        onDeviceSelected: (d) => setState(() => _deviceTag = d),
                        paymentAccount: _paymentAccount, onAccountSelected: (a) => setState(() => _paymentAccount = a),
                        installmentMonths: _installmentMonths, installmentController: _installmentController,
                        onTenorChanged: (t) => setState(() {
                          _installmentMonths = t;
                          if (t > 1 && _installmentController.text.isEmpty && _itemsTotal > 0) {
                            final est = ((_itemsTotal + _serviceFee + _shippingFee) * (1.0 + (0.0295 * t))) / t;
                            _installmentController.text = CurrencyFormatter.formatNumber(est);
                          }
                        }),
                        onInstallmentChanged: () => setState(() {}),
                        status: _status, poDays: _poDays,
                        onStatusChanged: (s) => setState(() {
                          _status = s; final now = DateTime.now();
                          if (s == 'shipping' && _estArrivalStart == null) {
                            _estArrivalStart = now.add(const Duration(days: 2)); _estArrivalEnd = now.add(const Duration(days: 4));
                          } else if (s == 'pre_order' && _estArrivalStart == null) {
                            _estArrivalStart = now.add(Duration(days: _poDays)); _estArrivalEnd = now.add(Duration(days: _poDays + 3));
                          }
                        }),
                        onPoDaysChanged: (d) => setState(() => _poDays = d),
                        estArrivalStart: _estArrivalStart, estArrivalEnd: _estArrivalEnd,
                        onRangeChanged: (r) { if (r != null) setState(() { _estArrivalStart = r.start; _estArrivalEnd = r.end; }); },
                        products: products, items: _items,
                        onAddItem: (i) => setState(() => _items.add(i)),
                        onEditItem: (idx, u) => setState(() => _items[idx] = u),
                        onRemoveItem: (idx) => setState(() => _items.removeAt(idx)),
                        serviceFeeController: _serviceFeeController, shippingFeeController: _shippingFeeController,
                        shippingDiscountController: _shippingDiscountController, voucherDiscountController: _voucherDiscountController,
                        onMarketplaceFeesChanged: () => setState(() {}),
                        itemsTotal: _itemsTotal, serviceFee: _serviceFee, shippingFee: _shippingFee,
                        shippingDiscount: _shippingDiscount, voucherDiscount: _voucherDiscount,
                        notesController: _notesController, proofImagePath: _proofImagePath,
                        onImagePicked: (p) => setState(() => _proofImagePath = p),
                        isSubmitting: _isSubmitting, errorMessage: _errorMessage, onSubmit: _handleSubmit,
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
