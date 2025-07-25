import 'package:flutter/material.dart';
import 'package:salesquake_app/screens/sales/route_planner/route_map_screen.dart';

class PlannedRoute {
  final String id;
  final String name;
  final String description;
  final List<Location> locations;

  PlannedRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.locations,
  });
}

class Location {
  final String locationName;
  final double latitude;
  final double longitude;

  Location({
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });
}

class RoutePlannerScreen extends StatelessWidget {
  RoutePlannerScreen({Key? key}) : super(key: key);

  final List<PlannedRoute> plannedRoutes = [
    PlannedRoute(
      id: '1',
      name: 'Route 1',
      description: 'Description for Route 1',
      locations: [
        Location(locationName: 'Phsar Thmei', latitude: 11.569478, longitude: 104.920235),
        Location(locationName: 'Olympic Stadium', latitude: 11.559472, longitude: 104.910147),
      ],
    ),
    PlannedRoute(
      id: '2',
      name: 'Route 2',
      description: 'Description for Route 2',
      locations: [
        Location(locationName: 'Independence Monument', latitude: 11.557075, longitude: 104.928097),
        Location(locationName: 'Norea Park', latitude: 11.5487757, longitude: 104.9510837),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: ListView.builder(
          itemCount: plannedRoutes.length,
          itemBuilder: (context, index) {
            final route = plannedRoutes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: RouteCard(route: route),
            );
          },
        ),
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final PlannedRoute route;

  const RouteCard({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RouteMapScreen(plannedRoute: route),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      route.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                route.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${route.locations.length} locations',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
