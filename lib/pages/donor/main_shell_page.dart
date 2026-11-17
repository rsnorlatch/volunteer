import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/pages/donor/activity_list_page.dart';
import 'package:volunteer/pages/donor/home_page.dart';
import 'package:volunteer/pages/donor/location_page.dart';
import 'package:volunteer/pages/donor/shell_controller.dart';
import 'package:volunteer/pages/profile/profile_page.dart';
import 'package:volunteer/shared/constants/app_colors.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    return Scaffold(
      body: SafeArea(
        child: Obx(() => IndexedStack(
              index: shell.index.value,
              children: const [
                HomePage(),
                ActivityListPage(),
                LocationPage(),
                ProfilePage(),
              ],
            )),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Obx(() => BottomNavigationBar(
              currentIndex: shell.index.value,
              onTap: shell.goTo,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.surface,
              elevation: 0,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: AppColors.textPrimary,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: 'Beranda'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.format_list_bulleted), label: 'Kegiatan'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.location_on_outlined), label: 'Lokasi'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: 'Profil'),
              ],
            )),
      ),
    );
  }
}
