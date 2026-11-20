import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/entities/authentication_user.dart';

class FakeUserRepository implements UserRepositoryInterface {
  final List<AuthenticationUser> _users = [];

  List<AuthenticationUser> get users => List.unmodifiable(_users);

  @override
  Future<void> insertAsync(AuthenticationUser user) async {
    _users.add(user);
  }
}
