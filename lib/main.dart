import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:volunteer/adapter/activity_repository/activity_repository_interface.dart';
import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/adapter/activity_repository/supabase_activity_repository.dart';
import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/profile_repository/supabase_profile_repository.dart';
import 'package:volunteer/adapter/registration_repository/fake_registration_repository.dart';
import 'package:volunteer/adapter/registration_repository/registration_repository_interface.dart';
import 'package:volunteer/adapter/registration_repository/supabase_registration_repository.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/adapter/session_manager/supabase_session_manager.dart';
import 'package:volunteer/adapter/user_repository/supabase_user_repository.dart';
import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/core/constants/app_constants.dart';
import 'package:volunteer/core/routes/app_pages.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/routes/initial_binding.dart';
import 'package:volunteer/core/theme/app_theme.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/data/models/registration.dart';
import 'package:volunteer/services/activity_service.dart';
import 'package:volunteer/services/auth_service.dart';
import 'package:volunteer/services/profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "config.env");

  await Supabase.initialize(
      url: dotenv.get("SUPABASE_URL"),
      publishableKey: dotenv.get("PUBLISHABLE_KEY"));

  // Supabase-backed auth (kept as production implementation).
  final profiles = SupabaseProfileRepository();
  final users = SupabaseUserRepository();
  final session = SupabaseSessionManager(profiles);

  Get.put<ProfileRepositoryInterface>(profiles, permanent: true);
  Get.put<SessionManagerInterface>(session, permanent: true);
  Get.put<UserRepositoryInterface>(users, permanent: true);
  Get.put<AuthService>(AuthService(profiles, session, users), permanent: true);

  // Toggle between fake (in-memory) and Supabase-backed repositories for
  // activities and registrations. Set to true once the `activities` and
  // `registrations` tables exist in Supabase.
  bool useSupabaseActivityRepo = _useSupabaseActivityRepo();

  // Activity service wired with repositories for activities/registrations.
  late final ActivityRepositoryInterface activityRepo;
  late final RegistrationRepositoryInterface registrationRepo;

  if (useSupabaseActivityRepo) {
    activityRepo = SupabaseActivityRepository();
    registrationRepo = SupabaseRegistrationRepository();
  } else {
    activityRepo = FakeActivityRepository();
    registrationRepo = FakeRegistrationRepository();
  }

  Get.put<ActivityRepositoryInterface>(activityRepo, permanent: true);
  Get.put<RegistrationRepositoryInterface>(registrationRepo, permanent: true);
  Get.put(
    ActivityService(activityRepo, session, registrationRepo),
    permanent: true,
  );

  // Profile service wired with profile, registration, and activity repositories.
  Get.put(
    ProfileService(profiles, registrationRepo, activityRepo),
    permanent: true,
  );

  // Seed demo activity and registration data into the fake repositories only.
  if (!useSupabaseActivityRepo) {
    await _seedActivities(activityRepo as FakeActivityRepository);
    await _seedRegistrations(registrationRepo as FakeRegistrationRepository);
  }

  runApp(const VolunteerApp());
}

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

int _until(int weekday, DateTime today) {
  final d = (weekday - today.weekday) % 7;
  return d == 0 ? 7 : d;
}

Future<void> _seedActivities(FakeActivityRepository repo) async {
  const org = 'PMI Bandung';
  final today = _today();
  final saturday = today.add(Duration(days: _until(DateTime.saturday, today)));
  final sunday = saturday.add(const Duration(days: 1));

  final act1 = BloodActivityModel.dateTimeRangeFromString(
    Fmt.isoDate(saturday),
    '09:00 - 13:00',
  );
  final act2 = BloodActivityModel.dateTimeRangeFromString(
    Fmt.isoDate(sunday),
    '08:00 - 12:00',
  );
  final act3 = BloodActivityModel.dateTimeRangeFromString(
    Fmt.isoDate(today.add(const Duration(days: 8))),
    '10:00 - 14:00',
  );
  final act4 = BloodActivityModel.dateTimeRangeFromString(
    Fmt.isoDate(today.add(const Duration(days: 2))),
    '09:00 - 12:00',
  );

  await repo.insertAll([
    BloodActivityModel(
      id: 'act-1',
      title: 'Donor Darah Peduli Sesama',
      location: 'PMI Kota Bandung, Jl. Aceh No. 45',
      startDateTime: act1?.$1 ?? DateTime.now(),
      endDateTime: act1?.$2 ?? DateTime.now(),
      organizer: org,
      bloodGroups: BloodActivityModel.bloodGroupsFromString('O+, O-, A+, B+'),
      description: '',
      quota: 100,
      registered: 4,
    ),
    BloodActivityModel(
      id: 'act-2',
      title: 'Berbagi untuk Negeri',
      location: 'RS Harapan Sehat, Jl. Merdeka No. 12',
      startDateTime: act2?.$1 ?? DateTime.now(),
      endDateTime: act2?.$2 ?? DateTime.now(),
      organizer: org,
      bloodGroups: BloodActivityModel.bloodGroupsFromString('A+, A-'),
      description: '',
      quota: 80,
      registered: 2,
    ),
    BloodActivityModel(
      id: 'act-3',
      title: 'Sehat Bersama',
      location: 'Klinik Medika, Jl. Cendana No. 9',
      startDateTime: act3?.$1 ?? DateTime.now(),
      endDateTime: act3?.$2 ?? DateTime.now(),
      organizer: org,
      bloodGroups: BloodActivityModel.bloodGroupsFromString('B+, B-'),
      description: '',
      quota: 60,
      registered: 0,
    ),
    BloodActivityModel(
      id: 'act-4',
      title: 'Aksi Donor Kampus',
      location: 'Aula Kampus, Jl. Dipati Ukur',
      startDateTime: act4?.$1 ?? DateTime.now(),
      endDateTime: act4?.$2 ?? DateTime.now(),
      organizer: org,
      bloodGroups: BloodActivityModel.bloodGroupsFromString(
        'A+, A-, B+, B-, O+, O-, AB+, AB-',
      ),
      description: '',
      quota: 150,
      registered: 1,
    ),
  ]);
}

Future<void> _seedRegistrations(FakeRegistrationRepository repo) async {
  const donorKey = 'donor@volunteer.com';
  final today = _today();

  Registration r(String id, String act, String name, String blood,
          RegistrationStatus s, int daysAgo) =>
      Registration(
        id: id,
        activityId: act,
        userKey: donorKey,
        donorName: name,
        phone: '0812345678$id'.replaceAll(RegExp(r'[^0-9]'), ''),
        bloodType: blood,
        status: s,
        createdAt: today.subtract(Duration(days: daysAgo)),
      );

  await repo.insertAll([
    r('1', 'act-1', 'Alya Pratama', 'O+', RegistrationStatus.pending, 5),
    r('2', 'act-1', 'Bima Saputra', 'A+', RegistrationStatus.accepted, 6),
    r('3', 'act-1', 'Citra Lestari', 'B+', RegistrationStatus.pending, 7),
    r('4', 'act-1', 'Dian Putra', 'O-', RegistrationStatus.accepted, 8),
    r('5', 'act-2', 'Eka Wijaya', 'A+', RegistrationStatus.pending, 2),
    r('6', 'act-2', 'Farah Nabila', 'A-', RegistrationStatus.accepted, 3),
    r('7', 'act-4', 'Galih Permana', 'O+', RegistrationStatus.pending, 1),
  ]);
}

bool _useSupabaseActivityRepo() => true;

class VolunteerApp extends StatelessWidget {
  const VolunteerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      initialBinding: InitialBinding(),
      getPages: AppPages.pages,
    );
  }
}
