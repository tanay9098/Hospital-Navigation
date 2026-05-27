import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hospital_nav/models/user_position.dart';
import 'package:hospital_nav/services/pdr_service.dart';
import 'package:hospital_nav/models/floor_config.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'dart:math';

class PdrProvider extends ChangeNotifier {
  final PdrService _pdrService = PdrService();
  
  bool _isPdrEnabled = false;
  bool get isPdrEnabled => _isPdrEnabled;

  UserPosition? _currentPosition;
  UserPosition? get currentPosition => _currentPosition;

  Timer? _uiRefreshTimer;
  Timer? _compassTimer;
  double _lastNotifiedHeading = 0.0;
  NavigationProvider? _navProvider;

  /// Guards against fallback overwrite of user-selected origin.
  bool _hasUserSetOrigin = false;
  bool get hasUserSetOrigin => _hasUserSetOrigin;

  // Debug states
  int get totalSteps => _pdrService.totalSteps;
  double get currentHeading => _pdrService.currentHeading;
  double get rawAccelZ => _pdrService.rawAccelZ;
  double get rawGyroZ => _pdrService.rawGyroZ;

  // Biometric Config
  double get userHeightCm => _pdrService.userHeightCm;
  set userHeightCm(double value) {
    _pdrService.userHeightCm = value;
    notifyListeners();
  }

  String get userGender => _pdrService.userGender;
  set userGender(String value) {
    _pdrService.userGender = value;
    notifyListeners();
  }

  PdrProvider() {
    _pdrService.startCompass();
    _compassTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isPdrEnabled) {
        final newHeading = _pdrService.currentHeading;
        final headingDelta = (newHeading - _lastNotifiedHeading).abs();
        if (headingDelta > 0.017) {
          _lastNotifiedHeading = newHeading;
          notifyListeners();
        }
      }
    });

    _pdrService.onStepDetected.listen((event) {
      if (_currentPosition == null || !_isPdrEnabled) return;

      final newX = _currentPosition!.x + event.deltaX;
      final newY = _currentPosition!.y + event.deltaY;

      UserPosition rawPos = _currentPosition!.copyWith(
        x: newX,
        y: newY,
        heading: event.heading,
        isSimulated: false,
      );

      if (_navProvider != null) {
        double stepLengthPixels = sqrt(event.deltaX * event.deltaX + event.deltaY * event.deltaY);
        _currentPosition = _navProvider!.snapPdrPosition(rawPos, stepLengthPixels);
      } else {
        _currentPosition = rawPos;
      }

      debugPrint('[PDR] Step detected → snapped to (${_currentPosition!.x.toStringAsFixed(1)}, ${_currentPosition!.y.toStringAsFixed(1)}), heading: ${event.heading.toStringAsFixed(2)}');
      notifyListeners();
    });
  }

  void togglePdr(bool enable, [NavigationProvider? navProvider]) {
    _isPdrEnabled = enable;
    if (enable) {
      _navProvider = navProvider;
      _pdrService.startPedometer();
      _uiRefreshTimer?.cancel();
      _uiRefreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (_currentPosition != null) {
          final newHeading = _pdrService.currentHeading;
          // Only update if heading changed meaningfully (> ~1 degree)
          final headingDelta = (newHeading - _currentPosition!.heading).abs();
          if (headingDelta < 0.017 || (headingDelta - 2 * 3.14159).abs() < 0.017) {
            return; // Skip — heading hasn't changed enough
          }
          UserPosition updatedPos = _currentPosition!.copyWith(
            heading: newHeading,
          );
          if (_navProvider != null) {
            _currentPosition = _navProvider!.snapPdrPosition(updatedPos, 0.0);
          } else {
            _currentPosition = updatedPos;
          }
          notifyListeners();
        }
      });
      debugPrint('[PDR] Sensor tracking ENABLED');
    } else {
      _pdrService.stopPedometer();
      _uiRefreshTimer?.cancel();
      debugPrint('[PDR] Sensor tracking DISABLED');
      notifyListeners();
    }
  }

  void _updatePdrScale(int floorIndex) {
    final config = kFloorConfigs[floorIndex];
    if (config != null) {
      _pdrService.pixelsPerMeter = config.pixelsPerMeter;
    }
  }

  /// Initialize position from a real node selection (user-triggered).
  void initializePosition(double startX, double startY, int floor, double initialHeading) {
    _currentPosition = UserPosition(
      x: startX,
      y: startY,
      floor: floor,
      heading: initialHeading,
      isSimulated: false,
    );
    _hasUserSetOrigin = true;
    _updatePdrScale(floor);
    _pdrService.reset(initialHeading);
    debugPrint('[PDR] Origin SET by user → ($startX, $startY) floor $floor');
    notifyListeners();
  }

  /// Initialize with a default fallback ONLY if the user has not already set an origin.
  void initializeFallbackPosition(double startX, double startY, int floor, double initialHeading) {
    if (_hasUserSetOrigin) {
      debugPrint('[PDR] Fallback init BLOCKED — user origin already set at (${_currentPosition?.x}, ${_currentPosition?.y})');
      return;
    }
    _currentPosition = UserPosition(
      x: startX,
      y: startY,
      floor: floor,
      heading: initialHeading,
      isSimulated: false,
    );
    _updatePdrScale(floor);
    _pdrService.reset(initialHeading);
    debugPrint('[PDR] Fallback init → ($startX, $startY) floor $floor');
    notifyListeners();
  }

  /// Teleport PDR position to a new floor (e.g. after confirming a floor
  /// transition). Updates the tracked position, floor scale, and resets
  /// the sensor service so dead-reckoning continues from the new origin.
  void teleportToFloor(double x, double y, int floor) {
    final currentHeading = _pdrService.currentHeading;
    _currentPosition = UserPosition(
      x: x,
      y: y,
      floor: floor,
      heading: currentHeading,
      isSimulated: false,
    );
    _updatePdrScale(floor);
    _pdrService.reset(currentHeading);
    debugPrint('[PDR] Teleported to floor $floor → ($x, $y)');
    notifyListeners();
  }

  @override
  void dispose() {
    _uiRefreshTimer?.cancel();
    _compassTimer?.cancel();
    _pdrService.stop();
    super.dispose();
  }

  /// Optional override (e.g. snapped by Navigation Provider)
  void correctPosition(UserPosition corrected) {
    if (_currentPosition != null) {
      if (_currentPosition!.floor != corrected.floor) {
        _updatePdrScale(corrected.floor);
      }
      // Overwrite the position state but ensure we carry over properties correctly
      _currentPosition = corrected;
      // Note: Do not override rotation internally inside the sensor fusion service automatically,
      // map matching might be an artifact. For now just update the UI state.
      notifyListeners();
    }
  }
}
