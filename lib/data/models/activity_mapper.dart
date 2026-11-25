import 'package:volunteer/data/models/activity.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/data/models/bloodtype.dart';

/// Translation layer between the backend/domain model [BloodActivityModel] and
/// the frontend/display model [BloodActivity].
///
/// The backend model stores date/time as [DateTime] fields and blood groups as
/// [List<BloodType>], while the frontend model stores date/time as strings and
/// blood groups as a comma-separated string. These extensions convert between
/// the two representations.
extension ActivityModelToEntity on BloodActivityModel {
  /// Converts this backend model into a frontend [BloodActivity].
  BloodActivity toEntity() {
    final date =
        '${startDateTime.year}-${_two(startDateTime.month)}-${_two(startDateTime.day)}';
    final time =
        '${_two(startDateTime.hour)}:${_two(startDateTime.minute)} - ${_two(endDateTime.hour)}:${_two(endDateTime.minute)}';
    final groups = bloodGroups.map((g) => g.label).join(', ');
    return BloodActivity(
      id: id,
      title: title,
      location: location,
      date: date,
      time: time,
      organizer: organizer,
      ownerEmail: ownerEmail,
      latitude: latitude,
      longitude: longitude,
      bloodGroups: groups,
      description: description,
      quota: quota,
      registered: registered,
    );
  }
}

extension ActivityEntityToModel on BloodActivity {
  /// Converts this frontend model into a backend [BloodActivityModel].
  ///
  /// When [date] and [time] cannot be parsed, falls back to [DateTime.now()] for
  /// both start and end so the model remains usable.
  BloodActivityModel toModel() {
    final range = BloodActivityModel.dateTimeRangeFromString(date, time);
    final start = range?.$1 ?? DateTime.now();
    final end = range?.$2 ?? DateTime.now();
    final groups = BloodActivityModel.bloodGroupsFromString(bloodGroups);
    return BloodActivityModel(
      id: id,
      title: title,
      location: location,
      organizer: organizer,
      ownerEmail: ownerEmail,
      latitude: latitude,
      longitude: longitude,
      startDateTime: start,
      endDateTime: end,
      bloodGroups: groups,
      description: description,
      quota: quota,
      registered: registered,
    );
  }
}

String _two(int n) => n.toString().padLeft(2, '0');
