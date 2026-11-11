class UpdateSupplierDto {
  final String name;
  final String type;
  final String? platform;
  final String? contactName;
  final String? phone;
  final String? address;
  final String? notes;

  const UpdateSupplierDto({
    required this.name,
    this.type = 'offline',
    this.platform,
    this.contactName,
    this.phone,
    this.address,
    this.notes,
  });

  String? validate() {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Nama supplier wajib diisi';
    }
    if (trimmedName.length < 2) {
      return 'Nama supplier minimal 2 karakter';
    }
    if (type == 'online' && (platform == null || platform!.trim().isEmpty)) {
      return 'Platform marketplace wajib dipilih untuk supplier online';
    }
    return null;
  }
}
