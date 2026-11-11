import 'package:volunteer/adapter/authenticator/fake_authenticator.dart';
import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/statuses/login_status.dart';
import 'package:volunteer/statuses/register_status.dart';

class AuthService {
  new(this._profiles, this._auth);

  final FakeProfileRepository _profiles;
  final FakeSessionManager _auth;

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

    if (await _auth.authenticateAsync(username, password) == false) {
      return LoginStatus.incorrectCredential;
    }

    return LoginStatus.success;
  }
}
