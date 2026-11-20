import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/validators.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/pages/auth/auth_controller.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/app_snackbar.dart';
import 'package:volunteer/shared/widgets/custom_text_field.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = Get.find<AuthController>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await _auth.login(_email.text, _password.text);
    if (error != null) {
      showAppSnack(error, error: true);
      return;
    }
    final isOrganizer =
        Get.find<ProfileController>().role.value == Role.organizer;
    Get.offAllNamed(
        isOrganizer ? AppRoutes.organizerDashboard : AppRoutes.home);
  }

  void _continueAsGuest() {
    Get.find<ProfileController>().setGuest();
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat datang!',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      label: 'Email',
                      hint: 'nama@email.com',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Kata sandi',
                      hint: 'Masukkan kata sandi',
                      controller: _password,
                      obscureText: true,
                      validator: (v) => Validators.required(v, 'Kata sandi'),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => showAppSnack(
                            'Fitur lupa kata sandi belum tersedia.'),
                        child: const Text(
                          'Lupa kata sandi?',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => PrimaryButton(
                          text: 'Masuk',
                          isLoading: _auth.isLoading.value,
                          onPressed: _login,
                        )),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text('atau',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _continueAsGuest,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Lanjutkan sebagai pendonor',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun?',
                            style: TextStyle(
                                color: AppColors.primaryColor, fontSize: 13)),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.signup),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
