import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:volunteer/data/models/facility.dart';
import 'package:volunteer/shared/constants/app_colors.dart';

class LocationMap extends StatefulWidget {
  const LocationMap({
    super.key,
    required this.facilities,
    required this.userLocation,
    required this.selectedFacility,
    required this.onFacilitySelected,
    required this.onLocatePressed,
    required this.isLocating,
  });

  final List<Facility> facilities;
  final LatLng? userLocation;
  final Facility? selectedFacility;
  final ValueChanged<Facility> onFacilitySelected;
  final VoidCallback onLocatePressed;
  final bool isLocating;

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  static const _bandungCenter = LatLng(-6.9175, 107.6191);

  final _mapController = MapController();
  bool _mapReady = false;

  @override
  void didUpdateWidget(covariant LocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_mapReady) return;

    final selected = widget.selectedFacility;
    if (selected != null && selected != oldWidget.selectedFacility) {
      _mapController.move(
        LatLng(selected.latitude, selected.longitude),
        15,
      );
    } else if (widget.userLocation != null &&
        widget.userLocation != oldWidget.userLocation) {
      _mapController.move(widget.userLocation!, 14);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.userLocation ?? _bandungCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13,
            minZoom: 4,
            maxZoom: 18,
            onMapReady: () => _mapReady = true,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.volunteer',
            ),
            MarkerLayer(
              markers: [
                for (final facility in widget.facilities)
                  Marker(
                    point: LatLng(facility.latitude, facility.longitude),
                    width: 44,
                    height: 48,
                    child: Tooltip(
                      message: facility.name,
                      child: GestureDetector(
                        onTap: () => widget.onFacilitySelected(facility),
                        child: Icon(
                          Icons.location_on,
                          size: 40,
                          color: widget.selectedFacility?.name == facility.name
                              ? AppColors.primaryColor
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                if (widget.userLocation case final userLocation?)
                  Marker(
                    point: userLocation,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.circle, color: Colors.blue, size: 8),
                      ),
                    ),
                  ),
              ],
            ),
            SimpleAttributionWidget(
              source: const Text('OpenStreetMap contributors'),
              alignment: Alignment.bottomLeft,
              backgroundColor: Colors.white.withValues(alpha: 0.85),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  _MapControl(
                    icon: Icons.add,
                    label: 'Perbesar peta',
                    onPressed: () {
                      final camera = _mapController.camera;
                      _mapController.move(camera.center, camera.zoom + 1);
                    },
                  ),
                  const SizedBox(height: 8),
                  _MapControl(
                    icon: Icons.remove,
                    label: 'Perkecil peta',
                    onPressed: () {
                      final camera = _mapController.camera;
                      _mapController.move(camera.center, camera.zoom - 1);
                    },
                  ),
                  const SizedBox(height: 8),
                  _MapControl(
                    icon: widget.isLocating
                        ? Icons.hourglass_top
                        : Icons.my_location,
                    label: 'Gunakan lokasi saya',
                    onPressed:
                        widget.isLocating ? null : widget.onLocatePressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        color: AppColors.textPrimary,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
