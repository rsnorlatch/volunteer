import 'package:uuid/uuid.dart';

class BloodActivity {
  final String id;
  final String title;
  final String location;
  final String date;
  final String time;
  final String organizer;
  final String bloodGroups;
  final String description;
  final int quota;
  final int registered;

  const BloodActivity({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.organizer,
    required this.bloodGroups,
    required this.description,
    required this.quota,
    required this.registered,
  });

  BloodActivity copyWith({
    String? id,
    String? title,
    String? location,
    String? date,
    String? time,
    String? organizer,
    String? bloodGroups,
    String? description,
    int? quota,
    int? registered,
  }) {
    return BloodActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      organizer: organizer ?? this.organizer,
      bloodGroups: bloodGroups ?? this.bloodGroups,
      description: description ?? this.description,
      quota: quota ?? this.quota,
      registered: registered ?? this.registered,
    );
  }

  static BloodActivity create({
    String? id,
    required String title,
    required String location,
    required String date,
    required String time,
    required String organizer,
    required String bloodGroups,
    required String description,
    required int quota,
  }) {
    return BloodActivity(
        id: id ?? Uuid().v4(),
        title: title,
        location: location,
        date: date,
        time: time,
        organizer: organizer,
        bloodGroups: bloodGroups,
        description: description,
        quota: quota,
        registered: 0);
  }
}
