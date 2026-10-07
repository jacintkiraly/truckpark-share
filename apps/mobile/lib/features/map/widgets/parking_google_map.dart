import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../localization/generated/app_localizations.dart';
import '../../parking/domain/entities/parking_spot.dart';
import '../../parking/domain/value_objects/parking_map_cluster.dart';
import '../../parking/domain/value_objects/parking_viewport.dart';
import '../../parking/presentation/screens/edit_parking_screen.dart';
import '../../parking/presentation/widgets/parking_card.dart';
import '../models/driver_location.dart';

class ParkingGoogleMap extends StatefulWidget {
  const ParkingGoogleMap({
    super.key,
    required this.location,
    required this.onViewportChanged,
    required this.onClusterViewportChanged,
  });

  final DriverLocation location;

  final Future<List<ParkingSpot>> Function(ParkingViewport viewport)
  onViewportChanged;

  final Future<List<ParkingMapCluster>> Function(ParkingViewport viewport)
  onClusterViewportChanged;

  @override
  State<ParkingGoogleMap> createState() => _ParkingGoogleMapState();
}

class _ParkingGoogleMapState extends State<ParkingGoogleMap> {
  static const double _individualMarkerMinZoom = 8.0;

  static const ClusterManagerId _parkingClusterManagerId = ClusterManagerId(
    'parking',
  );

  late final Set<ClusterManager> _clusterManagers = {
    ClusterManager(
      clusterManagerId: _parkingClusterManagerId,
      onClusterTap: _handleClusterTap,
    ),
  };

  ParkingSpot? _selectedParkingSpot;

  GoogleMapController? _mapController;

  static const Duration _viewportDebounceDuration = Duration(milliseconds: 250);

  Timer? _viewportDebounceTimer;

  final List<ParkingSpot> _visibleParkingSpots = [];
  final List<ParkingMapCluster> _clusters = [];

  final Map<int, BitmapDescriptor> _clusterIconCache = {};
  BitmapDescriptor? _driverLocationIcon;
  BitmapDescriptor? _driverHeadingIcon;

  static const double _maxDriverHeadingAccuracy = 45.0;

  bool _followDriver = true;
  bool _programmaticCameraMove = false;
  bool _followCameraUpdateInProgress = false;
  bool _followCameraUpdateQueued = false;

  CameraPosition? _lastCameraPosition;

  bool _isLowZoom = false;

  String? _lastViewportKey;

  bool _viewportReadInProgress = false;
  bool _viewportReadQueued = false;

