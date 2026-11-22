class Facility {
  const Facility({
    required this.name,
    required this.address,
    required this.info,
    required this.note,
    required this.distanceKm,
    required this.bloodTypes,
    required this.latitude,
    required this.longitude,
    this.isOpen = true,
  });

  final String name;
  final String address;
  final String info; // contoh: "Buka hingga 16.00"
  final String note; // contoh: "Melayani donor O+"
  final double distanceKm;
  final List<String> bloodTypes;
  final double latitude;
  final double longitude;
  final bool isOpen;

  Facility copyWith({double? distanceKm}) {
    return Facility(
      name: name,
      address: address,
      info: info,
      note: note,
      distanceKm: distanceKm ?? this.distanceKm,
      bloodTypes: bloodTypes,
      latitude: latitude,
      longitude: longitude,
      isOpen: isOpen,
    );
  }
}
