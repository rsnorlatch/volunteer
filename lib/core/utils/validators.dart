import 'package:volunteer/core/constants/app_constants.dart';

class Validators {
  Validators._();

  static String? required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
    if (v.length < AppConstants.minPasswordLength) {
      return 'Kata sandi minimal ${AppConstants.minPasswordLength} karakter';
    }
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nomor telepon wajib diisi';
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9 || digits.length > 15) {
      return 'Nomor telepon tidak valid';
    }
    return null;
  }

  static String? quota(String? v) {
    final n = int.tryParse((v ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
    if (n == null || n <= 0) return 'Isi kuota dengan angka lebih dari 0';
    return null;
  }
}
