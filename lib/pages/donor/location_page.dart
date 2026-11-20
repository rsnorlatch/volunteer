import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/facility_controller.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/utils/formatters.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/map_placeholder.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<FacilityController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Lokasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Cari lokasi donor',
            subtitle: 'Temukan PMI, rumah sakit, klinik, dan bank darah.',
          ),
          const SizedBox(height: 20),
          AppSearchField(
            hint: 'Cari lokasi atau kota',
            onChanged: (v) => ctrl.locationQuery.value = v,
          ),
          const SizedBox(height: 16),
          const MapPlaceholder(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lokasi terdekat',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.facilitySearch),
                child: const Text('Pencarian lanjutan',
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final list = ctrl.nearby;
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.location_off_outlined,
                title: 'Lokasi tidak ditemukan',
                message: 'Coba kata kunci lain.',
              );
            }
            return Column(
              children: [
                for (final f in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.my_location,
                                color: AppColors.primaryColor, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary)),
                                const SizedBox(height: 6),
                                Text(
                                    '${Fmt.distance(f.distanceKm)} • ${f.info}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      ),
    );
  }
}
