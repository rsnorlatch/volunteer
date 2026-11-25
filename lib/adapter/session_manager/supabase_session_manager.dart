import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/entities/profile.dart';

class SupabaseSessionManager implements SessionManagerInterface {
  SupabaseSessionManager(this.profile);

  final SupabaseClient client = Supabase.instance.client;
  final ProfileRepositoryInterface profile;

  @override
  Future<void> destroyAsync() async {
    await client.auth.signOut();
  }

  @override
  Future<Profile?> getCurrentProfileAsync() async {
    final currentUser = client.auth.currentUser;

    return await profile.getByEmailAsync(currentUser!.email!);
  }

  @override
  Future<bool> validateAndSetCurrentUserAsync(
      String email, String password) async {
    try {
      await client.auth.signInWithPassword(email: email, password: password);

      return true;
    } on AuthException catch (e) {
      print("auth Exception: $e");
      return false;
    } catch (e) {
      throw Exception("failed to authenticate: $e");
    }
  }

  @override
  Future<String?> getCurrentUserIdAsync() async {
    if (client.auth.currentUser == null) {
      return null;
    }

    return client.auth.currentUser!.id;
  }
}
