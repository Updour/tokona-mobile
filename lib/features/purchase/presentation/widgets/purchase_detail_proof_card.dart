import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class PurchaseDetailProofCard extends StatelessWidget {
  final String? imagePath;

  const PurchaseDetailProofCard({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.trim().isEmpty) return const SizedBox.shrink();
    final file = File(imagePath!);
    if (!file.existsSync()) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.photo_camera_back_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text('Foto Faktur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => Dialog(
                backgroundColor: Colors.transparent,
                child: InteractiveViewer(
                  child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file)),
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(file, height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Ketuk untuk perbesar', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
