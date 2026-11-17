class Facility {
  const Facility({
    required this.name,
    required this.address,
    required this.info,
    required this.note,
    required this.distanceKm,
    required this.bloodTypes,
    this.isOpen = true,
  });

  final String name;
  final String address;
  final String info; // contoh: "Buka hingga 16.00"
  final String note; // contoh: "Melayani donor O+"
  final double distanceKm;
  final List<String> bloodTypes;
  final bool isOpen;
}
