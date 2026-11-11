import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/product/presentation/widgets/product_image_viewer_dialog.dart';

class ProductThumbnailAvatar extends StatelessWidget {
  final String? imagePath;
  final String productName;
  final double size;
  final double borderRadius;
  final bool enableViewer;

  const ProductThumbnailAvatar({
    super.key,
    required this.imagePath,
    required this.productName,
    this.size = 48,
    this.borderRadius = 14,
    this.enableViewer = true,
  });

  bool get _hasValidImage {
    if (imagePath == null || imagePath!.trim().isEmpty) return false;
    try {
      return File(imagePath!).existsSync();
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasValidImage) {
      final imageWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.file(
            File(imagePath!),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackIcon(),
          ),
        ),
      );

      if (enableViewer) {
        return GestureDetector(
          onTap: () => ProductImageViewerDialog.show(
            context,
            imagePath: imagePath!,
            productName: productName,
          ),
          child: imageWidget,
        );
      }

      return imageWidget;
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}
