class Validators {
  Validators._();

  static final _digitsOnly = RegExp(r'^\d+$');
  static final _nameChars = RegExp(r"^[a-zA-Z .,'-]+$");
  static final _phone = RegExp(r'^08\d{8,11}$');

  static String? nik(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'NIK wajib diisi';
    if (!_digitsOnly.hasMatch(value)) return 'NIK hanya boleh berisi angka';
    if (value.length != 16) {
      return 'NIK harus 16 digit (saat ini ${value.length})';
    }
    return null;
  }

  static String? name(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Nama wajib diisi';
    if (value.length < 3) return 'Nama minimal 3 karakter';
    if (value.length > 60) return 'Nama maksimal 60 karakter';
    if (!_nameChars.hasMatch(value)) {
      return 'Nama hanya boleh berisi huruf dan tanda baca umum';
    }
    return null;
  }

  static String? phone(String? v) {
    final value = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (value.isEmpty) return 'Nomor HP wajib diisi';
    if (!_phone.hasMatch(value)) {
      return 'Format nomor HP tidak valid (contoh: 081234567890)';
    }
    return null;
  }

  static String? address(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Alamat wajib diisi';
    if (value.length < 10) {
      return 'Alamat terlalu singkat (minimal 10 karakter)';
    }
    if (value.length > 150) return 'Alamat maksimal 150 karakter';
    return null;
  }

  static String? password(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Password wajib diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'\d').hasMatch(value)) {
      return 'Password harus mengandung huruf dan angka';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (v) {
      if ((v ?? '').isEmpty) return 'Konfirmasi password wajib diisi';
      if (v != original()) return 'Konfirmasi password tidak sama';
      return null;
    };
  }

  static String? birthDate(DateTime? d, {DateTime? now}) {
    if (d == null) return 'Tanggal lahir wajib dipilih';
    final today = now ?? DateTime.now();
    if (d.isAfter(today)) return 'Tanggal lahir tidak boleh di masa depan';
    if (today.year - d.year > 120) return 'Tanggal lahir tidak valid';
    return null;
  }

  static String? complaint(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Keluhan singkat wajib diisi';
    if (value.length < 5) return 'Jelaskan keluhan minimal 5 karakter';
    if (value.length > 200) return 'Keluhan maksimal 200 karakter';
    return null;
  }

  static String? requiredText(String? v, String field, {int max = 100}) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return '$field wajib diisi';
    if (value.length > max) return '$field maksimal $max karakter';
    return null;
  }
}
