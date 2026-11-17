import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../dtos/register_request_dto.dart';
import '../../entities/role.dart';
import '../../services/auth_service.dart';
import '../../statuses/login_status.dart';
import '../../statuses/register_status.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final loginEmailController = TextEditingController();
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final showPassword = false.obs;
  final selectedRole = Role.donor.obs;

  void togglePassword() {
    showPassword.value = !showPassword.value;
  }

  void selectRole(Role role) {
    selectedRole.value = role;
  }

  Future<LoginStatus> login() async {
    final email = loginEmailController.text.trim();
    final password = passwordController.text;

    isLoading.value = true;

    try {
      return await authService.loginAsync(
        email,
        password,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Registerstatus> signup() async {
    final dto = RegisterRequestDto(
      usernameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
      confirmPasswordController.text,
      selectedRole.value,
    );

    isLoading.value = true;

    try {
      return await authService.registerAsync(dto);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    usernameController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }
}
