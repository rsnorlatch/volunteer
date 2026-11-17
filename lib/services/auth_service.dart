import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/dtos/register_request_dto.dart';
import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/entities/user.dart';
import 'package:volunteer/statuses/login_status.dart';
import 'package:volunteer/statuses/register_status.dart';

class AuthService {
  AuthService(this._profiles, this._session, this._user);

  final ProfileRepositoryInterface _profiles;
  final SessionManagerInterface _session;
  final UserRepositoryInterface _user;

  Future<Registerstatus> registerAsync(RegisterRequestDto dto) async {
    if (dto.username.trim().isEmpty ||
        dto.email.trim().isEmpty ||
        dto.password.isEmpty ||
        dto.confirmPassword.isEmpty) {
      return Registerstatus.emptyCredential;
    }

    if (dto.password != dto.confirmPassword) {
      return Registerstatus.passwordDoNotMatch;
    }

    final existingProfile =
        await _profiles.getByUsernameAsync(dto.username.trim());

    if (existingProfile != null) return Registerstatus.usernameTaken;

    final insertedUser =
        User(dto.username.trim(), dto.email.trim(), dto.password);
    await _user.insertAsync(insertedUser);

    await _profiles.insertAsync(
      Profile(dto.username.trim(), dto.email.trim(), dto.role)
          .withUserId(insertedUser.id),
    );

    return Registerstatus.success;
  }

  Future<LoginStatus> loginAsync(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      return LoginStatus.noCredentialProvided;
    }

    final correctCredential = await _session.validateAndSetCurrentUserAsync(
      username.trim(),
      password,
    );

    return correctCredential
        ? LoginStatus.success
        : LoginStatus.incorrectCredential;
  }

  Future<void> logoutAsync() async {
    await _session.destroyAsync();
  }
}
