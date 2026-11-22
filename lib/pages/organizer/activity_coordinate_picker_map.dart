import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:volunteer/shared/constants/app_colors.dart';

class ActivityCoordinatePickerMap extends StatefulWidget {
  const ActivityCoordinatePickerMap({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  final LatLng? selectedLocation;
  final ValueChanged<LatLng> onLocationSelected;

  @override
  State<ActivityCoordinatePickerMap> createState() =>
      _ActivityCoordinatePickerMapState();
}

class _ActivityCoordinatePickerMapState
    extends State<ActivityCoordinatePickerMap> {
  static const _bandungCenter = LatLng(-6.9175, 107.6191);

  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 280,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.selectedLocation ?? _bandungCenter,
            initialZoom: widget.selectedLocation == null ? 12 : 15,
            minZoom: 4,
            maxZoom: 18,
            onTap: (_, point) => widget.onLocationSelected(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.volunteer',
            ),
            if (widget.selectedLocation case final location?)
              MarkerLayer(
                markers: [
                  Marker(
                    point: location,
                    width: 44,
                    height: 48,
                    child: const Icon(
                      Icons.location_on,
                      size: 40,
                      color: AppColors.primaryColor,
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
              top: 10,
              right: 10,
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
                    icon: Icons.my_location,
                    label: 'Pusatkan ke titik terpilih',
                    onPressed: widget.selectedLocation == null
                        ? null
                        : () => _mapController.move(
                              widget.selectedLocation!,
                              15,
                            ),
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
