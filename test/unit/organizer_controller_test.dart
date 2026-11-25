import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/controllers/notification_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/routes/app_pages.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/data/models/activity.dart';
import 'package:volunteer/data/models/activity_mapper.dart';
import 'package:volunteer/data/models/activity_model.dart';
import 'package:volunteer/data/models/registration.dart';
import 'package:volunteer/entities/role.dart';

void main() {
  late ActivityController activities;
  late ProfileController profile;

  setUp(() {
    Get.reset();
    profile = Get.put(ProfileController());
    Get.put(NotificationController());
    activities = Get.put(ActivityController());

    profile.name.value = 'Organizer One';
    profile.email.value = 'organizer@example.com';
    profile.role.value = Role.organizer;
    profile.isAuthenticated.value = true;
  });

  tearDown(() {
    Get.reset();
  });

  BloodActivityModel activity({
    String id = 'activity-1',
    String ownerEmail = 'organizer@example.com',
  }) {
    return BloodActivity.create(
      id: id,
      title: 'Donor day',
      location: 'Community Hall',
      date: '2026-12-01',
      time: '09:00 - 12:00',
      organizer: 'Organizer One',
      ownerEmail: ownerEmail,
      bloodGroups: 'O+',
      description: '',
      quota: 1,
    ).toModel();
  }

  test('organizer activities are scoped to the signed-in account', () {
    expect(activities.addActivity(activity()), isTrue);
    activities.activities.add(activity(
      id: 'activity-2',
      ownerEmail: 'someone-else@example.com',
    ));

    expect(activities.activitiesOf(profile.email.value).map((a) => a.id),
        ['activity-1']);
    expect(activities.canManageActivity('activity-1'), isTrue);
    expect(activities.canManageActivity('activity-2'), isFalse);
  });

  test('organizer routes reject guests and donor accounts', () {
    final middleware = OrganizerOnlyMiddleware();
    profile.isAuthenticated.value = false;

    expect(
        middleware.redirect(AppRoutes.manageActivities)?.name, AppRoutes.login);

    profile.isAuthenticated.value = true;
    profile.role.value = Role.donor;
    expect(
        middleware.redirect(AppRoutes.manageActivities)?.name, AppRoutes.home);

    profile.role.value = Role.organizer;
    expect(middleware.redirect(AppRoutes.manageActivities), isNull);
  });

  test('donor routes require a signed-in donor account', () {
    final middleware = DonorOnlyMiddleware();

    profile.isAuthenticated.value = false;
    expect(middleware.redirect(AppRoutes.home)?.name, AppRoutes.login);

    profile.isAuthenticated.value = true;
    profile.role.value = Role.organizer;
    expect(middleware.redirect(AppRoutes.home)?.name,
        AppRoutes.organizerDashboard);

    profile.role.value = Role.donor;
    expect(middleware.redirect(AppRoutes.home), isNull);
  });

  test('organizer cannot edit or delete another account activity', () {
    activities.activities.add(activity(
      ownerEmail: 'someone-else@example.com',
    ));

    expect(
      activities.updateActivity(
        activities.byId('activity-1')!.copyWith(title: 'Changed'),
      ),
      isFalse,
    );
    expect(activities.deleteActivity('activity-1'), isFalse);
    expect(activities.byId('activity-1')!.title, 'Donor day');
  });

  test('rejecting a registrant releases quota and quota is enforced on restore',
      () {
    activities.addActivity(activity());
    activities.registrations.add(Registration(
      id: 'registration-1',
      activityId: 'activity-1',
      userKey: 'donor-1',
      donorName: 'Donor One',
      phone: '0800000000',
      bloodType: 'O+',
    ));
    activities.activities[activities.activities.indexWhere(
      (a) => a.id == 'activity-1',
    )] = activities.byId('activity-1')!.copyWith(registered: 1);

    expect(
      activities.setRegistrantStatus(
        'registration-1',
        RegistrationStatus.rejected,
      ),
      isTrue,
    );
    expect(activities.byId('activity-1')!.registered, 0);

    activities.register(
      activities.byId('activity-1')!,
      name: 'Donor Two',
      phone: '0811111111',
      bloodType: 'O+',
    );

    expect(
      activities.setRegistrantStatus(
        'registration-1',
        RegistrationStatus.pending,
      ),
      isFalse,
    );
    expect(activities.byId('activity-1')!.registered, 1);
    expect(
      activities.registrations
          .firstWhere((r) => r.id == 'registration-1')
          .status,
      RegistrationStatus.rejected,
    );
  });
}
