import 'package:volunteer/entities/user.dart';

// Implement password resets through the auth provider in production; this
// interface is backed by an in-memory fake in the current app.
abstract interface class UserRepositoryInterface {
  Future<void> insertAsync(User user);

  Future<bool> resetPasswordAsync(String email, String newPassword);
}
