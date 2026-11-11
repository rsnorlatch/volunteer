import 'package:volunteer/entities/role.dart';

class RegisterRequestDto {
  new(
    this.username,
    this.email,
    this.password,
    this.confirmPassword,
    this.role,
  );

  String username;
  String email;
  String password;
  String confirmPassword;
  Role role;
}
