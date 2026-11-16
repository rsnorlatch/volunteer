import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/adapter/user_repository/fake_user_repository.dart';
import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/entities/profile.dart';

class FakeSessionManager implements SessionManagerInterface {
  FakeSessionManager(this._profiles, this._users);

  final ProfileRepositoryInterface _profiles;
  final UserRepositoryInterface _users;

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

  @override
  Future<void> destroyAsync() async {
    _currentProfile = null;
  }

  @override
  Future<Profile?> getCurrentProfileAsync() async {
    return _currentProfile;
  }
}
