import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/data/models/registration.dart';

class DonorHistoryEntry {
  const DonorHistoryEntry({
    required this.registration,
    required this.activity,
  });

  final Registration registration;
  final BloodActivityModel? activity;

  String get activityTitle => activity?.title ?? 'Kegiatan telah dihapus';
  String get activityLocation => activity?.location ?? '-';
  DateTime? get activityDate => activity?.startDateTime;
  String get statusLabel => registration.status.label;
  String get statusDescription => registration.status.description;
}
