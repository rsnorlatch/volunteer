import 'dart:async';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:volunteer/data/models/facility.dart';

class FacilityController extends GetxController {
  final locationQuery = ''.obs;
  final currentLocation = Rxn<LatLng>();
  final selectedFacility = Rxn<Facility>();
  final isLocating = false.obs;
  final locationError = RxnString();

  final List<Facility> all = const [
    Facility(
      name: 'PMI Kota Bandung',
      address: 'Jl. Aceh No. 45, Bandung',
      info: 'Buka hingga 16.00',
      note: 'Melayani donor O+',
      distanceKm: 1.2,
      bloodTypes: ['A+', 'B+', 'O+', 'O-', 'AB+'],
      latitude: -6.9061,
      longitude: 107.6093,
    ),
    Facility(
      name: 'RS Harapan Sehat',
      address: 'Jl. Merdeka No. 12, Bandung',
      info: 'Layanan donor darah',
      note: 'Bank darah',
      distanceKm: 2.4,
      bloodTypes: ['A+', 'B+', 'O+', 'AB+'],
      latitude: -6.9230,
      longitude: 107.6092,
    ),
    Facility(
      name: 'Bank Darah Medika',
      address: 'Jl. Cendana No. 3, Bandung',
      info: 'Hubungi lokasi',
      note: 'Bank darah',
      distanceKm: 3.1,
      bloodTypes: ['O+', 'O-', 'B+'],
      latitude: -6.9181,
      longitude: 107.6282,
      isOpen: false,
    ),
    Facility(
      name: 'Klinik Medika',
      address: 'Jl. Cendana No. 9, Bandung',
      info: 'Layanan darah',
      note: 'Layanan darah',
      distanceKm: 4.0,
      bloodTypes: ['A+', 'B+', 'AB+'],
      latitude: -6.9296,
      longitude: 107.6137,
    ),
  ];

  /// Daftar di tab Lokasi (urut jarak, bisa dicari).
  List<Facility> get nearby {
    final q = locationQuery.value.trim().toLowerCase();
    final position = currentLocation.value;
    final list = all
        .where((f) =>
            q.isEmpty ||
            f.name.toLowerCase().contains(q) ||
            f.address.toLowerCase().contains(q))
        .map((facility) {
      if (position == null) return facility;
      final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            facility.latitude,
            facility.longitude,
          ) /
          1000;
      return facility.copyWith(distanceKm: distance);
    }).toList();
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  /// Pencarian lanjutan (halaman Cari fasilitas darah).
  List<Facility> search(
      {String name = '', String group = 'Semua', String area = ''}) {
    final n = name.trim().toLowerCase();
    final a = area.trim().toLowerCase();
    return all.where((f) {
      final okName = n.isEmpty || f.name.toLowerCase().contains(n);
      final okGroup = group == 'Semua' || f.bloodTypes.contains(group);
      final okArea = a.isEmpty ||
          f.address.toLowerCase().contains(a) ||
          f.name.toLowerCase().contains(a);
      return okName && okGroup && okArea;
    }).toList();
  }

  void selectFacility(Facility facility) {
    selectedFacility.value = facility;
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
