import 'dart:math';

/// A simple Sensor Fusion implementation primarily relying on gyro integration 
/// for short-term accuracy, combined with a Low-Pass Complimentary Filter 
/// against the Magnetometer for long-term drift correction.
class SensorFusion {
  double _heading = 0.0; // Current heading in radians
  double _lastTimestamp = 0.0;

  // Filter Coefficients
  // Higher = trust gyro more (less responsive to magnet fluctuations)
  // Lower = trust compass more
  double complementaryAlpha = 0.98;

  double get heading => _heading;

  /// Resets the heading (e.g., when snapping to a known hallway)
  void setHeading(double newHeading) {
    _heading = newHeading;
  }

  /// Update the filter using Gyroscope (rad/s) and Magnetometer (microteslas)
  /// If magnetometer is unavailable, we just integrate the gyroscope.
  void update(double gyroZ, double? magX, double? magY, double timestampMs) {
    if (_lastTimestamp == 0.0) {
      _lastTimestamp = timestampMs;
      // Initialize heading if magnetometer is available
      if (magX != null && magY != null) {
        _heading = _calculateCompassHeading(magX, magY);
      }
      return;
    }

    // Delta time in seconds
    double dt = (timestampMs - _lastTimestamp) / 1000.0;
    _lastTimestamp = timestampMs;

    // 1. Gyro Integration (Δ Yaw)
    // Subtracting or adding depends on device orientation. 
    // Usually gyroZ > 0 means counter-clockwise rotation around Z-axis.
    double gyroHeading = _heading + (gyroZ * dt);

    // 2. Compass Correction (if available)
    if (magX != null && magY != null) {
      double compassHeading = _calculateCompassHeading(magX, magY);
      
      // Ensure we don't interpolate across the ±PI boundary incorrectly
      double diff = compassHeading - gyroHeading;
      while (diff > pi) {
        diff -= 2 * pi;
      }
      while (diff < -pi) {
        diff += 2 * pi;
      }
      
      _heading = gyroHeading + ((1.0 - complementaryAlpha) * diff);
    } else {
      _heading = gyroHeading;
    }

    // Normalize to 0 -> 2PI
    while (_heading < 0) {
      _heading += 2 * pi;
    }
    while (_heading >= 2 * pi) {
      _heading -= 2 * pi;
    }
  }

  /// Calculates azimuth from Magnetometer (X, Y)
  double _calculateCompassHeading(double mx, double my) {
    // Note: Depends on device orientation (portrait/landscape constraint)
    // arctan2(My, Mx) is standard for a flat device.
    double heading = atan2(my, mx);
    if (heading < 0) {
      heading += 2 * pi;
    }
    return heading;
  }
}
