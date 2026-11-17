import 'package:get/get.dart';

import 'package:volunteer/data/models/facility.dart';

class FacilityController extends GetxController {
  final locationQuery = ''.obs;

  final List<Facility> all = const [
    Facility(
      name: 'PMI Kota Bandung',
      address: 'Jl. Aceh No. 45, Bandung',
      info: 'Buka hingga 16.00',
      note: 'Melayani donor O+',
      distanceKm: 1.2,
      bloodTypes: ['A+', 'B+', 'O+', 'O-', 'AB+'],
    ),
    Facility(
      name: 'RS Harapan Sehat',
      address: 'Jl. Merdeka No. 12, Bandung',
      info: 'Layanan donor darah',
      note: 'Bank darah',
      distanceKm: 2.4,
      bloodTypes: ['A+', 'B+', 'O+', 'AB+'],
    ),
    Facility(
      name: 'Bank Darah Medika',
      address: 'Jl. Cendana No. 3, Bandung',
      info: 'Hubungi lokasi',
      note: 'Bank darah',
      distanceKm: 3.1,
      bloodTypes: ['O+', 'O-', 'B+'],
      isOpen: false,
    ),
    Facility(
      name: 'Klinik Medika',
      address: 'Jl. Cendana No. 9, Bandung',
      info: 'Layanan darah',
      note: 'Layanan darah',
      distanceKm: 4.0,
      bloodTypes: ['A+', 'B+', 'AB+'],
    ),
  ];

  /// Daftar di tab Lokasi (urut jarak, bisa dicari).
  List<Facility> get nearby {
    final q = locationQuery.value.trim().toLowerCase();
    final list = all
        .where((f) =>
            q.isEmpty ||
            f.name.toLowerCase().contains(q) ||
            f.address.toLowerCase().contains(q))
        .toList();
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
}
