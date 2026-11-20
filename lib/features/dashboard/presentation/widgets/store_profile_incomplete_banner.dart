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
      missingDesc = 'Alamat & no. telepon toko belum diisi.';
    } else if (isAddressMissing) {
      missingDesc = 'Alamat toko belum diisi.';
    } else {
      missingDesc = 'Nomor WhatsApp toko belum diisi.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront_outlined, color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Lengkapi Profil Toko',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E)),
                    ),
                    SizedBox(width: 6),
                    Text('(Wajib)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.error)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$missingDesc Lengkapi profil untuk mengaktifkan cetak nota & input produk.',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFB45309), height: 1.3),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => StoreEditBottomSheet.show(context, store: store),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lengkapi Sekarang',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 13),
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
