class LoginDto {
  final String username;
  final String password;

  const LoginDto({
    required this.username,
    required this.password,
  });

  String? validate() {
    if (username.trim().isEmpty) {
      return 'Nama pengguna wajib diisi';
    }
    if (password.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    return null;
  }
}
