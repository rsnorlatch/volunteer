import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../app_controller.dart';

class AuthController extends GetxController {
  final AppController appController = Get.find<AppController>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final showPassword = false.obs;
  final selectedRole = 'donor'.obs;

  void togglePassword() {
    showPassword.value = !showPassword.value;
  }

  void selectRole(String role) {
    selectedRole.value = role;
  }

  // LOGIN
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Login gagal',
        'Email dan password wajib diisi.',
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Email tidak valid',
        'Masukkan alamat email yang benar.',
      );
      return;
    }

    isLoading.value = true;

    try {
      final success = await appController.login(email, password);

      if (!success) return;

      Get.snackbar(
        'Login berhasil',
        'Selamat datang, ${appController.fullName.value}!',
      );

      if (appController.role.value == 'organizer') {
        Get.offAllNamed(AppRoutes.organizer);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // SIGN UP
  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Registrasi gagal',
        'Semua kolom wajib diisi.',
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Email tidak valid',
        'Masukkan alamat email yang benar.',
      );
      return;
    }

    if (password.length < 8) {
      Get.snackbar(
        'Password terlalu pendek',
        'Password minimal 8 karakter.',
      );
      return;
    }

    isLoading.value = true;

    try {
      final success = await appController.signup(
        name,
        email,
        password,
        selectedRole.value,
      );

      if (!success) return;

      emailController.text = email;
      passwordController.clear();
      nameController.clear();

      Get.offNamed(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Email diperlukan',
        'Masukkan email yang valid terlebih dahulu.',
      );
      return;
    }

    final exists = appController.users.any(
      (user) => user['email'] == email,
    );

    final isDemoAccount =
        email == 'donor@volunteer.com' || email == 'organizer@volunteer.com';

    if (!exists && !isDemoAccount) {
      Get.snackbar(
        'Email tidak ditemukan',
        'Tidak ada akun dengan email tersebut.',
      );
      return;
    }

    Get.snackbar(
      'Simulasi reset password',
      'Reset password membutuhkan layanan backend atau email.',
    );
  }

  // LOGIN TANPA AKUN
  void continueAsDonorDemo() {
    appController.role.value = 'donor';
    appController.fullName.value = 'Sahabat Donor';
    appController.email.value = 'donor@volunteer.com';

    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.onClose();
  }
}
