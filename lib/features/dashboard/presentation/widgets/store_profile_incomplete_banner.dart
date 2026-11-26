import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/dashboard/presentation/widgets/store_edit_bottom_sheet.dart';

class StoreProfileIncompleteBanner extends ConsumerWidget {
  const StoreProfileIncompleteBanner({super.key});

  static void showProfileAlert(BuildContext context, StoreModel store) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.storefront_rounded, color: Color(0xFFD97706), size: 22),
            SizedBox(width: 8),
            Text('Lengkapi Profil Toko', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text(
          'Profil toko Anda belum lengkap (alamat toko wajib diisi). Lengkapi data toko Anda terlebih dahulu di menu profil untuk membuka akses input produk.',
          style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.35),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              StoreEditBottomSheet.show(context, store: store);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Lengkapi Sekarang', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(authProvider).currentStore;
    if (store == null || store.isProfileComplete) {
      return const SizedBox.shrink();
    }

    final isAddressMissing = store.address == null || store.address!.trim().isEmpty;
    final isPhoneMissing = store.phone == null || store.phone!.trim().isEmpty;

    String missingDesc;
    if (isAddressMissing && isPhoneMissing) {
      missingDesc = 'Nama, alamat & no. HP toko belum lengkap.';
    } else if (isAddressMissing) {
      missingDesc = 'Alamat toko belum diisi.';
    } else {
      missingDesc = 'No. WhatsApp toko belum diisi.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront_rounded, color: Color(0xFFD97706), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lengkapi Info Toko',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF92400E)),
                ),
                const SizedBox(height: 3),
                Text(
                  '$missingDesc Isi sekarang agar nota & fitur produk aktif.',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFFB45309), height: 1.35),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => StoreEditBottomSheet.show(context, store: store),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFF59E0B)]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97706).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lengkapi Sekarang',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
