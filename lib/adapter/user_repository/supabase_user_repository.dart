import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/entities/authentication_user.dart';

class SupabaseUserRepository implements UserRepositoryInterface {
  SupabaseUserRepository();

  final SupabaseClient client = Supabase.instance.client;

  @override
  Future<void> insertAsync(AuthenticationUser user) async {
    try {
      await client.auth.signUp(email: user.email, password: user.password);
    } catch (e) {
      throw Exception("failed to create user: $e");
    }
  }

  @override
  Future<bool> resetPasswordAsync(String email, String newPassword) {
    // TODO: implement resetPasswordAsync
    throw UnimplementedError();
  }
}
