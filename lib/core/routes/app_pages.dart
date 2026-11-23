import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/pages/auth/login_page.dart';
import 'package:volunteer/pages/auth/reset_password_page.dart';
import 'package:volunteer/pages/auth/signup_page.dart';
import 'package:volunteer/pages/donor/activity_detail_page.dart';
import 'package:volunteer/pages/donor/facility_search_page.dart';
import 'package:volunteer/pages/donor/history_page.dart';
import 'package:volunteer/pages/donor/main_shell_page.dart';
import 'package:volunteer/pages/donor/notifications_page.dart';
import 'package:volunteer/pages/donor/registration_page.dart';
import 'package:volunteer/pages/donor/registration_status_page.dart';
import 'package:volunteer/pages/donor/shell_controller.dart';
import 'package:volunteer/pages/organizer/activity_form_page.dart';
import 'package:volunteer/pages/organizer/dashboard_page.dart';
import 'package:volunteer/pages/organizer/manage_activities_page.dart';
import 'package:volunteer/pages/organizer/registrants_page.dart';
import 'package:volunteer/pages/profile/profile_page.dart';
import 'package:volunteer/pages/profile/edit_profile_page.dart';
import 'package:volunteer/pages/splash/splash_page.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.signup, page: () => const SignUpPage()),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainShellPage(),
      binding: ShellBinding(),
      middlewares: [DonorOnlyMiddleware()],
    ),
    GetPage(
      name: AppRoutes.activityDetail,
      page: () => const ActivityDetailPage(),
      middlewares: [DonorOnlyMiddleware()],
    ),
    GetPage(
      name: AppRoutes.registration,
      page: () => const RegistrationPage(),
      middlewares: [DonorOnlyMiddleware()],
    ),
    GetPage(
        name: AppRoutes.registrationStatus,
        page: () => const RegistrationStatusPage(),
        middlewares: [DonorOnlyMiddleware()]),
    GetPage(
      name: AppRoutes.facilitySearch,
      page: () => const FacilitySearchPage(),
      middlewares: [DonorOnlyMiddleware()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      middlewares: [DonorOnlyMiddleware()],
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryPage(),
      middlewares: [DonorOnlyMiddleware()],
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
      middlewares: [AuthenticatedMiddleware()],
    ),
    GetPage(
      name: AppRoutes.organizerProfile,
      page: () => const ProfilePage(),
      middlewares: [OrganizerOnlyMiddleware()],
    ),
    GetPage(
      name: AppRoutes.organizerDashboard,
      page: () => const DashboardPage(),
      middlewares: [OrganizerOnlyMiddleware()],
    ),
    GetPage(
      name: AppRoutes.createActivity,
      page: () => const ActivityFormPage(),
      middlewares: [OrganizerOnlyMiddleware()],
    ),
    GetPage(
        name: AppRoutes.editActivity,
        page: () => const ActivityFormPage(isEdit: true),
        middlewares: [OrganizerOnlyMiddleware()]),
    GetPage(
        name: AppRoutes.manageActivities,
        page: () => const ManageActivitiesPage(),
        middlewares: [OrganizerOnlyMiddleware()]),
    GetPage(
      name: AppRoutes.manageRegistrants,
      page: () => const RegistrantsPage(),
      middlewares: [OrganizerOnlyMiddleware()],
    ),
  ];
}

class OrganizerOnlyMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final profile = Get.find<ProfileController>();
    if (!profile.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (profile.role.value != Role.organizer) {
      return const RouteSettings(name: AppRoutes.home);
    }
    return null;
  }
}

class DonorOnlyMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final profile = Get.find<ProfileController>();
    if (!profile.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (profile.role.value != Role.donor) {
      return const RouteSettings(name: AppRoutes.organizerDashboard);
    }
    return null;
  }
}

class AuthenticatedMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.find<ProfileController>().isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
