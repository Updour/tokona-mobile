class RegisterDto {
  final String storeName;
  final String? storePhone;
  final String? storeAddress;
  final String ownerFullName;
  final String username;
  final String password;

  const RegisterDto({
    required this.storeName,
    this.storePhone,
    this.storeAddress,
    required this.ownerFullName,
    required this.username,
    required this.password,
  });

  String? validate() {
    if (storeName.trim().isEmpty) {
      return 'Nama toko wajib diisi';
    }
    if (ownerFullName.trim().isEmpty) {
      return 'Nama lengkap pemilik wajib diisi';
    }
    if (username.trim().isEmpty) {
      return 'Nama pengguna wajib diisi';
    }
    if (username.trim().length < 3) {
      return 'Nama pengguna minimal 3 karakter';
    }
    if (password.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }
}
