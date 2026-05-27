import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // For debugPrint, kIsWeb
import 'package:hospital_nav/services/sensor_fusion.dart';

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
  StreamSubscription? _magSub;
  StreamSubscription? _pedometerSub;
  Timer? _fusionTimer;

  final _stepController = StreamController<PdrStepEvent>.broadcast();
  Stream<PdrStepEvent> get onStepDetected => _stepController.stream;

  // Step Detection params
  double pixelsPerMeter = 8.55; // Default to Ground Floor scale
  double userHeightCm = 170.0;
  String userGender = 'Male';
  
  double get _physicalStepLengthMeters {
    if (userHeightCm <= 0) return 0.75;
    return userGender == 'Male' ? (userHeightCm * 0.415 / 100.0) : (userHeightCm * 0.413 / 100.0);
  }

  int _initialSteps = -1;
  int _lastSteps = -1;
  
  double _lastAccelX = 0.0;
  double _lastAccelY = 0.0;
  double _lastAccelZ = 0.0;

  double? _lastMagX;
  double? _lastMagY;
  double? _lastMagZ;

  double _lastGyroX = 0.0;
  double _lastGyroY = 0.0;
  double _lastGyroZ = 0.0;
  bool _hasGyro = false;
  
  // Debug values exposed for the UI
  int totalSteps = 0;
  double rawAccelZ = 0.0;
  double rawGyroZ = 0.0;

  void startCompass() {
    stopCompass(); // Clean up first
    if (kIsWeb) return;

    _lastAccelX = 0.0;
    _lastAccelY = 0.0;
    _lastAccelZ = 0.0;
    _lastGyroX = 0.0;
    _lastGyroY = 0.0;
    _lastGyroZ = 0.0;
    _lastMagX = null;
    _lastMagY = null;
    _lastMagZ = null;
    _hasGyro = false;

    try {
      _accelSub = accelerometerEventStream().listen((event) {
        rawAccelZ = event.z;
        _lastAccelX = event.x;
        _lastAccelY = event.y;
        _lastAccelZ = event.z;
      }, onError: (e) {
        debugPrint('Accelerometer Error: $e');
      });

      _gyroSub = gyroscopeEventStream().listen((event) {
        _hasGyro = true;
        rawGyroZ = event.z;
        _lastGyroX = event.x;
        _lastGyroY = event.y;
        _lastGyroZ = event.z;
      }, onError: (e) {
        debugPrint('Gyroscope Error (Likely unsupported device): $e');
      });

      _magSub = magnetometerEventStream().listen((event) {
        _lastMagX = event.x;
        _lastMagY = event.y;
        _lastMagZ = event.z;
      }, onError: (e) {
        debugPrint('Magnetometer Error: $e');
      });

      // Periodic timer for stable sensor fusion at 20Hz (50ms interval)
      _fusionTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        final ms = DateTime.now().millisecondsSinceEpoch.toDouble();
        _fusion.update(
          _lastAccelX, _lastAccelY, _lastAccelZ,
          _lastGyroX, _lastGyroY, _lastGyroZ,
          _lastMagX, _lastMagY, _lastMagZ,
          ms,
          hasGyro: _hasGyro,
        );
      });
    } catch (e) {
      debugPrint('Failed to initialize compass sensors: $e');
    }
  }

  void stopCompass() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _magSub?.cancel();
    _fusionTimer?.cancel();
  }

  Future<void> startPedometer() async {
    stopPedometer(); // Clean up first
    if (kIsWeb) return;

    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.activityRecognition.request();
    } else if (Platform.isIOS) {
      status = await Permission.sensors.request();
    } else {
      debugPrint('Unsupported platform for pedometer.');
      return;
    }

    if (!status.isGranted) {
      debugPrint('Pedometer permission denied!');
      return;
    }

    try {
      _pedometerSub = Pedometer.stepCountStream.listen((StepCount event) {
        if (_initialSteps == -1) {
          _initialSteps = event.steps;
          _lastSteps = event.steps;
        } else {
          int newSteps = event.steps - _lastSteps;
          for (int i = 0; i < newSteps; i++) {
            _onStep();
          }
          _lastSteps = event.steps;
        }
      }, onError: (e) {
        debugPrint('Pedometer Error: $e');
      });
    } catch (e) {
      debugPrint('Failed to initialize pedometer: $e');
    }
  }

  void stopPedometer() {
    _pedometerSub?.cancel();
  }

  void stop() {
    stopPedometer();
    stopCompass();
  }

  void reset(double initialHeading) {
    totalSteps = 0;
    _initialSteps = -1;
    _lastSteps = -1;
    _fusion.setHeading(initialHeading);
  }

  double get currentHeading => _fusion.heading;

  void _onStep() {
    totalSteps++;
    
    // Calculate delta vector based on heading
    double heading = _fusion.heading;
    
    // Heading 0 = North (UP on map, -Y)
    // Heading pi/2 = East (RIGHT on map, +X)
    double stepLengthPixels = _physicalStepLengthMeters * pixelsPerMeter;
    double dx = stepLengthPixels * sin(heading);
    double dy = -stepLengthPixels * cos(heading);

    _stepController.add(PdrStepEvent(dx, dy, heading));
  }
}
