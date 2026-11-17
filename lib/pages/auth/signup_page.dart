import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/core/utils/validators.dart';
import 'package:volunteer/pages/auth/auth_controller.dart';
import 'package:volunteer/pages/auth/widgets/role_selector.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/app_snackbar.dart';
import 'package:volunteer/shared/widgets/custom_text_field.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = Get.find<AuthController>();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await _auth.signup(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (error != null) {
      showAppSnack(error, error: true);
      return;
    }
    showAppSnack('Akun berhasil dibuat. Silakan masuk.');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Buat akun baru',
      subtitle: 'Mulai perjalanan kecil untuk menyelamatkan hidup.',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Nama lengkap',
                hint: 'Nama sesuai identitas',
                controller: _name,
                validator: (v) => Validators.required(v, 'Nama lengkap'),
              ),
              const SizedBox(height: 16),
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
                hint: 'Minimal 8 karakter',
                controller: _password,
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 20),
              const Text(
                'Daftar sebagai',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => RoleSelector(
                    selected: _auth.selectedRole.value,
                    onChanged: _auth.selectRole,
                  )),
              const SizedBox(height: 28),
              Obx(() => PrimaryButton(
                    text: 'Buat akun',
                    isLoading: _auth.isLoading.value,
                    onPressed: _signUp,
                  )),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun?',
                      style: TextStyle(
                          color: AppColors.primaryColor, fontSize: 13)),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Masuk',
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
      ],
    );
  }
}