  int _spotRequestId = 0;
  int _clusterRequestId = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_prepareDriverLocationIcon());
  }

  Future<BitmapDescriptor> _createDriverLocationIcon() async {
    const double size = 96;
    const double centerCoordinate = size / 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(centerCoordinate, centerCoordinate);

    // Soft blue halo.
    final haloPaint = Paint()
      ..color = const Color(0x553A86FF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 29, haloPaint);

    // White outer ring.
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 21, outerPaint);

    // TruckPark Share blue center.
    final bluePaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 17, bluePaint);

    // White center dot.
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerPaint);

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    image.dispose();

    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }

    return BitmapDescriptor.bytes(
      byteData.buffer.asUint8List(),
      width: 40,
      height: 40,
    );
  }

  Future<BitmapDescriptor> _createDriverHeadingIcon() async {
    const double size = 96;
    const double centerCoordinate = size / 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(centerCoordinate, centerCoordinate);

    // Soft blue halo.
    final haloPaint = Paint()
      ..color = const Color(0x553A86FF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 30, haloPaint);

    // White outer ring.
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 22, outerPaint);

    // TruckPark Share blue directional arrow.
    final arrowPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(center.dx, center.dy - 19)
      ..lineTo(center.dx + 14, center.dy + 15)
      ..lineTo(center.dx, center.dy + 9)
      ..lineTo(center.dx - 14, center.dy + 15)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);

    // White center.
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 5, centerPaint);

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    image.dispose();

    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }

    return BitmapDescriptor.bytes(
      byteData.buffer.asUint8List(),
      width: 40,
      height: 40,
    );
  }

  Future<void> _prepareDriverLocationIcon() async {
    final icon = await _createDriverLocationIcon();
    final headingIcon = await _createDriverHeadingIcon();

    if (!mounted) {
      return;
    }

    setState(() {
      _driverLocationIcon = icon;
      _driverHeadingIcon = headingIcon;
    });
  }

  Marker _buildDriverLocationMarker() {
    final icon = _driverLocationIcon;

    if (icon == null) {
      throw StateError('Driver location icon is not ready.');
    }

    final heading = widget.location.heading;
    final headingAccuracy = widget.location.headingAccuracy;

    final useHeading =
        heading != null &&
        heading.isFinite &&
        heading >= 0 &&
        heading < 360 &&
        headingAccuracy != null &&
        headingAccuracy.isFinite &&
        headingAccuracy >= 0 &&
        headingAccuracy <= _maxDriverHeadingAccuracy &&
        _driverHeadingIcon != null;

    return Marker(
      markerId: const MarkerId('driver_location'),
      position: LatLng(widget.location.latitude, widget.location.longitude),
      icon: useHeading ? _driverHeadingIcon! : icon,
      rotation: useHeading ? heading : 0,
      anchor: const Offset(0.5, 0.5),
      zIndexInt: 10000,
      flat: true,
    );
  }

  Set<Circle> _buildDriverAccuracyCircle() {
    final accuracy = widget.location.accuracy;

    if (!accuracy.isFinite || accuracy <= 0) {
      return const <Circle>{};
    }

    final radius = accuracy.clamp(1.0, 100.0);

    return {
      Circle(
        circleId: const CircleId('driver_accuracy'),
        center: LatLng(widget.location.latitude, widget.location.longitude),
        radius: radius,
        fillColor: const Color(0x263A86FF),
        strokeColor: const Color(0x883A86FF),
        strokeWidth: 1,
        zIndex: 999,
      ),
    };
  }

  Set<Marker> _buildParkingMarkers() {
    return _visibleParkingSpots.map((parkingSpot) {
      return Marker(
        markerId: MarkerId(parkingSpot.id),
        position: LatLng(
          parkingSpot.location.latitude,
          parkingSpot.location.longitude,
        ),
        clusterManagerId: _parkingClusterManagerId,
        infoWindow: InfoWindow(title: parkingSpot.name),
        onTap: () {
          setState(() {
            _selectedParkingSpot = parkingSpot;
          });
        },
      );
    }).toSet();
  }

  Set<Marker> _buildClusterMarkers() {
    return _clusters.map((cluster) {
      final icon = _clusterIconCache[cluster.count];

      return Marker(
        markerId: MarkerId('cluster_${cluster.id}'),
        position: LatLng(cluster.latitude, cluster.longitude),
        anchor: const Offset(0.5, 0.5),
        icon: icon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: '${cluster.count} parking spots'),
      );
    }).toSet();
  }

  Future<void> _handleClusterTap(Cluster cluster) async {
    final controller = _mapController;

    if (controller == null || !mounted) {
      return;
    }

    debugPrint(
      'PARKING MAP: cluster tapped '
      'count=${cluster.count} '
      'position=${cluster.position.latitude},'
      '${cluster.position.longitude}',
    );

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(cluster.bounds, 80),
      );
    } catch (error) {
      debugPrint('PARKING MAP CLUSTER ZOOM ERROR: $error');

      try {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(cluster.position, 11.0),
        );
      } catch (fallbackError) {
        debugPrint(
          'PARKING MAP CLUSTER FALLBACK ZOOM ERROR: '
          '$fallbackError',
        );
      }
    }
  }

  Future<BitmapDescriptor> _createClusterIcon(int count) async {
    final cachedIcon = _clusterIconCache[count];

    if (cachedIcon != null) {
      return cachedIcon;
    }

    const double size = 72;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(size / 2, size / 2);

    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, size / 2, outerPaint);

    canvas.drawCircle(center, size / 2 - 4, circlePaint);

    canvas.drawCircle(center, size / 2 - 4, borderPaint);

    final countText = count.toString();

    final double fontSize;

    if (countText.length <= 2) {
      fontSize = 24;
    } else if (countText.length == 3) {
      fontSize = 21;
    } else if (countText.length == 4) {
      fontSize = 18;
    } else {
      fontSize = 15;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: countText,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size - 8);

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    image.dispose();

    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }

    final icon = BitmapDescriptor.bytes(
      byteData.buffer.asUint8List(),
      width: 48,
      height: 48,
    );

    _clusterIconCache[count] = icon;

    return icon;
  }

  Future<void> _prepareClusterIcons(List<ParkingMapCluster> clusters) async {
    final counts = clusters
        .map((cluster) => cluster.count)
        .where((count) => count > 0)
        .toSet();

    await Future.wait(counts.map(_createClusterIcon));
  }

  String _buildViewportKey(ParkingViewport viewport, double zoom) {
    final int coordinatePrecision;

    if (zoom >= 12) {
      coordinatePrecision = 5;
    } else if (zoom >= 9) {
      coordinatePrecision = 4;
    } else {
      coordinatePrecision = 3;
    }

    return [
      zoom.toStringAsFixed(1),
      viewport.southWestLatitude.toStringAsFixed(coordinatePrecision),
      viewport.southWestLongitude.toStringAsFixed(coordinatePrecision),
      viewport.northEastLatitude.toStringAsFixed(coordinatePrecision),
      viewport.northEastLongitude.toStringAsFixed(coordinatePrecision),
    ].join('|');
  }

  Future<void> _emitCurrentViewport() async {
    final controller = _mapController;

    if (controller == null || !mounted) {
      return;
    }

    if (_viewportReadInProgress) {
      _viewportReadQueued = true;
      return;
    }

    _viewportReadInProgress = true;

    try {
      final zoom = await controller.getZoomLevel();
      final bounds = await controller.getVisibleRegion();

      if (!mounted) {
        return;
      }

      final viewport = ParkingViewport(
        southWestLatitude: bounds.southwest.latitude,
        southWestLongitude: bounds.southwest.longitude,
        northEastLatitude: bounds.northeast.latitude,
        northEastLongitude: bounds.northeast.longitude,
      );

      final viewportKey = _buildViewportKey(viewport, zoom);

      if (_lastViewportKey == viewportKey) {
        debugPrint('PARKING MAP VIEWPORT: duplicate viewport ignored');
        return;
      }

      _lastViewportKey = viewportKey;

      final lowZoom = zoom < _individualMarkerMinZoom;

      debugPrint(
        'PARKING MAP VIEWPORT: '
        'zoom=${zoom.toStringAsFixed(2)} '
        'mode=${lowZoom ? 'clusters' : 'individual'}',
      );

      if (_isLowZoom != lowZoom) {
        setState(() {
          _isLowZoom = lowZoom;
          _selectedParkingSpot = null;

          if (lowZoom) {
            _visibleParkingSpots.clear();
          } else {
            _clusters.clear();
          }
        });
      }

      if (lowZoom) {
        final requestId = ++_clusterRequestId;

        try {
          final clusters = await widget.onClusterViewportChanged(viewport);

          if (!mounted || requestId != _clusterRequestId || !_isLowZoom) {
            return;
          }

          await _prepareClusterIcons(clusters);

          if (!mounted || requestId != _clusterRequestId || !_isLowZoom) {
            return;
          }

          setState(() {
            _clusters
              ..clear()
              ..addAll(clusters);
          });

          final totalParkingSpots = clusters.fold<int>(
            0,
            (total, cluster) => total + cluster.count,
          );

          debugPrint(
            'PARKING MAP: coarse clusters displayed '
            '(${clusters.length} cells, '
            'totalCount=$totalParkingSpots)',
          );
        } catch (error) {
          debugPrint('PARKING MAP CLUSTER ERROR: $error');
        }

        return;
      }

      final requestId = ++_spotRequestId;

      try {
        final spots = await widget.onViewportChanged(viewport);

        if (!mounted || requestId != _spotRequestId || _isLowZoom) {
          return;
        }

        setState(() {
          _visibleParkingSpots
            ..clear()
            ..addAll(spots);

          final selectedId = _selectedParkingSpot?.id;

          if (selectedId != null &&
              !spots.any((parkingSpot) => parkingSpot.id == selectedId)) {
            _selectedParkingSpot = null;
          }
        });

        debugPrint(
          'PARKING MAP: individual markers displayed '
          '(${spots.length})',
        );
      } catch (error) {
        debugPrint('PARKING MAP MARKER ERROR: $error');
      }
    } finally {
      _viewportReadInProgress = false;

      if (_viewportReadQueued && mounted) {
        _viewportReadQueued = false;
        unawaited(_emitCurrentViewport());
      }
    }
  }

  void _scheduleViewportRefresh() {
    _viewportDebounceTimer?.cancel();

    _viewportDebounceTimer = Timer(_viewportDebounceDuration, () {
      _viewportDebounceTimer = null;

      if (!mounted) {
        return;
      }

      unawaited(_emitCurrentViewport());
    });
  }

  void _handleCameraMoveStarted() {
    if (_programmaticCameraMove) {
      return;
    }

    if (!_followDriver || !mounted) {
      return;
    }

    setState(() {
      _followDriver = false;
    });

    debugPrint('PARKING MAP: follow driver disabled by user gesture');
  }

  void _handleCameraMove(CameraPosition position) {
    _lastCameraPosition = position;
  }

  void _scheduleFollowCameraUpdate() {
    if (!_followDriver || !mounted || _mapController == null) {
      return;
    }

    if (_followCameraUpdateInProgress) {
      _followCameraUpdateQueued = true;
      return;
    }

    unawaited(_updateFollowCamera());
  }

  Future<void> _updateFollowCamera() async {
    final controller = _mapController;

    if (controller == null || !_followDriver || !mounted) {
      return;
    }

    _followCameraUpdateInProgress = true;
    _programmaticCameraMove = true;

    try {
      final currentCamera = _lastCameraPosition;

      final heading = widget.location.hasReliableHeading
          ? widget.location.heading!
          : currentCamera?.bearing ?? 0;

      final zoom = currentCamera?.zoom ?? 15;
      final tilt = currentCamera?.tilt ?? 0;

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(widget.location.latitude, widget.location.longitude),
            zoom: zoom,
            bearing: heading,
            tilt: tilt,
          ),
        ),
      );

      if (mounted && _followDriver) {
        _scheduleViewportRefresh();
      }
    } catch (error) {
      debugPrint('PARKING MAP FOLLOW CAMERA ERROR: $error');
    } finally {
      _programmaticCameraMove = false;
      _followCameraUpdateInProgress = false;

      if (_followCameraUpdateQueued) {
        _followCameraUpdateQueued = false;

        if (_followDriver && mounted) {
          unawaited(_updateFollowCamera());
        }
      }
    }
  }

  void _enableFollowDriver() {
    if (!mounted) {
      return;
    }

    setState(() {
      _followDriver = true;
      _lastViewportKey = null;
    });

    debugPrint('PARKING MAP: follow driver enabled by user');

    _scheduleFollowCameraUpdate();
  }

  void _handleMapCreated(GoogleMapController controller) {
    _mapController = controller;

    _scheduleFollowCameraUpdate();
  }

  void _handleCameraIdle() {
    if (_programmaticCameraMove) {
      return;
    }

    _scheduleViewportRefresh();
  }

  void _closeParkingCard() {
    setState(() {
      _selectedParkingSpot = null;
    });
  }

  @override
  void didUpdateWidget(covariant ParkingGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_followDriver) {
      return;
    }

    final locationChanged =
        oldWidget.location.latitude != widget.location.latitude ||
        oldWidget.location.longitude != widget.location.longitude ||
        oldWidget.location.heading != widget.location.heading;

    if (locationChanged) {
      _scheduleFollowCameraUpdate();
    }
  }

  @override
  void dispose() {
    _spotRequestId++;
    _clusterRequestId++;

    _viewportDebounceTimer?.cancel();
    _viewportDebounceTimer = null;

    _clusterIconCache.clear();

    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.location.latitude, widget.location.longitude),
            zoom: 15,
          ),
          markers: {
            if (_isLowZoom)
              ..._buildClusterMarkers()
            else
              ..._buildParkingMarkers(),
            if (_driverLocationIcon != null) _buildDriverLocationMarker(),
          },
          circles: _buildDriverAccuracyCircle(),
          clusterManagers: _clusterManagers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: true,
          onMapCreated: _handleMapCreated,
          onCameraMoveStarted: _handleCameraMoveStarted,
          onCameraMove: _handleCameraMove,
          onCameraIdle: _handleCameraIdle,
          onTap: (_) {
            if (_selectedParkingSpot != null) {
              _closeParkingCard();
            }
          },
        ),
        if (!_followDriver)
          Positioned(
            right: 16,
            bottom: 104,
            child: SafeArea(
              child: FloatingActionButton.small(
                heroTag: 'follow_driver_button',
                tooltip: 'Follow driver',
                onPressed: _enableFollowDriver,
                child: const Icon(Icons.my_location),
              ),
            ),
          ),
        if (_selectedParkingSpot != null)
          Positioned(
            left: 24,
            right: 24,
            bottom: 16,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 36),
                          child: ParkingCard(
                            parkingSpot: _selectedParkingSpot!,
                            driverLocation: widget.location,
                            onEdit: () {
                              final parkingSpot = _selectedParkingSpot;

                              if (parkingSpot == null) {
                                return;
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditParkingScreen(
                                    parkingSpot: parkingSpot,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            tooltip: l10n.close,
                            icon: const Icon(Icons.close),
                            onPressed: _closeParkingCard,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
