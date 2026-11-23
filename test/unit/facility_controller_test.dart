import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:volunteer/controllers/facility_controller.dart';

void main() {
  test('nearby facilities use current GPS distance and sort nearest first', () {
    final controller = FacilityController()
      ..currentLocation.value = const LatLng(-6.9181, 107.6282);

    final nearby = controller.nearby;

    expect(nearby.first.name, 'Bank Darah Medika');
    expect(nearby.first.distanceKm, 0);
    expect(nearby.last.distanceKm, greaterThan(nearby.first.distanceKm));
  });
}
