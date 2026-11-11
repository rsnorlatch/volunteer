import 'package:volunteer/entities/user.dart';

abstract interface class UserRepositoryInterface {
  Future<void> insertAsync(User user);
}
