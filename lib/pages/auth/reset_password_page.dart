import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/validators.dart';
import 'package:volunteer/pages/auth/auth_controller.dart';
import 'package:volunteer/shared/widgets/app_snackbar.dart';
import 'package:volunteer/shared/widgets/custom_text_field.dart';
import 'package:volunteer/shared/widgets/password_text_field.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _auth = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    final initialEmail = Get.arguments;
    if (initialEmail is String) _email.text = initialEmail.trim();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await _auth.resetPassword(
      email: _email.text.trim(),
      password: _password.text,
    );
    if (error != null) {
      showAppSnack(error, error: true);
      return;
    }

    Get.offAllNamed(
      AppRoutes.login,
      arguments: _email.text.trim(),
    );
    showAppSnack('Kata sandi berhasil diubah. Silakan masuk kembali.',
        success: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Email',
                      hint: 'nama@email.com',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: const Icon(Icons.email_outlined),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      label: 'Password Baru',
                      hint: 'Minimal 8 karakter',
                      controller: _password,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      label: 'Konfirmasi Password',
                      hint: 'Masukkan kembali password baru',
                      controller: _confirmPassword,
                      validator: (value) {
                        final requiredError =
                            Validators.required(value, 'Konfirmasi password');
                        if (requiredError != null) return requiredError;
                        if (value != _password.text) {
                          return 'Konfirmasi password tidak cocok.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 56),
                    Obx(
                      () => PrimaryButton(
                        text: 'Simpan perubahan',
                        isLoading: _auth.isLoading.value,
                        onPressed: _savePassword,
                      ),
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
