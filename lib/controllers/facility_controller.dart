import 'dart:async';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:volunteer/data/models/activity.dart';
import 'package:volunteer/data/models/activity_mapper.dart';
import 'package:volunteer/data/models/facility.dart';
import 'package:volunteer/services/activity_service.dart';

class FacilityController extends GetxController {
  final locationQuery = ''.obs;
  final currentLocation = Rxn<LatLng>();
  final selectedFacility = Rxn<BloodActivity>();
  final isLocating = false.obs;
  final locationError = RxnString();

  final activity = Get.find<ActivityService>();

  final List<BloodActivity> all = [];

  @override
  void onInit() async {
    super.onInit();

    final activities = await activity.getActivityListAsync();

    all.assignAll(activities.map((activity) => activity.toEntity()).toList());
  }

  /// Daftar di tab Lokasi (urut jarak, bisa dicari).
  List<BloodActivity> get nearby {
    final q = locationQuery.value.trim().toLowerCase();
    final list = all
        .where((a) =>
            q.isEmpty ||
            a.title.toLowerCase().contains(q) ||
            a.location.toLowerCase().contains(q))
        .toList();
    list.sort((a, b) {
      final da = _distanceKm(a);
      final db = _distanceKm(b);
      // null distances sort to the end
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return list;
  }

  /// Hitung jarak (km) dari lokasi pengguna ke aktivasi. Null jika lokasi
  /// pengguna atau koordinat aktivasi tidak tersedia.
  double? _distanceKm(BloodActivity a) {
    final position = currentLocation.value;
    if (position == null || a.latitude == null || a.longitude == null) {
      return null;
    }
    return Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          a.latitude!,
          a.longitude!,
        ) /
        1000;
  }

  /// Jarak (km) untuk ditampilkan di UI.
  double? distanceKmOf(BloodActivity activity) => _distanceKm(activity);

  /// Pencarian lanjutan (halaman Cari fasilitas darah).
  List<BloodActivity> search({
    String name = '',
    String group = 'Semua',
    String area = '',
  }) {
    final n = name.trim().toLowerCase();
    final a = area.trim().toLowerCase();
    return all.where((activity) {
      final okName = n.isEmpty || activity.title.toLowerCase().contains(n);
      final okGroup = group == 'Semua' ||
          activity.bloodGroups.split(',').map((e) => e.trim()).contains(group);
      final okArea = a.isEmpty ||
          activity.location.toLowerCase().contains(a) ||
          activity.title.toLowerCase().contains(a);
      return okName && okGroup && okArea;
    }).toList();
  }

  void selectFacility(BloodActivity activity) {
    selectedFacility.value = activity;
  }

  // ---------- LocationMap adapter (LocationMap is typed to Facility) ----------

  List<Facility> get mapFacilities {
    return nearby.map((activity) {
      final dist = _distanceKm(activity) ?? 0.0;
      final lat = activity.latitude ?? 0.0;
      final lng = activity.longitude ?? 0.0;
      return Facility(
        name: activity.title,
        address: activity.location,
        info: activity.description,
        note: '',
        distanceKm: dist,
        bloodTypes:
            activity.bloodGroups.split(',').map((e) => e.trim()).toList(),
        latitude: lat,
        longitude: lng,
      );
    }).toList();
  }

  Facility? get mapSelectedFacility {
    final activity = selectedFacility.value;
    if (activity == null) return null;
    final lat = activity.latitude ?? 0.0;
    final lng = activity.longitude ?? 0.0;
    return Facility(
      name: activity.title,
      address: activity.location,
      info: activity.description,
      note: '',
      distanceKm: _distanceKm(activity) ?? 0.0,
      bloodTypes: activity.bloodGroups.split(',').map((e) => e.trim()).toList(),
      latitude: lat,
      longitude: lng,
    );
  }

  void onMapFacilitySelected(Facility facility) {
    final activity = all.firstWhere(
      (a) => a.title == facility.name,
      orElse: () => all.isNotEmpty
          ? all.first
          : throw StateError('No activities available'),
    );
    selectFacility(activity);
  }

  Future<void> locateMe() async {
    if (isLocating.value) return;
    isLocating.value = true;
    locationError.value = null;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        locationError.value = 'Aktifkan layanan lokasi untuk memakai GPS.';
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        locationError.value = 'Izin lokasi diperlukan untuk mencari jarak.';
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        locationError.value =
            'Izin lokasi ditolak. Aktifkan izin dari pengaturan perangkat.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      currentLocation.value = LatLng(position.latitude, position.longitude);
    } on LocationServiceDisabledException {
      locationError.value = 'Aktifkan layanan lokasi untuk memakai GPS.';
    } on PermissionDeniedException {
      locationError.value = 'Izin lokasi diperlukan untuk mencari jarak.';
    } on TimeoutException {
      locationError.value =
          'Lokasi belum berhasil didapat. Coba lagi beberapa saat.';
    } finally {
      isLocating.value = false;
    }
  }
}
