import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volunteer/adapter/activity_repository/activity_repository_interface.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/data/models/bloodtype.dart';

class SupabaseActivityRepository implements ActivityRepositoryInterface {
  SupabaseActivityRepository();

  final SupabaseClient client = Supabase.instance.client;

  static List<BloodType> _bloodGroupsFromDb(dynamic value) {
    if (value == null) return <BloodType>[];
    final raw = value is String ? value : value.toString();
    if (raw.isEmpty) return <BloodType>[];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((label) => switch (label) {
              'A+' => BloodType.aPlus,
              'A-' => BloodType.aMin,
              'B+' => BloodType.bPlus,
              'B-' => BloodType.bMin,
              'O+' => BloodType.oPlus,
              'O-' => BloodType.oMin,
              'AB+' => BloodType.abPlus,
              'AB-' => BloodType.abMin,
              _ => null,
            })
        .whereType<BloodType>()
        .toList();
  }

  static String _bloodGroupsToDb(List<BloodType> groups) {
    return groups.map((g) => g.label).join(',');
  }

  static DateTime? _dateTimeFromDb(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  Future<List<BloodActivityModel>> getAllAsync() async {
    final query = await client.from("activities").select("*");

    return query.map((row) {
      return BloodActivityModel(
        id: row["id"] as String,
        title: row["title"] as String,
        location: row["location"] as String,
        organizer: row["organizer"] as String,
        bloodGroups: _bloodGroupsFromDb(row["blood_groups"]),
        ownerEmail: row["owner_email"] as String? ?? '',
        latitude: (row["latitude"] as num?)?.toDouble(),
        longitude: (row["longitude"] as num?)?.toDouble(),
        startDateTime: _dateTimeFromDb(row["start_date_time"]) ?? DateTime.now(),
        endDateTime: _dateTimeFromDb(row["end_date_time"]) ?? DateTime.now(),
        description: row["description"] as String? ?? '',
        quota: (row["quota"] as num?)?.toInt() ?? 0,
        registered: (row["registered"] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  @override
  Future<void> insertAsync(BloodActivityModel activity) async {
    try {
      await client.from("activities").insert({
        "id": activity.id,
        "title": activity.title,
        "location": activity.location,
        "organizer": activity.organizer,
        "blood_groups": _bloodGroupsToDb(activity.bloodGroups),
        "owner_email": activity.ownerEmail,
        "latitude": activity.latitude,
        "longitude": activity.longitude,
        "start_date_time": activity.startDateTime.toIso8601String(),
        "end_date_time": activity.endDateTime.toIso8601String(),
        "description": activity.description,
        "quota": activity.quota,
        "registered": activity.registered,
      });
    } catch (e) {
      throw Exception("failed to insert activity: $e");
    }
  }

  @override
  Future<BloodActivityModel?> getByIdAsync(String activityId) async {
    final queried = await client
        .from("activities")
        .select("*")
        .eq("id", activityId)
        .maybeSingle();

    if (queried == null) {
      return null;
    }

    return BloodActivityModel(
      id: queried["id"] as String,
      title: queried["title"] as String,
      location: queried["location"] as String,
      organizer: queried["organizer"] as String,
      bloodGroups: _bloodGroupsFromDb(queried["blood_groups"]),
      ownerEmail: queried["owner_email"] as String? ?? '',
      latitude: (queried["latitude"] as num?)?.toDouble(),
      longitude: (queried["longitude"] as num?)?.toDouble(),
      startDateTime:
          _dateTimeFromDb(queried["start_date_time"]) ?? DateTime.now(),
      endDateTime:
          _dateTimeFromDb(queried["end_date_time"]) ?? DateTime.now(),
      description: queried["description"] as String? ?? '',
      quota: (queried["quota"] as num?)?.toInt() ?? 0,
      registered: (queried["registered"] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<void> updateAsync(BloodActivityModel newActivity) async {
    try {
      await client.from("activities").update({
        "title": newActivity.title,
        "location": newActivity.location,
        "organizer": newActivity.organizer,
        "blood_groups": _bloodGroupsToDb(newActivity.bloodGroups),
        "owner_email": newActivity.ownerEmail,
        "latitude": newActivity.latitude,
        "longitude": newActivity.longitude,
        "start_date_time": newActivity.startDateTime.toIso8601String(),
        "end_date_time": newActivity.endDateTime.toIso8601String(),
        "description": newActivity.description,
        "quota": newActivity.quota,
        "registered": newActivity.registered,
      }).eq("id", newActivity.id);
    } catch (e) {
      throw Exception("failed to update activity: $e");
    }
  }

  @override
  Future<void> deleteByIdAsync(String activityId) async {
    try {
      await client.from("activities").delete().eq("id", activityId);
    } catch (e) {
      throw Exception("failed to delete activity: $e");
    }
  }
}
