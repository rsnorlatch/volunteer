import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/entities/user.dart';

class FakeUserRepository implements UserRepositoryInterface {
  final List<User> _users = [];

  List<User> get users => List.unmodifiable(_users);

  @override
  Future<void> insertAsync(User user) async {
    _users.add(user);
  }

  User? findByIdentifierAndPassword(String identifier, String password) {
    for (final user in _users) {
      final matchesIdentifier =
          user.username.toLowerCase() == identifier.toLowerCase() ||
          user.email.toLowerCase() == identifier.toLowerCase();
      if (matchesIdentifier && user.password == password) return user;
    }
    return null;
  }
}
