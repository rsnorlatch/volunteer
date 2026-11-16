import 'package:volunteer/entities/role.dart';

class RegisterRequestDto {
  RegisterRequestDto(
    this.username,
    this.email,
    this.password,
    this.confirmPassword,
    this.role,
  );

  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final Role role;
}
