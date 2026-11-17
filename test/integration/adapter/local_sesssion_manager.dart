import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/adapter/user_repository/fake_user_repository.dart';
import 'package:volunteer/entities/profile.dart';

/// Session dummy lokal: cek email + password dari data registrasi (in-memory).
class LocalSessionManager implements SessionManagerInterface {
  LocalSessionManager(this._profiles, this._users);

  final ProfileRepositoryInterface _profiles;
  final FakeUserRepository _users;
  Profile? _current;

  @override
  Future<bool> validateAndSetCurrentUserAsync(
      String email, String password) async {
    final e = email.trim().toLowerCase();
    final user = _users.users
        .where((u) => u.email.toLowerCase() == e && u.password == password)
        .firstOrNull;
    if (user == null) return false;

    final profile = await _profiles.getByEmailAsync(user.email);
    if (profile == null) return false;

    _current = profile;
    return true;
  }

  @override
  Future<void> destroyAsync() async => _current = null;

  @override
  Future<Profile?> getCurrentProfileAsync() async => _current;
}
