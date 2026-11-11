import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_photo_picker_sheet.dart';

class ProfileAvatarPicker extends StatefulWidget {
  final UserModel? user;
  final double size;

  const ProfileAvatarPicker({
    super.key,
    required this.user,
    this.size = 76,
  });

  @override
  State<ProfileAvatarPicker> createState() => _ProfileAvatarPickerState();
}

class _ProfileAvatarPickerState extends State<ProfileAvatarPicker> {
  String? _avatarPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAvatar();
    _checkLostData();
  }

  Future<void> _checkLostData() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final picker = ImagePicker();
      final response = await picker.retrieveLostData();
      if (!response.isEmpty && response.file != null) {
        final targetFile = await _getAvatarFile();
        await File(response.file!.path).copy(targetFile.path);
        if (mounted) {
          setState(() => _avatarPath = targetFile.path);
        }
      }
    } catch (_) {}
  }

  Future<File> _getAvatarFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final uid = widget.user?.id ?? 'default_user';
    return File('${dir.path}/avatar_$uid.jpg');
  }

  Future<void> _loadSavedAvatar() async {
    try {
      final file = await _getAvatarFile();
      if (await file.exists()) {
        setState(() {
          _avatarPath = file.path;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 120));
    try {
      final picker = ImagePicker();
      XFile? picked;
      try {
        if (source == ImageSource.camera) {
          picked = await picker.pickImage(source: source);
        } else {
          picked = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
        }
      } catch (_) {
        picked = await picker.pickImage(source: source);
      }
      if (picked == null) return;

      final targetFile = await _getAvatarFile();
      await File(picked.path).copy(targetFile.path);

      if (mounted) {
        setState(() => _avatarPath = targetFile.path);
        AppToast.showSuccess(context, 'Foto profil berhasil diperbarui');
      }
    } on PlatformException catch (e) {
      if (mounted) {
        final isDenied = e.code.contains('denied') || (e.message?.toLowerCase().contains('permission') ?? false);
        AppToast.showError(
          context,
          isDenied
              ? 'Izin kamera belum aktif. Buka Pengaturan HP > Aplikasi > Tokona > Izin > Aktifkan Kamera.'
              : 'Gagal membuka kamera: ${e.message}',
        );
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Gagal memilih foto: $e');
    }
  }

  void _showPickerOptions() {
    ProfilePhotoPickerSheet.show(
      context,
      hasExistingPhoto: _avatarPath != null,
      onPickGallery: () => _pickImage(ImageSource.gallery),
      onPickCamera: () => _pickImage(ImageSource.camera),
      onRemovePhoto: () async {
        Navigator.of(context).pop();
        try {
          final f = await _getAvatarFile();
          if (await f.exists()) await f.delete();
          if (mounted) {
            setState(() => _avatarPath = null);
            AppToast.showSuccess(context, 'Foto profil berhasil dihapus');
          }
        } catch (_) {}
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = (widget.user?.fullName.isNotEmpty ?? false)
        ? widget.user!.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    final hasPhoto = _avatarPath != null && File(_avatarPath!).existsSync();

    return GestureDetector(
      onTap: _showPickerOptions,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _isLoading
                  ? Container(color: AppColors.surfaceElevated)
                  : (hasPhoto
                      ? Image.file(
                          File(_avatarPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallback(initials),
                        )
                      : _buildFallback(initials)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(String initials) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.18,
            child: Icon(Icons.person_rounded, size: widget.size * 0.8, color: Colors.white),
          ),
          Text(
            initials,
            style: TextStyle(
              fontSize: widget.size * 0.35,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
