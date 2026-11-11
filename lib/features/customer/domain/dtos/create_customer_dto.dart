class CreateCustomerDto {
  final String name;
  final String? phone;
  final String? address;
  final String customerType;
  final String? notes;
  final double initialReceivableBalance;

  const CreateCustomerDto({
    required this.name,
    this.phone,
    this.address,
    this.customerType = 'umum',
    this.notes,
    this.initialReceivableBalance = 0.0,
  });

  String? validate() {
    if (name.trim().isEmpty) {
      return 'Nama pelanggan wajib diisi';
    }
    if (name.trim().length < 2) {
      return 'Nama pelanggan minimal 2 karakter';
    }
    if (phone != null && phone!.trim().isNotEmpty) {
      final clean = phone!.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.length < 8) {
        return 'Nomor telepon minimal 8 digit';
      }
    }
    if (initialReceivableBalance < 0) {
      return 'Saldo kasbon awal tidak boleh negatif';
    }
    return null;
  }
}

