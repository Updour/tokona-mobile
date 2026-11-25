import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/product/domain/dtos/create_product_dto.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_dto.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/supplier/domain/dtos/create_supplier_dto.dart';
import 'package:tokona/features/supplier/presentation/controllers/supplier_controller.dart';

class AddPurchasePayloadBuilder {
  static Future<String?> resolveSupplierId({
    required WidgetRef ref,
    required String storeId,
    required String rawSupplierName,
    required String purchaseType,
    required String platform,
    required String? existingSupplierId,
  }) async {
    if (rawSupplierName.isEmpty) return existingSupplierId;
    final suppliers = ref.read(supplierListProvider).suppliers;
    final match = suppliers.where((s) => s.name.trim().toLowerCase() == rawSupplierName.trim().toLowerCase()).firstOrNull;
    if (match != null) return match.id;
    try {
      final created = await ref.read(supplierRepositoryProvider).createSupplier(
        storeId,
        CreateSupplierDto(
          name: rawSupplierName.trim(),
          type: purchaseType,
          platform: purchaseType == 'online' ? platform : null,
        ),
      );
      ref.read(supplierListProvider.notifier).loadSuppliers(storeId);
      return created.id;
    } catch (_) {
      return existingSupplierId;
    }
  }

  static Future<List<CreatePurchaseItemDto>> resolveCoOrderItems({
    required WidgetRef ref,
    required String storeId,
    required ProductModel? selectedProduct,
    required String rawProductName,
    required double qty,
    required double totalCost,
    required double pricePerUnit,
  }) async {
    String prodId;
    String prodName;
    String unitName = 'pcs';

    if (selectedProduct != null) {
      prodId = selectedProduct.id;
      prodName = selectedProduct.name;
      unitName = selectedProduct.baseUnit;
    } else {
      final all = ref.read(productListProvider).products;
      final match = all.where((p) => p.name.trim().toLowerCase() == rawProductName.trim().toLowerCase()).firstOrNull;
      if (match != null) {
        prodId = match.id;
        prodName = match.name;
        unitName = match.baseUnit;
      } else {
        final unitCost = qty > 0 ? (totalCost / qty) : totalCost;
        final sellPrice = pricePerUnit > 0 ? pricePerUnit : unitCost;
        final created = await ref.read(productRepositoryProvider).createProduct(
          storeId,
          CreateProductDto(
            name: rawProductName.trim(),
            baseUnit: 'pcs',
            baseCostPrice: unitCost,
            baseSellingPrice: sellPrice,
            initialStock: 0,
          ),
        );
        prodId = created.id;
        prodName = created.name;
        ref.read(productListProvider.notifier).loadProducts(storeId);
      }
    }

    final unitCost = qty > 0 ? (totalCost / qty) : totalCost;
    return [
      CreatePurchaseItemDto(
        productId: prodId,
        productName: prodName,
        unitName: unitName,
        quantity: qty,
        conversionFactor: 1.0,
        unitCost: unitCost,
      ),
    ];
  }
}
