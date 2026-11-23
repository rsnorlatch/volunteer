import 'package:get/get.dart';

import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/constants/app_constants.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/dtos/register_request_dto.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/services/auth_service.dart';
import 'package:volunteer/statuses/login_status.dart';
import 'package:volunteer/statuses/register_status.dart';

class AuthController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final SessionManagerInterface _session = Get.find<SessionManagerInterface>();
  final ProfileRepositoryInterface _profiles =
      Get.find<ProfileRepositoryInterface>();

  final isLoading = false.obs;
  final selectedRole = Role.donor.obs;

  void selectRole(Role role) => selectedRole.value = role;

  /// Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> login(String email, String password) async {
    isLoading.value = true;
    try {
      final status = await _auth.loginAsync(email, password);
      if (status != LoginStatus.success) {
        return switch (status) {
          LoginStatus.noCredentialProvided =>
            'Email dan kata sandi wajib diisi.',
          _ =>
            'Email atau kata sandi salah. Daftar dulu jika belum punya akun.',
        };
      }
      final profile = await _session.getCurrentProfileAsync();
      if (profile == null) return 'Akun tidak ditemukan.';
      Get.find<ProfileController>().setFromProfile(profile);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String bloodType,
  }) async {
    isLoading.value = true;
    try {
      if (await _profiles.getByEmailAsync(email.trim()) != null) {
        return 'Email sudah terdaftar.';
      }
      if (!AppConstants.bloodTypes.contains(bloodType)) {
        return 'Pilih golongan darah kamu.';
      }
      // Desain tidak punya field username -> nama lengkap dipakai sebagai username.
      final dto = RegisterRequestDto(
        name.trim(),
        email.trim(),
        password,
        password,
        selectedRole.value,
        bloodType: bloodType,
      );
      final status = await _auth.registerAsync(dto);
      return switch (status) {
        Registerstatus.success => null,
        Registerstatus.emptyCredential => 'Semua kolom wajib diisi.',
        Registerstatus.passwordDoNotMatch =>
          'Konfirmasi kata sandi tidak cocok.',
        Registerstatus.usernameTaken =>
          'Nama sudah terdaftar. Gunakan nama lain.',
      };
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset akun lokal untuk demo; implementasi produksi harus memakai
  /// alur verifikasi penyedia autentikasi.
  Future<String?> resetPassword({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final updated = await _auth.resetPasswordAsync(email, password);
      return updated ? null : 'Akun dengan email tersebut tidak ditemukan.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.logoutAsync();
    Get.find<ProfileController>().clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}
