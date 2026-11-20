import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class ShipmentProofPhotoCard extends StatelessWidget {
  final List<String> proofPhotos;

  const ShipmentProofPhotoCard({super.key, required this.proofPhotos});

  void _showZoom(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (c, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: const Text('Gagal memuat foto bukti kurir'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (proofPhotos.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, size: 16, color: Color(0xFF16A34A)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Foto Bukti Serah Terima Kurir J&T Cargo',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF166534)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(5)),
                child: Text('${proofPhotos.length} Foto', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: proofPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final url = proofPhotos[idx];
                return GestureDetector(
                  onTap: () => _showZoom(context, url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Image.network(
                          url,
                          width: 150,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (c, child, progress) => progress == null
                              ? child
                              : Container(
                                  width: 150,
                                  height: 120,
                                  color: const Color(0xFFE2E8F0),
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                                ),
                          errorBuilder: (_, __, ___) => Container(
                            width: 150,
                            height: 120,
                            color: const Color(0xFFE2E8F0),
                            child: const Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          const Text('Ketuk foto untuk melihat dalam ukuran penuh (zoom)', style: TextStyle(fontSize: 10, color: Color(0xFF15803D))),
        ],
      ),
    );
  }
}

