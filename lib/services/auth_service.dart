import 'package:volunteer/adapter/authenticator/authenticator_interface.dart';
import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/statuses/login_status.dart';
import 'package:volunteer/statuses/register_status.dart';

class AuthService {
  new(this._profiles, this._session);

  final ProfileRepositoryInterface _profiles;
  final SessionManagerInterface _session;

  Future<Registerstatus> registerAsync(
    String username,
    String password,
    String confirmPassword,
  ) async {
    if (username == "" || password == "" || confirmPassword == "") {
      return Registerstatus.emptyCredential;
    }

    if (password != confirmPassword) {
      return Registerstatus.passwordDoNotMatch;
    }

    final profile = await _profiles.getByUsernameAsync(username);

    if (profile != null) {
      return Registerstatus.usernameTaken;
    }

    await _profiles.insertAsync(Profile(username));

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
