import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/entities/profile.dart';

class FakeSessionManager implements SessionManagerInterface {
  FakeSessionManager(this._profiles, this.correctPassword);

  final ProfileRepositoryInterface _profiles;
  final String correctPassword;

  Profile? _currentProfile;
  Profile? get currentProfile => _currentProfile;

  @override
  Future<bool> validateAndSetCurrentUserAsync(
    String email,
    String password,
  ) async {
    if (password != correctPassword) return false;

    _currentProfile = await _profiles.getByEmailAsync(email);

    return true;
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
