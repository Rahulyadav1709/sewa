// ignore_for_file: sort_child_properties_last

import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';
import 'package:sewa/global/app_styles.dart';
import 'package:sewa/global/app_colors.dart';

import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';

class LocationTab extends StatefulWidget {
  final void Function(double latitude, double longitude) onLocationSelected;
  final String? assetName;
  final String? equipmentNo;
  final String? lat;
  final String? long;
  final String? base64Image;
  final String? recordNo;
  final String? status;
  final String? updatelat;
  final String? updatelong;

  const LocationTab({
    super.key,
    required this.onLocationSelected,
    this.assetName,
    this.equipmentNo,
    this.base64Image,
    this.lat,
    this.long,
    this.recordNo,
    this.status,
    this.updatelat,
    this.updatelong,
  });

  @override
  _LocationTabState createState() => _LocationTabState();
}

class _LocationTabState extends State<LocationTab>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  BitmapDescriptor? normalMarker;
  BitmapDescriptor? shiningMarker;
  bool isShining = false;
  Timer? _timer;
  GoogleMapController? mapController;
  bool _isUserInteracting = false;
  MapType _currentMapType = MapType.normal;
  bool isMapCreated = false;
  bool _isUpdatingLocation = false;
  bool _showLocationDetails = false;
  String? lastKnownAddress;
  
  // Manual location selection
  bool _isManualSelectionMode = false;
  LatLng? _manuallySelectedLocation;
  BitmapDescriptor? _manualMarkerIcon;

  late AnimationController _fabAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _pulseAnimation;

  final ClientMgrHomeController homeController =
      Get.find<ClientMgrHomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Only check permission status on init, don't automatically request
    homeController.getLocation(requestIfNeeded: false);
    _setCustomMarkers();
    _initAnimations();
    _createManualMarker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Re-check permission status when app resumes (returning from settings or background)
      // Do NOT auto-request here to avoid loops
      homeController.getLocation(requestIfNeeded: false);
    }
  }

  void _initAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fabAnimationController.forward();
    _pulseAnimationController.repeat(reverse: true);
  }

  Future<void> _createManualMarker() async {
    _manualMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _fabAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Future<ui.Image> resizeImage(Uint8List data, int width, int height) async {
    ui.Codec codec = await ui.instantiateImageCodec(
      data,
      targetWidth: width,
      targetHeight: height,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<Uint8List> addBorderToImage(
    ui.Image image,
    double borderWidth,
    Color borderColor,
    bool isShining,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

    if (isShining) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
      paint.color = borderColor.withOpacity(0.8);
    }

    final size = Size(image.width.toDouble(), image.height.toDouble());
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRect(rect.translate(2, 2), shadowPaint);
    canvas.drawImageRect(image, rect, rect, Paint());
    canvas.drawRect(rect, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _setCustomMarkers() async {
    if (widget.base64Image != null && widget.base64Image!.isNotEmpty) {
      try {
        Uint8List markerImageBytes = base64Decode(widget.base64Image!);
        ui.Image resizedImage = await resizeImage(markerImageBytes, 120, 120);

        Uint8List normalImageBytes = await addBorderToImage(
          resizedImage,
          4,
          Colors.green,
          false,
        );
        Uint8List shiningImageBytes = await addBorderToImage(
          resizedImage,
          6,
          Colors.greenAccent,
          true,
        );

        normalMarker = BitmapDescriptor.fromBytes(normalImageBytes);
        shiningMarker = BitmapDescriptor.fromBytes(shiningImageBytes);
      } catch (e) {
        log('Error creating custom markers: $e');
        _setDefaultMarkers();
      }
    } else {
      _setDefaultMarkers();
    }

    _startBlinking();
    if (mounted) setState(() {});
  }

  void _setDefaultMarkers() {
    normalMarker = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueGreen,
    );
    shiningMarker = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueGreen,
    );
  }

  void _startBlinking() {
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          isShining = !isShining;
        });
      }
    });
  }

  void _toggleManualSelectionMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isManualSelectionMode = !_isManualSelectionMode;
      if (!_isManualSelectionMode) {
        _manuallySelectedLocation = null;
      }
    });
    
    if (_isManualSelectionMode) {
      _showSnackBar(
        'Tap on the map to select location',
        Colors.deepOrange,
      );
    } else {
      _showSnackBar('Manual selection cancelled', Colors.grey);
    }
  }

  void _onMapTapped(LatLng position) {
    if (_isManualSelectionMode) {
      HapticFeedback.selectionClick();
      setState(() {
        _manuallySelectedLocation = position;
      });
      _showSnackBar(
        'Location selected: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        Colors.deepOrange,
      );
    }
  }

  Future<void> _openGoogleMapsDirections() async {
    if (!_isValidCoordinate(widget.updatelat, widget.updatelong)) {
      _showSnackBar('Updated location data not available', Colors.red);
      return;
    }

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.updatelat},${widget.updatelong}';

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open Google Maps', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error opening directions: $e', Colors.red);
    }
  }

  Future<void> _openDirectionsToPreviousLocation() async {
    if (!_isValidCoordinate(widget.lat, widget.long)) {
      _showSnackBar('Previous location not available', Colors.orange);
      return;
    }

    try {
      final previousLat = _safeParseDouble(widget.lat);
      final previousLng = _safeParseDouble(widget.long);
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$previousLat,$previousLng';

      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open Google Maps', Colors.red);
      }
    } catch (e) {
      _showSnackBar(
        'Error opening directions: Invalid location data',
        Colors.red,
      );
      log('Error parsing location data: $e');
    }
  }

  void _navigateToPreviousLocation() {
    if (!_isValidCoordinate(widget.lat, widget.long) || mapController == null) {
      _showSnackBar('Previous location not available', Colors.orange);
      return;
    }

    try {
      final previousLat = _safeParseDouble(widget.lat);
      final previousLng = _safeParseDouble(widget.long);

      setState(() {
        _isUserInteracting = true;
      });

      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(previousLat, previousLng), zoom: 18),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        mapController!.showMarkerInfoWindow(const MarkerId("2"));
      });

      _showSnackBar('Navigated to previous location', Colors.blue);
    } catch (e) {
      _showSnackBar('Error navigating: Invalid location data', Colors.red);
      log('Error parsing location data: $e');
    }
  }

  void _toggleMapType() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal
              ? MapType.satellite
              : MapType.normal;
    });
  }

  void _resetToCurrentLocation() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isUserInteracting = false;
    });

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              homeController.latitude.value,
              homeController.longitude.value,
            ),
            zoom: 17,
          ),
        ),
      );
    }
    _showSnackBar('Returned to current location', Colors.green);
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  double _safeParseDouble(String? value, {double defaultValue = 0.0}) {
    if (value == null || value.trim().isEmpty) {
      return defaultValue;
    }
    try {
      return double.parse(value.trim());
    } catch (e) {
      log('Error parsing double value: $value, error: $e');
      return defaultValue;
    }
  }

  bool _isValidCoordinate(String? lat, String? lng) {
    if (lat == null ||
        lng == null ||
        lat.trim().isEmpty ||
        lng.trim().isEmpty) {
      return false;
    }
    try {
      final latValue = double.parse(lat.trim());
      final lngValue = double.parse(lng.trim());
      return latValue >= -90 &&
          latValue <= 90 &&
          lngValue >= -180 &&
          lngValue <= 180;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateLocation() async {
    if (_isUpdatingLocation) return;

    // Determine which location to use
    double latitude;
    double longitude;
    
    if (_manuallySelectedLocation != null) {
      latitude = _manuallySelectedLocation!.latitude;
      longitude = _manuallySelectedLocation!.longitude;
    } else {
      latitude = homeController.latitude.value;
      longitude = homeController.longitude.value;
    }

    setState(() {
      _isUpdatingLocation = true;
    });

    try {
      await homeController.updateAssetLocation(
        context,
        latitude: latitude.toString(),
        longitude: longitude.toString(),
        recordNo: widget.recordNo!,
        status: widget.status!,
        username: "TAQA_MGR",
      );

      _showSnackBar(
        _manuallySelectedLocation != null
            ? 'Manual location updated successfully!'
            : 'Current location updated successfully!',
        Colors.green,
      );
      HapticFeedback.mediumImpact();
      
      // Reset manual selection after successful update
      setState(() {
        _isManualSelectionMode = false;
        _manuallySelectedLocation = null;
      });
    } catch (e) {
      _showSnackBar('Failed to update location: $e', Colors.red);
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingLocation = false;
        });
      }
    }
  }

  void _toggleLocationDetails() {
    setState(() {
      _showLocationDetails = !_showLocationDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Check if location permission is denied or permanently denied
        if (homeController.locationPermission.value == LocationPermission.denied ||
            homeController.locationPermission.value == LocationPermission.deniedForever) {
          return _buildPermissionDeniedView();
        }
        
        // Show the map if permission is granted
        return Stack(
        children: [
          // Google Map
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  homeController.latitude.value,
                  homeController.longitude.value,
                ),
                zoom: 17,
              ),
              mapType: _currentMapType,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              onTap: _onMapTapped,
              onMapCreated: (GoogleMapController controller) {
                homeController.setGoogleMapController(controller);
                mapController = controller;
                setState(() {
                  isMapCreated = true;
                });
              },
              onCameraMoveStarted: () {
                setState(() {
                  _isUserInteracting = true;
                });
              },
              onCameraIdle: () {
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _isUserInteracting = false;
                    });
                  }
                });
              },
              markers: {
                // Manual selection marker
                if (_manuallySelectedLocation != null)
                  Marker(
                    markerId: const MarkerId("manual"),
                    position: _manuallySelectedLocation!,
                    draggable: true,
                    onDragEnd: (newPosition) {
                      setState(() {
                        _manuallySelectedLocation = newPosition;
                      });
                      _showSnackBar(
                        'Location updated: ${newPosition.latitude.toStringAsFixed(6)}, ${newPosition.longitude.toStringAsFixed(6)}',
                        Colors.deepOrange,
                      );
                    },
                    icon: _manualMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    infoWindow: InfoWindow(
                      title: 'Selected Location (Draggable)',
                      snippet:
                          'Lat: ${_manuallySelectedLocation!.latitude.toStringAsFixed(6)}\n'
                          'Lng: ${_manuallySelectedLocation!.longitude.toStringAsFixed(6)}',
                    ),
                  ),

                // Updated location marker
                if (_isValidCoordinate(widget.updatelat, widget.updatelong))
                  Marker(
                    markerId: const MarkerId("1"),
                    position: LatLng(
                      _safeParseDouble(widget.updatelat),
                      _safeParseDouble(widget.updatelong),
                    ),
                    draggable: false,
                    icon:
                        isShining
                            ? (shiningMarker ?? BitmapDescriptor.defaultMarker)
                            : (normalMarker ?? BitmapDescriptor.defaultMarker),
                    infoWindow: InfoWindow(
                      title:
                          "${widget.assetName ?? 'Asset'} - ${widget.equipmentNo ?? 'N/A'}",
                      snippet:
                          'Updated Location\n'
                          'Lat: ${_safeParseDouble(widget.updatelat).toStringAsFixed(6)}\n'
                          'Lng: ${_safeParseDouble(widget.updatelong).toStringAsFixed(6)}',
                    ),
                  ),

                // Previous location marker
                if (_isValidCoordinate(widget.lat, widget.long))
                  Marker(
                    markerId: const MarkerId("2"),
                    position: LatLng(
                      _safeParseDouble(widget.lat),
                      _safeParseDouble(widget.long),
                    ),
                    draggable: false,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                    infoWindow: InfoWindow(
                      title: 'Previous Location',
                      snippet:
                          'Lat: ${_safeParseDouble(widget.lat).toStringAsFixed(6)}\n'
                          'Lng: ${_safeParseDouble(widget.long).toStringAsFixed(6)}',
                    ),
                  ),
              },
            ),
          ),

          // Manual Selection Mode Banner
          if (_isManualSelectionMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange, Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manual Selection Mode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _manuallySelectedLocation != null
                                ? 'Location selected! You can drag the red marker to adjust.'
                                : 'Tap anywhere on the map to select location',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleManualSelectionMode,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // Location Info Card (only when not in manual mode)
          if (!_isManualSelectionMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 15,
              right: 15,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 24,
                        ),
                        Text(
                          'Current Location',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: _toggleLocationDetails,
                          child: Icon(
                            _showLocationDetails
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.my_location,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lat: ${homeController.latitude.value.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.my_location,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lng: ${homeController.longitude.value.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          if (_showLocationDetails) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Updated: ${DateTime.now().toString().substring(0, 19)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Action Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 150,
            right: 15,
            child: FadeTransition(
              opacity: _fabAnimation,
              child: Column(
                children: [
                  // Manual Selection Toggle
                  _buildFAB(
                    heroTag: "manualSelectionBtn",
                    onPressed: _toggleManualSelectionMode,
                    backgroundColor: _isManualSelectionMode ? Colors.deepOrange : Colors.deepOrange.shade300,
                    icon: _isManualSelectionMode ? Icons.edit_location : Icons.add_location_alt_outlined,
                    tooltip: 'Manual Location Selection',
                  ),
                  const SizedBox(height: 12),

                  // Map Type Toggle
                  _buildFAB(
                    heroTag: "mapTypeBtn",
                    onPressed: _toggleMapType,
                    backgroundColor: Colors.deepPurple,
                    icon:
                        _currentMapType == MapType.normal
                            ? Icons.satellite_alt
                            : Icons.map_outlined,
                    tooltip: 'Toggle Map Type',
                  ),
                  const SizedBox(height: 12),

                  // Previous Location
                  _buildFAB(
                    heroTag: "previousLocationBtn",
                    onPressed: _navigateToPreviousLocation,
                    backgroundColor: Colors.blue,
                    icon: Icons.history_outlined,
                    tooltip: 'Previous Location',
                  ),
                  const SizedBox(height: 12),

                  // Directions to Previous
                  _buildFAB(
                    heroTag: "directionsBtn",
                    onPressed: _openDirectionsToPreviousLocation,
                    backgroundColor: Colors.orange,
                    icon: Icons.directions_outlined,
                    tooltip: 'Directions to Previous',
                  ),
                  const SizedBox(height: 12),

                  // Reset to Current
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isUserInteracting ? _pulseAnimation.value : 1.0,
                        child: _buildFAB(
                          heroTag: "resetLocationBtn",
                          onPressed: _resetToCurrentLocation,
                          backgroundColor: Colors.green,
                          icon: Icons.my_location_outlined,
                          tooltip: 'Current Location',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUpdatingLocation ? null : _updateLocation,
                      icon:
                          _isUpdatingLocation
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Icon(
                                  _manuallySelectedLocation != null
                                      ? Icons.save_outlined
                                      : Icons.update_outlined,
                                ),
                      label: Text(
                        _isUpdatingLocation
                            ? 'Updating...'
                            : _manuallySelectedLocation != null
                                ? 'Save Manual Location'
                                : 'Update Location',
                        style: AppStyles.white_16_600,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            _manuallySelectedLocation != null
                                ? Colors.deepOrange
                                : const Color(0xFF0F9D58),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openGoogleMapsDirections,
                      icon: const Icon(Icons.directions_outlined),
                      label: Text(
                        'Get Directions',
                        style: AppStyles.white_16_600,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF4285F4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      }),
    );
  }

  Widget _buildPermissionDeniedView() {
    bool isPermanentlyDenied = homeController.locationPermission.value == LocationPermission.deniedForever;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              size: 80,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Location Access Required',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            isPermanentlyDenied
                ? 'Location permissions are permanently denied. Please enable them in your app settings to view the map and update assets.'
                : 'To view the asset location and update it, we need your location permission. This helps in precisely tagging assets on the field.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Obx(() => Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: homeController.isLocationLoading.value 
                    ? null 
                    : () async {
                      // Re-check actual status directly from controller to be safe
                      final currentPermission = await Geolocator.requestPermission();
                      final isForever = currentPermission == LocationPermission.deniedForever;
                      
                      print("🔘 Button pressed! Status: $currentPermission, isForever: $isForever");
                      
                      if (isForever) {
                        print("📱 Opening settings...");
                        await homeController.openSettings(context: context);
                      } else {
                        print("🔓 Requesting permission...");
                        await homeController.getLocation(requestIfNeeded: true);
                      }
                      print("✅ Button action completed");
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: homeController.isLocationLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        homeController.locationPermission.value == LocationPermission.deniedForever 
                          ? 'Open App Settings' 
                          : 'Grant Permission',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: homeController.isLocationLoading.value 
                  ? null 
                  : () async => await homeController.getLocation(requestIfNeeded: true),
                child: Text(
                  homeController.locationPermission.value == LocationPermission.deniedForever 
                    ? 'Already enabled? Click here to refresh' 
                    : 'Try Again',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildFAB({
    required String heroTag,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required IconData icon,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        mini: true,
        elevation: 4,
        child: Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
      ),
    );
  }
}