class RegisterDto {
  final String storeName;
  final String? storePhone;
  final String? storeAddress;
  final String ownerFullName;
  final String username;
  final String password;

  RegisterDto({
    required this.storeName,
    this.storePhone,
    this.storeAddress,
    required this.ownerFullName,
    String? username,
    required this.password,
  }) : username = _resolveUsername(username, ownerFullName, storePhone);

  static String _resolveUsername(String? username, String ownerFullName, String? storePhone) {
    if (username != null && username.trim().isNotEmpty) {
      return username.trim();
    }
    final clean = ownerFullName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
    if (clean.length >= 3) return clean;
    if (storePhone != null && storePhone.trim().isNotEmpty) {
      final digits = storePhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 4) return 'user_$digits';
    }
    return 'owner';
  }

  String? validate() {
    if (storeName.trim().isEmpty) {
      return 'Nama toko wajib diisi';
    }
    if (ownerFullName.trim().isEmpty) {
      return 'Nama pemilik toko wajib diisi';
    }
    if (username.trim().isEmpty) {
      return 'Nama pengguna wajib diisi';
    }
    if (password.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }
}
