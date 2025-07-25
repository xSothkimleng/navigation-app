import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:salesquake_app/screens/sales/route_planner/create_opportunity_waypoint.dart';
import 'package:salesquake_app/screens/sales/route_planner/route_planner_screen.dart';

class RouteData {
  final List<LatLng> coordinates;
  final double distance;
  final double duration;
  final List<String> instructions;

  RouteData({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.instructions,
  });

  // Helper getters for display
  String get distanceText {
    if (distance < 1000) {
      return '${distance.round()} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  String get durationText {
    int minutes = (duration / 60).round();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }
}

class RouteMapScreen extends StatefulWidget {
  final PlannedRoute? plannedRoute;

  const RouteMapScreen({super.key, this.plannedRoute});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(11.583934602643119, 104.89766061132211);
  LatLng? _destination;
  RouteData? _routeData;
  List<LatLng> _waypoints = [];
  bool _isLoadingLocation = false;
  bool _isLoadingRoute = false;
  bool _isCreatingActivity = false;

  @override
  void initState() {
    super.initState();

    if (widget.plannedRoute != null) {
      _initializeWithPlannedRoute();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeWithPlannedRoute() {
    final route = widget.plannedRoute!;
    final locations = route.locations;

    if (locations.isNotEmpty) {
      // Set first location as starting point (or keep current location)
      // Set waypoints for middle locations
      // Set last location as destination

      if (locations.length == 1) {
        _destination = LatLng(locations[0].latitude, locations[0].longitude);
      } else {
        // First location becomes destination, others become waypoints
        _destination = LatLng(locations.last.latitude, locations.last.longitude);

        // Add all locations except the last one as waypoints
        _waypoints = locations.take(locations.length - 1).map((loc) => LatLng(loc.latitude, loc.longitude)).toList();
      }

      // Fit map to show all locations and calculate route
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapToLocations(locations);
        _calculateRoute(); // Automatically calculate route on load
      });
    }
  }

