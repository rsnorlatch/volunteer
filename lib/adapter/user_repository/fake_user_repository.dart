import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/entities/user.dart';

class FakeUserRepository implements UserRepositoryInterface {
  final List<User> _users = [];

  List<User> get users => List.unmodifiable(_users);

  @override
  Future<void> insertAsync(User user) async {
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
