import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../dtos/register_request_dto.dart';
import '../../entities/role.dart';
import '../../services/auth_service.dart';
import '../../statuses/register_status.dart';

import '../../shared/constants/app_colors.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_button.dart';
import 'widgets/role_selector.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'donor';
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final dto = RegisterRequestDto(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
      _selectedRole == 'organizer' ? Role.organizer : Role.donor,
    );
    final status = await Get.find<AuthService>().registerAsync(dto);
    if (!mounted) return;
    setState(() => _isLoading = false);

    final message = switch (status) {
      Registerstatus.success => 'Akun berhasil dibuat. Silakan masuk.',
      Registerstatus.emptyCredential => 'Semua kolom wajib diisi.',
      Registerstatus.passwordDoNotMatch => 'Konfirmasi password tidak cocok.',
      Registerstatus.usernameTaken => 'Username sudah digunakan.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    if (status == Registerstatus.success && mounted) Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(
                      title: 'Buat Akun Baru',
                      subtitle: 'Bergabunglah dan jadilah bagian dari penyelamat kehidupan.',
                    ),

                    const SizedBox(height: 28),

                    AuthTextField(
                      label: 'Username',
                      hint: 'Masukkan username',
                      prefixIcon: Icons.person_outline,
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      prefixIcon: Icons.badge_outlined,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Email',
                      hint: 'Masukkan email aktif',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email wajib diisi';
                        }

                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                          return 'Format email tidak valid';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Password',
                      hint: 'Minimal 6 karakter',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Konfirmasi Password',
                      hint: 'Ulangi password',
                      prefixIcon: Icons.lock_reset_outlined,
                      isPassword: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Daftar Sebagai',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    RoleSelector(
                      selectedRole: _selectedRole,
                      onChanged: (role) {
                        setState(() {
                          _selectedRole = role;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    AuthButton(
                      text: 'Buat Akun',
                      isLoading: _isLoading,
                      onPressed: _signUp,
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Sudah punya akun? Masuk',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