  void _fitMapToLocations(List<Location> locations) {
    if (locations.isEmpty) return;

    // Include current location in bounds calculation
    List<LatLng> allPoints = [_currentLocation];
    allPoints.addAll(locations.map((loc) => LatLng(loc.latitude, loc.longitude)));

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (final point in allPoints) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showMessage('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showMessage('Location permission denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_currentLocation, 15.0);
    } catch (e) {
      _showMessage('Error getting location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _calculateRoute() async {
    if (_destination == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      // OpenRouteService API
      final routeData = await _getRouteFromAPI(_currentLocation, _destination!, _waypoints);

      setState(() {
        _routeData = routeData;
      });

      // Fit the map to show the entire route
      _fitMapToRoute();

      _showMessage('Route detailed: ${routeData.distanceText}, ${routeData.durationText}');
    } catch (e) {
      _showMessage('Error routing: $e');
      print('Route calculation error: $e');
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  // OpenRouteService API call with waypoints support
  Future<RouteData> _getRouteFromAPI(LatLng start, LatLng end, List<LatLng> waypoints) async {
    List<String> coordinateStrings = [];

    // Add start coordinate
    coordinateStrings.add('${start.longitude},${start.latitude}');

    // Add waypoints
    for (final waypoint in waypoints) {
      coordinateStrings.add('${waypoint.longitude},${waypoint.latitude}');
    }

    // Add destination
    coordinateStrings.add('${end.longitude},${end.latitude}');

    // Join with semicolons
    String coordinatesParam = coordinateStrings.join(';');

    // Build URL for Android Emulator
    final url = Uri.parse('http://10.0.2.2:5000/route/v1/driving/$coordinatesParam?overview=full&geometries=polyline');

    print("Coordinates Param: $coordinatesParam");
    // Make GET request (no authorization header needed)
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      print("Data: $data");

      // Check if the response code is "Ok"
      if (data['code'] != 'Ok') {
        throw Exception('Route calculation failed: ${data['code']}');
      }

      return _parseRouteResponse(data);
    } else {
      throw Exception('Failed to get route: ${response.statusCode} - ${response.body}');
    }
  }

  RouteData _parseRouteResponse(Map<String, dynamic> data) {
    final route = data['routes'][0];
    print("Routess: $route");
    final geometry = route['geometry'];
    print("Geometryss: $geometry");

    // Get duration and distance directly from route object
    final double distance = route['distance']?.toDouble() ?? 0.0;
    final double duration = route['duration']?.toDouble() ?? 0.0;

    // Handle geometry (should be encoded polyline string)
    List<LatLng> coordinates;
    if (geometry is String) {
      coordinates = _decodeEncodedPolyline(geometry);
    } else {
      throw Exception('Expected encoded polyline string, got: ${geometry.runtimeType}');
    }

    // Extract instructions from all legs
    List<String> instructions = [];
    final legs = route['legs'] as List? ?? [];

    for (final leg in legs) {
      final steps = leg['steps'] as List? ?? [];
      for (final step in steps) {
        if (step['instruction'] != null && step['instruction'].toString().isNotEmpty) {
          instructions.add(step['instruction'].toString());
        }
      }
    }

    // If no instructions available, add a default message
    if (instructions.isEmpty) {
      instructions.add('Navigate to destination');
    }

    return RouteData(
      coordinates: coordinates,
      distance: distance,
      duration: duration,
      instructions: instructions,
    );
  }

  void _setDestinationFromOpportunity(Map<String, dynamic> locationData) {
    final newDestination = LatLng(locationData['latitude'], locationData['longitude']);

    setState(() {
      // Reset everything - clear waypoints and route
      _waypoints.clear();
      _routeData = null;
      _destination = newDestination;
    });

    // Center map on the new destination
    _mapController.move(newDestination, 15.0);

    // Show confirmation message
    _showMessage('Destination set: ${locationData['name']}');
  }

  // Decode coordinate array to LatLng coordinates
  List<LatLng> _decodeCoordinateArray(List<dynamic> coordinates) {
    return coordinates.map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble())).toList();
  }

  // Decode encoded polyline string (Google's polyline algorithm)
  List<LatLng> _decodeEncodedPolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Fit map to show the entire route
  void _fitMapToRoute() {
    if (_routeData == null) return;

    final coordinates = _routeData!.coordinates;
    if (coordinates.isEmpty) return;

    // Calculate bounds
    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (final coord in coordinates) {
      minLat = math.min(minLat, coord.latitude);
      maxLat = math.max(maxLat, coord.latitude);
      minLng = math.min(minLng, coord.longitude);
      maxLng = math.max(maxLng, coord.longitude);
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  void _clearDestination() {
    setState(() {
      _destination = null;
      _waypoints.clear();
      _routeData = null;
    });
  }

  void _showCreateActivityDialog(LatLng location) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Activity Name'),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Save activity (you'll need to make activities list dynamic)
              _showMessage('Activity "${nameController.text}" created!');
              setState(() => _isCreatingActivity = false);
              Navigator.pop(context);
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_isCreatingActivity) {
      _showCreateActivityDialog(point);
      return;
    }

    // Existing destination logic
    setState(() {
      if (_destination == null) {
        _destination = point;
      } else {
        _waypoints.add(_destination!);
        _destination = point;
      }
      _routeData = null;
    });
  }

  void _removeWaypoint(int index) {
    setState(() {
      _waypoints.removeAt(index);
      _routeData = null; // Clear route when waypoints change
    });
  }

