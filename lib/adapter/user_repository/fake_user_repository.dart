import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/entities/authentication_user.dart';

class FakeUserRepository implements UserRepositoryInterface {
  final List<AuthenticationUser> _users = [];

  List<AuthenticationUser> get users => List.unmodifiable(_users);

  @override
  Future<void> insertAsync(AuthenticationUser user) async {
    _users.add(user);
  }

  @override
  Future<bool> resetPasswordAsync(String email, String newPassword) async {
    final normalizedEmail = email.trim().toLowerCase();
    for (final user in _users) {
      if (user.email.toLowerCase() == normalizedEmail) {
        user.password = newPassword;
        return true;
      }
    }
    return false;
  }
}
