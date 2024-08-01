import 'dart:math';

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);

  static const earthRadius = 6371000; // Radius of the Earth in meters

  static double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  static double calculateDistance(LatLng student, LatLng teacher) {
    final double startLatRadians = degreesToRadians(student.latitude);
    final double endLatRadians = degreesToRadians(teacher.latitude);
    final double deltaLatRadians =
        degreesToRadians(teacher.latitude - student.latitude);
    final double deltaLonRadians =
        degreesToRadians(teacher.longitude - student.longitude);

    // Haversine formula
    final double a = sin(deltaLatRadians / 2) * sin(deltaLatRadians / 2) +
        cos(startLatRadians) *
            cos(endLatRadians) *
            sin(deltaLonRadians / 2) *
            sin(deltaLonRadians / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Calculate distance
    final double distance = earthRadius * c;

    return distance;
  }

  bool isWithinDistance(LatLng other, double maxDistance) {
    double distance = calculateDistance(this, other);
    return distance <= maxDistance;
  }
}
