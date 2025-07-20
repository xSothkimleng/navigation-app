typedef GeoPoint = List<double>;

class GeoLocation {
  final double latitude;
  final double longitude;

  GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  GeoPoint toGeoPoint() {
    return [latitude, longitude];
  }

  factory GeoLocation.fromGeoPoint(GeoPoint point) {
    return GeoLocation(
      latitude: point.isNotEmpty ? point[0] : 0.0,
      longitude: point.length > 1 ? point[1] : 0.0,
    );
  }
}
