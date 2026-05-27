import 'dart:math';

class SensorFusion {
  double _heading = 0.0;
  double _lastTimestamp = 0.0;

  // Trust gyro heavily for short term, compass slowly for long term
  double complementaryAlpha = 0.98;

  // Smoothed heading for UI display (low-pass filtered)
  double _smoothedHeading = 0.0;
  double smoothingFactor = 0.15; // lower = smoother, higher = more responsive

  double get heading => _smoothedHeading;
  double get rawHeading => _heading;

  void setHeading(double newHeading) {
    _heading = newHeading;
    _smoothedHeading = newHeading;
  }

  void update(
    double ax, double ay, double az,
    double gx, double gy, double gz,
    double? mx, double? my, double? mz,
    double timestampMs,
    {required bool hasGyro}
  ) {
    double normA = sqrt(ax*ax + ay*ay + az*az);

    if (!hasGyro) {
      if (mx != null && my != null && mz != null && normA > 0.1) {
        _heading = _calculateCompassHeading(ax, ay, az, mx, my, mz);
      }
      
      _lastTimestamp = timestampMs;

      // Apply exponential smoothing for display heading
      double displayDiff = _heading - _smoothedHeading;
      while (displayDiff > pi) displayDiff -= 2 * pi;
      while (displayDiff < -pi) displayDiff += 2 * pi;
      _smoothedHeading += smoothingFactor * displayDiff;
      while (_smoothedHeading < 0) _smoothedHeading += 2 * pi;
      while (_smoothedHeading >= 2 * pi) _smoothedHeading -= 2 * pi;
      return;
    }

    if (_lastTimestamp == 0.0) {
      _lastTimestamp = timestampMs;
      if (mx != null && my != null && mz != null) {
        _heading = _calculateCompassHeading(ax, ay, az, mx, my, mz);
      }
      return;
    }

    double dt = (timestampMs - _lastTimestamp) / 1000.0;
    _lastTimestamp = timestampMs;

    double deadband = 0.12; // Ignore walking vibrations (was 0.05)
    if (gx.abs() < deadband) gx = 0.0;
    if (gy.abs() < deadband) gy = 0.0;
    if (gz.abs() < deadband) gz = 0.0;

    double yawRate = 0.0;
    if (normA > 0.1) {
      yawRate = (gx * ax + gy * ay + gz * az) / normA;
    } else {
      yawRate = gz;
    }

    // Counter-clockwise rotation around gravity gives positive yawRate.
    // This turns the phone West. Heading is 0=North, pi/2=East, so West decreases heading.
    double gyroHeading = _heading - (yawRate * dt);

    if (mx != null && my != null && mz != null && normA > 0.1) {
      double compassHeading = _calculateCompassHeading(ax, ay, az, mx, my, mz);
      
      double diff = compassHeading - gyroHeading;
      while (diff > pi) diff -= 2 * pi;
      while (diff < -pi) diff += 2 * pi;

      // Only apply compass correction if the difference is meaningful (> 0.5°)
      // to avoid micro-jitter from noisy magnetometer
      if (diff.abs() > 0.009) {
        _heading = gyroHeading + ((1.0 - complementaryAlpha) * diff);
      } else {
        _heading = gyroHeading;
      }
    } else {
      _heading = gyroHeading;
    }

    // Normalize
    while (_heading < 0) _heading += 2 * pi;
    while (_heading >= 2 * pi) _heading -= 2 * pi;

    // Apply exponential smoothing for display heading
    double displayDiff = _heading - _smoothedHeading;
    while (displayDiff > pi) displayDiff -= 2 * pi;
    while (displayDiff < -pi) displayDiff += 2 * pi;
    _smoothedHeading += smoothingFactor * displayDiff;
    while (_smoothedHeading < 0) _smoothedHeading += 2 * pi;
    while (_smoothedHeading >= 2 * pi) _smoothedHeading -= 2 * pi;
  }

  double _calculateCompassHeading(double ax, double ay, double az, double mx, double my, double mz) {
    // Normalize U (Up vector from Accelerometer)
    double normU = sqrt(ax*ax + ay*ay + az*az);
    if (normU < 0.1) return _heading;
    double ux = ax / normU;
    double uy = ay / normU;
    double uz = az / normU;

    // Normalize M (Magnetometer vector)
    double normM = sqrt(mx*mx + my*my + mz*mz);
    if (normM < 0.1) return _heading;
    double mX = mx / normM;
    double mY = my / normM;
    double mZ = mz / normM;

    // E = M x U (East vector)
    double ex = mY * uz - mZ * uy;
    double ey = mZ * ux - mX * uz;
    double ez = mX * uy - mY * ux;
    double normE = sqrt(ex*ex + ey*ey + ez*ez);
    if (normE < 0.001) return _heading;
    ex /= normE;
    ey /= normE;
    ez /= normE;

    // N = U x E (North vector)
    double nx = uy * ez - uz * ey;
    double ny = uz * ex - ux * ez;
    double nz = ux * ey - uy * ex;
    
    // Phone's Forward vector in Portrait mode: F = U x (1, 0, 0)
    double fx = 0.0;
    double fy = uz;
    double fz = -uy;
    
    // Project Forward onto East and North
    double forwardEast = fx * ex + fy * ey + fz * ez;
    double forwardNorth = fx * nx + fy * ny + fz * nz;

    // Heading is angle from North to Forward
    double heading = atan2(forwardEast, forwardNorth);
    
    if (heading < 0) heading += 2 * pi;
    return heading;
  }
}
