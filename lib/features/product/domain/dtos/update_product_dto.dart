import 'package:tokona/features/product/domain/dtos/create_product_price_tier_dto.dart';
import 'package:tokona/features/product/domain/dtos/create_product_unit_dto.dart';

class UpdateProductDto {
  final String name;
  final String? sku;
  final String? category;
  final String productType;
  final String? imagePath;
  final bool clearImage;
  final DateTime? expiredAt;
  final bool clearExpiredAt;
  final String? deviceTag;
  final bool clearDeviceTag;
  final String baseUnit;
  final double? stockBase;
  final double minStockAlert;
  final double baseCostPrice;
  final double baseSellingPrice;
  final List<CreateProductUnitDto> packagingUnits;
  final List<CreateProductPriceTierDto> priceTiers;

  const UpdateProductDto({
    required this.name,
    this.sku,
    this.category,
    this.productType = 'Fisik',
    this.imagePath,
    this.clearImage = false,
    this.expiredAt,
    this.clearExpiredAt = false,
    this.deviceTag,
    this.clearDeviceTag = false,
    this.baseUnit = 'Pcs',
    this.stockBase,
    this.minStockAlert = 0,
    required this.baseCostPrice,
    required this.baseSellingPrice,
    this.packagingUnits = const [],
    this.priceTiers = const [],
  });

  String? validate() {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Nama barang wajib diisi';
    }
    if (trimmedName.length < 3) {
      return 'Nama barang minimal 3 huruf';
    }
    if (baseUnit.trim().isEmpty) {
      return 'Satuan dasar wajib diisi';
    }
    if (baseCostPrice < 0) {
      return 'Harga pokok (HPP) tidak boleh negatif';
    }
    if (baseSellingPrice <= 0) {
      return 'Harga jual harus lebih besar dari 0';
    }
    for (final unit in packagingUnits) {
      final unitError = unit.validate();
      if (unitError != null) return unitError;
    }
    for (final tier in priceTiers) {
      if (tier.minQuantity <= 1) {
        return 'Minimal pembelian harga grosir harus lebih dari 1';
      }
      if (tier.price <= 0) {
        return 'Harga grosir harus lebih besar dari 0';
      }
    }
    return null;
  }
}
