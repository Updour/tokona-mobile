import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/product/data/services/product_image_service.dart';
import 'package:tokona/features/product/presentation/widgets/product_image_viewer_dialog.dart';
import 'package:tokona/features/product/presentation/widgets/product_photo_picker_sheet.dart';

class ProductImagePickerWidget extends StatefulWidget {
  final String? imagePath;
  final ValueChanged<String> onImageSelected;
  final VoidCallback onImageRemoved;
  final String productName;

  const ProductImagePickerWidget({
    super.key,
    required this.imagePath,
    required this.onImageSelected,
    required this.onImageRemoved,
    this.productName = 'Foto Produk',
  });

  @override
  State<ProductImagePickerWidget> createState() => _ProductImagePickerWidgetState();
}

class _ProductImagePickerWidgetState extends State<ProductImagePickerWidget> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLostData();
  }

  Future<void> _checkLostData() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final picker = ImagePicker();
      final response = await picker.retrieveLostData();
      if (!response.isEmpty && response.file != null) {
        final savedPath = await ProductImageService.saveImageLocally(response.file!);
        if (savedPath != null && mounted) {
          widget.onImageSelected(savedPath);
        }
      }
    } catch (_) {}
  }

  bool get _hasImage {
    if (widget.imagePath == null || widget.imagePath!.trim().isEmpty) return false;
    try {
      return File(widget.imagePath!).existsSync();
    } catch (_) {
      return false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final path = await ProductImageService.pickAndSaveImage(source);
      if (path != null && mounted) {
        widget.onImageSelected(path);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        final isDenied = e.code.contains('denied') || (e.message?.toLowerCase().contains('permission') ?? false);
        final message = isDenied
            ? 'Izin kamera atau galeri belum diberikan. Aktifkan izin di Pengaturan aplikasi.'
            : 'Tidak dapat membuka kamera atau galeri.';
        AppToast.showError(context, message);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Gagal mengambil gambar: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSourceDialog(BuildContext context) async {
    final source = await ProductPhotoPickerSheet.show(
      context,
      hasExistingImage: _hasImage,
      onRemove: widget.onImageRemoved,
    );

    if (source != null && mounted) {
      await _pickImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasImage) {
      return _buildImagePreviewCard();
    }
    return _buildEmptyPickerCard();
  }

  Widget _buildEmptyPickerCard() {
    return InkWell(
      onTap: _isLoading ? null : () => _showSourceDialog(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_a_photo_outlined, size: 20, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Foto Produk (Opsional)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ambil foto dari kamera atau galeri',
                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviewCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ProductImageViewerDialog.show(
              context,
              imagePath: widget.imagePath!,
              productName: widget.productName,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(widget.imagePath!),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Foto Produk Terpasang', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text('Ketuk foto untuk melihat layar penuh', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
            tooltip: 'Ganti Foto',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isLoading ? null : () => _showSourceDialog(context),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded, size: 18, color: AppColors.error),
            tooltip: 'Hapus Foto',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFEE2E2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isLoading ? null : widget.onImageRemoved,
          ),
        ],
      ),
    );
  }
}
