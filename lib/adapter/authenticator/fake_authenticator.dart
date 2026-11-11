import 'package:volunteer/adapter/authenticator/authenticator_interface.dart';
import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/entities/profile.dart';

class FakeAuthenticator implements AuthenticatorInterface {
  new(this._profiles);

  final FakeProfileRepository _profiles;

  final correctPassword = "Password123";

  Profile? _currentProfile;
  Profile? get currentProfile => _currentProfile;

  @override
  Future<bool> authenticateAsync(String username, String password) async {
    if (password != correctPassword) return false;

    _currentProfile = await _profiles.getByUsernameAsync(username);

    return true;
  }
}
