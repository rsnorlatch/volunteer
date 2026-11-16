import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/entities/user.dart';

class FakeUserRepository implements UserRepositoryInterface {
  final List<User> _users = [];

  List<User> get users => List.unmodifiable(_users);

  @override
  Future<void> insertAsync(User user) async {
    _users.add(user);
  }
}
