import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/session_manager/authenticator_interface.dart';
import 'package:volunteer/adapter/user_repository/fake_user_repository.dart';
import 'package:volunteer/entities/profile.dart';

class FakeSessionManager implements SessionManagerInterface {
  FakeSessionManager(this._profiles, this._users);

  final FakeProfileRepository _profiles;
  final FakeUserRepository _users;

  Profile? _currentProfile;
  Profile? get currentProfile => _currentProfile;

  @override
  Future<bool> validateAndSetCurrentUserAsync(
    String username,
    String password,
  ) async {
    final user = _users.findByIdentifierAndPassword(username, password);
    if (user == null) return false;

    _currentProfile = await _profiles.getByUsernameAsync(user.username);
    return _currentProfile != null;
  }
}
