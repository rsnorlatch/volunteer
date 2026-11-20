import 'package:volunteer/entities/authentication_user.dart';

// this operation is insert only because supabase does not allow you to query auth.user table
abstract interface class UserRepositoryInterface {
  Future<void> insertAsync(AuthenticationUser user);
}
