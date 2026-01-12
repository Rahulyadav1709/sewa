

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sewa/global/app_styles.dart';

class GoogleMapScreen extends StatefulWidget {
  final Function(double, double) onLocationSelected;

  GoogleMapScreen({required this.onLocationSelected});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Marker? _currentMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _updateMarker();
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
  }

  void _updateMarker() {
    setState(() {
      _currentMarker = Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentPosition!,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _currentPosition = newPosition;
            _updateMarker();  // Call to update marker after drag
          });
        },
          infoWindow: InfoWindow(
                      title: 'Latitude: ${_currentPosition!.latitude.toStringAsFixed(8).toString()}, Longitude: ${_currentPosition!.longitude.toStringAsFixed(8).toString()}',
                     
                    ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Location')),
      body: _currentPosition != null
          ? Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 17.0,
                  ),
                  myLocationEnabled: true,mapType: MapType.satellite,
                  myLocationButtonEnabled: true,
                  markers: _currentMarker != null ? {_currentMarker!} : {},
                  onTap: (LatLng position) {
                    setState(() {
                      _currentPosition = position;
                      _updateMarker();  // Update marker on map tap
                    });
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPosition != null) {
                        widget.onLocationSelected(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: const Color(0xFF0F9D58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Update Location',
                      style: AppStyles.white_16_600,
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
