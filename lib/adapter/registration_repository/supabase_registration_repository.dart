import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volunteer/adapter/registration_repository/registration_repository_interface.dart';
import 'package:volunteer/data/models/registration.dart';

class SupabaseRegistrationRepository
    implements RegistrationRepositoryInterface {
  SupabaseRegistrationRepository();

  final SupabaseClient client = Supabase.instance.client;

  static RegistrationStatus _statusFromDb(dynamic value) {
    final raw = value is String ? value : value.toString();
    return switch (raw) {
      'accepted' => RegistrationStatus.accepted,
      'rejected' => RegistrationStatus.rejected,
      _ => RegistrationStatus.pending,
    };
  }

  static DateTime? _dateTimeFromDb(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  Future<List<Registration>> getAllAsync() async {
    final query = await client.from("registrations").select("*");

    return query.map((row) {
      return Registration(
        id: row["id"] as String,
        activityId: row["activity_id"] as String,
        userKey: row["user_key"] as String,
        donorName: row["donor_name"] as String,
        phone: row["phone"] as String,
        bloodType: row["blood_type"] as String,
        status: _statusFromDb(row["status"]),
        createdAt: _dateTimeFromDb(row["created_at"]),
      );
    }).toList();
  }

  @override
  Future<void> insertAsync(Registration registration) async {
    try {
      await client.from("registrations").insert({
        "activity_id": registration.activityId,
        "user_key": registration.userKey,
        "donor_name": registration.donorName,
        "phone": registration.phone,
        "blood_type": registration.bloodType,
        "status": registration.status.toString().split('.').last,
        "created_at": registration.createdAt.toIso8601String(),
      });
    } catch (e) {
      throw Exception("failed to insert registration: $e");
    }
  }

  @override
  Future<Registration?> getByIdAsync(String id) async {
    final queried = await client
        .from("registrations")
        .select("*")
        .eq("id", id)
        .maybeSingle();

    if (queried == null) {
      return null;
    }

    return Registration(
      id: queried["id"] as String,
      activityId: queried["activity_id"] as String,
      userKey: queried["user_key"] as String,
      donorName: queried["donor_name"] as String,
      phone: queried["phone"] as String,
      bloodType: queried["blood_type"] as String,
      status: _statusFromDb(queried["status"]),
      createdAt: _dateTimeFromDb(queried["created_at"]),
    );
  }

  @override
  Future<void> updateAsync(Registration registration) async {
    try {
      await client.from("registrations").update({
        "activity_id": registration.activityId,
        "user_key": registration.userKey,
        "donor_name": registration.donorName,
        "phone": registration.phone,
        "blood_type": registration.bloodType,
        "status": registration.status.toString().split('.').last,
        "created_at": registration.createdAt.toIso8601String(),
      }).eq("id", registration.id);
    } catch (e) {
      throw Exception("failed to update registration: $e");
    }
  }

  @override
  Future<void> deleteByIdAsync(String registrationId) async {
    try {
      await client.from("registrations").delete().eq("id", registrationId);
    } catch (e) {
      throw Exception("failed to delete registration: $e");
    }
  }
}