  void _clearAllWaypoints() {
    setState(() {
      _waypoints.clear();
      _routeData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plannedRoute?.name ?? 'Route Map'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.navigation_map_app',
              ),

              // Route polyline (if route exists)
              if (_routeData != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeData!.coordinates,
                      strokeWidth: 5.0,
                      color: Colors.blue,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  // Current location marker
                  Marker(
                    point: _currentLocation,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),

                  // Waypoint markers
                  ..._waypoints.asMap().entries.map((entry) {
                    int index = entry.key;
                    LatLng waypoint = entry.value;
                    return Marker(
                      point: waypoint,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // Destination marker
                  if (_destination != null)
                    Marker(
                      point: _destination!,
                      child: const Icon(
                        Icons.pin_drop,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Current location button
          Positioned(
            top: 20,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              backgroundColor: Colors.white,
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          Positioned(
            top: 70,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () async {
                // Navigate to OpportunitiesWayPointListScreen for waypoint selection
                final result = await Navigator.push<List<LatLng>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpportunitiesWayPointListScreen(
                      isWaypointSelection: true, // Enable waypoint selection mode
                      onWaypointsSelected: (List<LatLng> selectedWaypoints) {
                        // This callback will be called when user confirms selection
                        setState(() {
                          _waypoints.addAll(selectedWaypoints);
                          _routeData = null; // Clear existing route
                        });

                        // Optionally auto-calculate route with new waypoints
                        if (_destination != null) {
                          _calculateRoute();
                        }

                        _showMessage('${selectedWaypoints.length} waypoint(s) added');
                      },
                    ),
                  ),
                );

                // Handle result if returned via Navigator.pop (alternative approach)
                if (result != null && result.isNotEmpty) {
                  setState(() {
                    _waypoints.addAll(result);
                    _routeData = null;
                  });

                  if (_destination != null) {
                    _calculateRoute();
                  }

                  _showMessage('${result.length} waypoint(s) added');
                }
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.add_location, color: Colors.blue),
            ),
          ),

          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    final bool canNavigate = _destination != null;

    return DraggableScrollableSheet(
      initialChildSize: _routeData != null ? 0.4 : 0.3,
      minChildSize: 0.25,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Route summary (if route exists)
                if (_routeData != null) ...[
                  _buildRouteSummary(),
                  const SizedBox(height: 16),
                ],

                // Current Location Section
                _buildLocationSection(
                  icon: Icons.location_on,
                  title: "Current Location",
                  subtitle: "Lat: ${_currentLocation.latitude.toStringAsFixed(4)}, Lng: ${_currentLocation.longitude.toStringAsFixed(4)}",
                  isActive: true,
                ),

                const SizedBox(height: 16),

                // Waypoints Section
                if (_waypoints.isNotEmpty) ...[
                  _buildWaypointsSection(),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 16),

                // Destination Section
                _buildLocationSection(
                  icon: Icons.pin_drop,
                  title: "Destination",
                  subtitle: _destination == null
                      ? "Tap on map to select destination"
                      : "Lat: ${_destination!.latitude.toStringAsFixed(4)}, Lng: ${_destination!.longitude.toStringAsFixed(4)}",
                  isActive: _destination != null,
                  showClear: _destination != null,
                  onClear: _clearDestination,
                ),

                const SizedBox(height: 24),

                // Calculate Route Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: canNavigate && !_isLoadingRoute ? _calculateRoute : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canNavigate ? Colors.blue : Colors.grey[300],
                      foregroundColor: canNavigate ? Colors.white : Colors.grey[600],
                      elevation: canNavigate ? 4 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoadingRoute
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Calculating Route...'),
                            ],
                          )
                        : Text(
                            _routeData != null ? 'Recalculate Route' : 'Get Directions',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRouteSummary() {
    if (_routeData == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.route, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Route Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_routeData!.distanceText} • ${_routeData!.durationText}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaypointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.route, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Waypoints (${_waypoints.length})',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_waypoints.isNotEmpty)
              TextButton(
                onPressed: _clearAllWaypoints,
                child: const Text('Clear All', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_waypoints.length, (index) {
          final waypoint = _waypoints[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.orange,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Waypoint ${index + 1}: ${waypoint.latitude.toStringAsFixed(4)}, ${waypoint.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  iconSize: 20,
                  onPressed: () => _removeWaypoint(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLocationSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    bool showClear = false,
    VoidCallback? onClear,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.blue : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.blue : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showClear && onClear != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
