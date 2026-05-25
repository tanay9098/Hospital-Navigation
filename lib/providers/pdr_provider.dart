import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hospital_nav/models/user_position.dart';
import 'package:hospital_nav/services/pdr_service.dart';
import 'package:hospital_nav/models/floor_config.dart';

class PdrProvider extends ChangeNotifier {
  final PdrService _pdrService = PdrService();
  
  bool _isPdrEnabled = false;
  bool get isPdrEnabled => _isPdrEnabled;

  UserPosition? _currentPosition;
  UserPosition? get currentPosition => _currentPosition;

  Timer? _uiRefreshTimer;

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
    _pdrService.onStepDetected.listen((event) {
      if (_currentPosition == null || !_isPdrEnabled) return;

      final newX = _currentPosition!.x + event.deltaX;
      final newY = _currentPosition!.y + event.deltaY;

      _currentPosition = _currentPosition!.copyWith(
        x: newX,
        y: newY,
        heading: event.heading,
        isSimulated: false,
      );

      debugPrint('[PDR] Step detected → position updated to (${newX.toStringAsFixed(1)}, ${newY.toStringAsFixed(1)}), heading: ${event.heading.toStringAsFixed(2)}');
    });
  }

  void togglePdr(bool enable) {
    _isPdrEnabled = enable;
    if (enable) {
      _pdrService.start();
      _uiRefreshTimer?.cancel();
      _uiRefreshTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
        if (_currentPosition != null) {
          _currentPosition = _currentPosition!.copyWith(
            heading: _pdrService.currentHeading,
          );
        }
        notifyListeners();
      });
      debugPrint('[PDR] Sensor tracking ENABLED');
    } else {
      _pdrService.stop();
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

  @override
  void dispose() {
    _uiRefreshTimer?.cancel();
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
