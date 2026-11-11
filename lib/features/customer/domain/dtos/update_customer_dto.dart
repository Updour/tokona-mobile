class UpdateCustomerDto {
  final String? name;
  final String? phone;
  final String? address;
  final String? customerType;
  final String? notes;
  final double? receivableBalance;

  const UpdateCustomerDto({
    this.name,
    this.phone,
    this.address,
    this.customerType,
    this.notes,
    this.receivableBalance,
  });

  String? validate() {
    if (name != null) {
      if (name!.trim().isEmpty) {
        return 'Nama pelanggan tidak boleh kosong';
      }
      if (name!.trim().length < 2) {
        return 'Nama pelanggan minimal 2 karakter';
      }
    }
    if (phone != null && phone!.trim().isNotEmpty) {
      final clean = phone!.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.length < 8) {
        return 'Nomor telepon minimal 8 digit';
      }
    }
    if (receivableBalance != null && receivableBalance! < 0) {
      return 'Saldo kasbon tidak boleh negatif';
    }
    return null;
  }
}

