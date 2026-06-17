import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  final Function(String address, double lat, double lng) onPicked;
  const LocationPickerScreen({super.key, required this.onPicked});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng _selectedLocation = const LatLng(30.0444, 31.2357);
  String _address = '';
  bool _tapped = false;
  bool _loadingAddress = false;

  Future<void> _onMapTap(LatLng point) async {
    // Always set coordinates as fallback address first (works on web + mobile)
    final coordAddress =
        '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';

    setState(() {
      _selectedLocation = point;
      _tapped = true;
      _loadingAddress =
          !kIsWeb; // only show loading on mobile where geocoding runs
      _address = coordAddress;
    });

    // Geocoding only works on mobile — skip entirely on web
    if (!kIsWeb) {
      try {
        final placemarks =
            await placemarkFromCoordinates(point.latitude, point.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [p.street, p.locality, p.administrativeArea]
              .where((s) => s != null && s.trim().isNotEmpty)
              .join(', ');
          if (parts.isNotEmpty && mounted) {
            setState(() => _address = parts);
          }
        }
      } catch (_) {
        // keep coordinate fallback — already set above
      } finally {
        if (mounted) setState(() => _loadingAddress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                  initialCenter: _selectedLocation,
                  initialZoom: 14,
                  onTap: (tapPosition, point) {
                    _onMapTap(point);
                  }),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sakina.sakina',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_loadingAddress)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Getting address...'),
                    ],
                  )
                else
                  Text(
                    _tapped ? _address : 'Tap on map to select location',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _tapped ? Colors.black : Colors.grey,
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Disabled until user taps the map
                    onPressed: _tapped
                        ? () {
                            widget.onPicked(
                              _address,
                              _selectedLocation.latitude,
                              _selectedLocation.longitude,
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Use this location'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
