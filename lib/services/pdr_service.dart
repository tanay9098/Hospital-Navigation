import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:hospital_nav/services/sensor_fusion.dart';
// Removed unused import: package:hospital_nav/models/user_position.dart

class PdrStepEvent {
  final double deltaX;
  final double deltaY;
  final double heading;
  PdrStepEvent(this.deltaX, this.deltaY, this.heading);
}

class PdrService {
  final SensorFusion _fusion = SensorFusion();
  
  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;

  final _stepController = StreamController<PdrStepEvent>.broadcast();
  Stream<PdrStepEvent> get onStepDetected => _stepController.stream;

  // Step Detection params
  // TODO: Replace with real sensor calibration and dynamic step length
  static const double _stepLengthPixels = 35.0; // Assume 0.7m step * 50 pixels/m
  static const double _stepThreshold = 1.2; // G-force peak threshold
  
  bool _isStepReady = true;
  double _lastAccelMag = 0.0;
  
  // Debug values exposed for the UI
  int totalSteps = 0;
  double rawAccelZ = 0.0;
  double rawGyroZ = 0.0;

  void start() {
    stop(); // Always clean up first
    try {
      _accelSub = accelerometerEventStream().listen((event) {
        rawAccelZ = event.z;
        _processAccelerometer(event);
      }, onError: (e) {
        debugPrint('Accelerometer Error (Likely unsupported device): $e');
      });

      _gyroSub = gyroscopeEventStream().listen((event) {
        rawGyroZ = event.z;
        // Convert current timestamp to milliseconds manually
        final ms = DateTime.now().millisecondsSinceEpoch.toDouble();
        _fusion.update(event.z, null, null, ms); 
      }, onError: (e) {
        debugPrint('Gyroscope Error (Likely unsupported device): $e');
      });
    } catch (e) {
      debugPrint('Failed to initialize hardware sensors: $e');
    }
  }

  void stop() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
  }

  void reset(double initialHeading) {
    totalSteps = 0;
    _fusion.setHeading(initialHeading);
  }

  double get currentHeading => _fusion.heading;

  void _processAccelerometer(AccelerometerEvent event) {
    // Calculate magnitude vector
    double mag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    // Normalize against gravity
    double gForce = mag / 9.81; 

    // Simple Peak Detection logic
    if (gForce > _stepThreshold && _isStepReady && _lastAccelMag <= _stepThreshold) {
      _onStep();
      _isStepReady = false; // Lock
      
      // Unlock step detection after 300ms (debouncing human steps)
      Timer(const Duration(milliseconds: 300), () {
        _isStepReady = true;
      });
    }
    
    _lastAccelMag = gForce;
  }

  void _onStep() {
    totalSteps++;
    
    // Calculate delta vector based on heading
    double heading = _fusion.heading;
    
    // Note: Depends on coordinate system. 
    // Usually X increases to the right (East), Y increases downwards (South) in UI Canvas
    double dx = _stepLengthPixels * cos(heading);
    double dy = _stepLengthPixels * sin(heading);

    _stepController.add(PdrStepEvent(dx, dy, heading));
  }
}
