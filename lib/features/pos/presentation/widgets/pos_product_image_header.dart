import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';

class PosProductImageHeader extends StatelessWidget {
  final ProductModel product;
  final double inCartQty;
  final double? height;

  const PosProductImageHeader({
    super.key,
    required this.product,
    required this.inCartQty,
    this.height,
  });

  bool get _hasValidImage {
    final path = product.imagePath;
    if (path == null || path.trim().isEmpty) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  IconData _getCategoryIcon(String? category) {
    final cat = category?.toLowerCase().trim() ?? '';
    if (cat.contains('makan') || cat.contains('food')) return Icons.restaurant_rounded;
    if (cat.contains('minum') || cat.contains('drink')) return Icons.local_drink_rounded;
    if (cat.contains('snack')) return Icons.cookie_outlined;
    if (cat.contains('rokok')) return Icons.smoking_rooms_outlined;
    if (cat.contains('sembako') || cat.contains('bumbu')) return Icons.shopping_bag_outlined;
    return Icons.inventory_2_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final p = product;
    final isInCart = inCartQty > 0;

    final imageWidget = Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: _hasValidImage
              ? Image.file(
                  File(p.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(p),
                )
              : _buildPlaceholder(p),
        ),
        Positioned(
          top: 7,
          left: 7,
          child: _buildStockBadge(p),
        ),
        if (isInCart)
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_bag_rounded, size: 11, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(
                    '${inCartQty.toStringAsFixed(0)}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    if (height != null) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: imageWidget,
      );
    }

    return SizedBox(
      width: double.infinity,
      child: imageWidget,
    );
  }

  Widget _buildPlaceholder(ProductModel p) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceElevated,
            AppColors.primaryContainer.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getCategoryIcon(p.category),
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge(ProductModel p) {
    Color bg;
    Color fg;
    String label;

    if (p.stockBase <= 0) {
      bg = AppColors.error;
      fg = Colors.white;
      label = 'Habis';
    } else if (p.stockBase <= p.minStockAlert) {
      bg = const Color(0xFFD97706);
      fg = Colors.white;
      label = 'Sisa ${p.stockBase.toStringAsFixed(0)}';
    } else {
      bg = Colors.black.withValues(alpha: 0.65);
      fg = Colors.white;
      label = 'Stok ${p.stockBase.toStringAsFixed(0)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

