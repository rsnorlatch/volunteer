import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/user_repository/supabase_user_repository.dart';
import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/entities/role.dart';

class SupabaseProfileRepository implements ProfileRepositoryInterface {
  SupabaseProfileRepository();

  final SupabaseClient client = Supabase.instance.client;

  @override
  Future<List<Profile>> getAllAsync() async {
    final query = await client.from("profiles").select("*");

    return query
        .map((row) => Profile(row["username"], row["email"], row["role"])
            .withId(row["id"])
            .withUserId(row["user_id"]))
        .toList();
  }

  @override
  Future<Profile?> getByEmailAsync(String email) async {
    final queried = await client
        .from("profiles")
        .select("*")
        .eq("email", email)
        .maybeSingle();

    if (queried == null) {
      return null;
    }

    return Profile(
      queried["fullname"],
      queried["email"],
      queried["role"] == "donor" ? Role.donor : Role.organizer,
    ).withId(queried["id"]).withUserId(queried["user_id"]);
  }

  @override
  Future<Profile?> getByUsernameAsync(String username) async {
    final queried = await client
        .from("profiles")
        .select("*")
        .eq("fullname", username)
        .maybeSingle();

    if (queried == null) {
      return null;
    }

    return Profile(queried["fullname"], queried["email"], queried["role"])
        .withId(queried["id"])
        .withUserId(queried["user_id"]);
  }

  @override
  Future<void> insertAsync(Profile profile) async {
    try {
      await client.from("profiles").insert({
        "fullname": profile.username,
        "email": profile.email,
        "role": profile.role == Role.donor ? "donor" : "organizer",
        "bloodtype": profile.bloodType,
        "user_id": profile.userId,
      });
    } catch (e) {
      throw Exception("failed to insert profile: $e");
    }
  }
}
