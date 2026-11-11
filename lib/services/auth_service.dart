import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/authenticator_interface.dart';
import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/dtos/register_request_dto.dart';
import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/entities/user.dart';
import 'package:volunteer/statuses/login_status.dart';
import 'package:volunteer/statuses/register_status.dart';

class AuthService {
  new(this._profiles, this._session, this._user);

  final ProfileRepositoryInterface _profiles;
  final SessionManagerInterface _session;
  final UserRepositoryInterface _user;

  Future<Registerstatus> registerAsync(RegisterRequestDto dto) async {
    if (dto.username == "" || dto.password == "" || dto.confirmPassword == "") {
      return Registerstatus.emptyCredential;
    }

    if (dto.password != dto.confirmPassword) {
      return Registerstatus.passwordDoNotMatch;
    }

    final profile = await _profiles.getByUsernameAsync(dto.username);

    if (profile != null) {
      return Registerstatus.usernameTaken;
    }

    final insertedUser = User(dto.username, dto.email, dto.password);

    await _user.insertAsync(insertedUser);

    await _profiles.insertAsync(
      Profile(dto.username, dto.email, dto.role).withUserId(insertedUser.id),
    );

    return Registerstatus.success;
  }

  Future<LoginStatus> loginAsync(String username, String password) async {
    if (username == "" || password == "") {
      return LoginStatus.noCredentialProvided;
    }

    final correctCredential = await _session.validateAndSetCurrentUserAsync(
      username,
      password,
    );
    if (!correctCredential) {
      return LoginStatus.incorrectCredential;
    }

    return LoginStatus.success;
  }
}
