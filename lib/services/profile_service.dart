import 'package:volunteer/adapter/activity_repository/activity_repository_interface.dart';
import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/registration_repository/registration_repository_interface.dart';
import 'package:volunteer/data/models/donor_history_entry.dart';
import 'package:volunteer/data/models/registration.dart';

class ProfileService {
  ProfileService(this.profileRepo, this.registrationRepo, this.activityRepo);

  final ProfileRepositoryInterface profileRepo;
  final RegistrationRepositoryInterface registrationRepo;
  final ActivityRepositoryInterface activityRepo;

  /// Edit profile — persists name, phone, bloodType, medicalNotes
  Future<void> updateProfileAsync({
    required String profileId,
    required String name,
    required String phone,
    required String bloodType,
    required String medicalNotes,
  }) async {
    final profiles = await profileRepo.getAllAsync();
    final profile = profiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => throw Exception('Profile not found'),
    );

    profile.username = name;
    profile.phone = phone;
    profile.bloodType = bloodType;
    profile.medicalNotes = medicalNotes;

    await profileRepo.updateAsync(profile);
  }

  /// View donor history — fetch registrations, then activity detail per registration
  Future<List<DonorHistoryEntry>> getDonorHistoryAsync(String profileId) async {
    final allRegs = await registrationRepo.getAllAsync();
    final userRegs = allRegs.where((r) => r.userKey == profileId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final entries = <DonorHistoryEntry>[];
    for (final r in userRegs) {
      final act = await activityRepo.getByIdAsync(r.activityId);
      entries.add(DonorHistoryEntry(registration: r, activity: act));
    }
    return entries;
  }

  /// Count only non-rejected registrations for current user
  Future<int> getApplicationCountAsync(String profileId) async {
    final allRegs = await registrationRepo.getAllAsync();
    return allRegs
        .where((r) =>
            r.userKey == profileId && r.status != RegistrationStatus.rejected)
        .length;
  }
}
