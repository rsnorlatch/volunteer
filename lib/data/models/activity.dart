import 'package:uuid/uuid.dart';
import 'package:volunteer/data/models/bloodtype.dart';

class BloodActivity {
  final String id;
  final String title;
  final String location;
  final String organizer;
  final List<BloodType> bloodGroups;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String description;
  final int quota;
  final int registered;

  const BloodActivity({
    required this.id,
    required this.title,
    required this.location,
    required this.organizer,
    required this.bloodGroups,
    required this.startDateTime,
    required this.endDateTime,
    required this.description,
    required this.quota,
    required this.registered,
  });

  BloodActivity copyWith({
    String? id,
    String? title,
    String? location,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? organizer,
    List<BloodType>? bloodGroups,
    String? description,
    int? quota,
    int? registered,
  }) {
    return BloodActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      organizer: organizer ?? this.organizer,
      bloodGroups: bloodGroups ?? this.bloodGroups,
      description: description ?? this.description,
      quota: quota ?? this.quota,
      registered: registered ?? this.registered,
    );
  }

  factory BloodActivity.create({
    String? id,
    required String title,
    required String location,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String organizer,
    required List<BloodType> bloodGroups,
    required String description,
    required int quota,
  }) {
    return BloodActivity(
        id: id ?? Uuid().v4(),
        title: title,
        location: location,
        organizer: organizer,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        bloodGroups: bloodGroups,
        description: description,
        quota: quota,
        registered: 0);
  }

  static List<BloodType> bloodGroupsFromString(String s) {
    final map = <String, BloodType>{
      'A+': BloodType.aPlus,
      'A-': BloodType.aMin,
      'B+': BloodType.bPlus,
      'B-': BloodType.bMin,
      'O+': BloodType.oPlus,
      'O-': BloodType.oMin,
      'AB+': BloodType.abPlus,
      'AB-': BloodType.abMin,
    };
    return s
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => map[e])
        .whereType<BloodType>()
        .toList();
  }

  static BloodType? bloodTypeFromLabel(String label) {
    switch (label) {
      case 'A+':
        return BloodType.aPlus;
      case 'A-':
        return BloodType.aMin;
      case 'B+':
        return BloodType.bPlus;
      case 'B-':
        return BloodType.bMin;
      case 'O+':
        return BloodType.oPlus;
      case 'O-':
        return BloodType.oMin;
      case 'AB+':
        return BloodType.abPlus;
      case 'AB-':
        return BloodType.abMin;
      default:
        return null;
    }
  }

  static DateTime? dateFromString(String s) => DateTime.tryParse(s);

  static (int hour, int minute)? _parseHm(String s) {
    final p = s.trim().split(':');
    if (p.length != 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null) return null;
    return (h, m);
  }

  /// Parses "HH:mm - HH:mm" into start/end (hour, minute).
  static ((int, int), (int, int))? timeRangeFromString(String s) {
    final parts = s.split('-').map((e) => e.trim()).toList();
    if (parts.length != 2) return null;
    final start = _parseHm(parts[0]);
    final end = _parseHm(parts[1]);
    if (start == null || end == null) return null;
    return (start, end);
  }

  /// Combines an ISO date string with a "HH:mm - HH:mm" time range into
  /// start/end [DateTime] on that date.
  static (DateTime, DateTime)? dateTimeRangeFromString(String date, String time) {
    final d = dateFromString(date);
    if (d == null) return null;
    final range = timeRangeFromString(time);
    if (range == null) return null;
    final ((sh, sm), (eh, em)) = range;
    return (
      DateTime(d.year, d.month, d.day, sh, sm),
      DateTime(d.year, d.month, d.day, eh, em),
    );
  }
}
