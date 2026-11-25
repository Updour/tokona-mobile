class WhatsappMessageTemplates {
  static const String defaultBookingTemplate =
      'Halo Kak *{nama}*!\n\n'
      'Mengingatkan pesanan Anda di *{toko}*:\n'
      '{daftar_barang}\n\n'
      'Total: *{total}*\n'
      'Jadwal: *{jadwal}*\n'
      'Layanan: {metode}\n\n'
      'Pesanan sudah siap di toko. Ditunggu kedatangannya ya Kak. Terima kasih!';

  static const String defaultKasbonTemplate =
      'Halo Kak *{nama}*!\n'
      'Semoga selalu sehat dan lancar rezekinya.\n\n'
      'Kami dari *{toko}* menginformasikan tagihan nota kasbon:\n'
      'No. Nota: *{no_nota}*\n'
      'Tanggal Belanja: {tanggal}\n'
      'Jatuh Tempo: *{jatuh_tempo}*\n'
      'Total Tagihan: *{total}*\n\n'
      'Pembayaran bisa tunai di kasir atau transfer. Mohon konfirmasinya ya Kak. Terima kasih!';

  static const String defaultOrderTemplate =
      'Halo *{nama}*!\n'
      'Pesanan dari *{toko}*:\n\n'
      'Barang: *{barang}*\n'
      'Jumlah: *{jumlah} {satuan}*\n'
      'Harga Satuan: {harga}\n'
      'Total Beli: *{total}*\n\n'
      'Mohon konfirmasinya ya. Terima kasih!';

  static String renderTemplate(String template, Map<String, String> values) {
    var result = template;
    values.forEach((key, val) {
      result = result.replaceAll('{$key}', val);
    });
    return result;
  }
}
