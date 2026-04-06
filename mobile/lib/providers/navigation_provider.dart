import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/location_model.dart';
import '../models/route_response.dart';
import '../models/floor_summary.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';

/// Application-wide navigation state, consumed via Provider.
class NavigationProvider extends ChangeNotifier {
  final ApiService _api;
  final TtsService _tts;

  NavigationProvider({ApiService? api, TtsService? tts})
      : _api = api ?? ApiService(),
        _tts = tts ?? TtsService();

  // ── Backend connectivity ───────────────────────────────────────────────
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  // ── Accessibility ──────────────────────────────────────────────────────
  bool _accessibleOnly = false;
  bool get accessibleOnly => _accessibleOnly;

  // ── Location selection ─────────────────────────────────────────────────
  LocationModel? _fromLocation;
  LocationModel? _toLocation;
  LocationModel? get fromLocation => _fromLocation;
  LocationModel? get toLocation => _toLocation;

  // ── Search ─────────────────────────────────────────────────────────────
  List<LocationModel> _searchResults = [];
  List<LocationModel> get searchResults => _searchResults;
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // ── Destination menu (grouped by floor) ───────────────────────────────
  List<FloorSummary> _menu = [];
  List<FloorSummary> get menu => _menu;
  bool _menuLoading = false;
  bool get menuLoading => _menuLoading;

  // ── Active route ───────────────────────────────────────────────────────
  RouteResponse? _route;
  RouteResponse? get route => _route;
  bool _routeLoading = false;
  bool get routeLoading => _routeLoading;
  String? _routeError;
  String? get routeError => _routeError;

  // ── Voice navigation ───────────────────────────────────────────────────
  int _currentStepIndex = 0;
  int get currentStepIndex => _currentStepIndex;
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;
  bool _autoAdvance = true;
  bool get autoAdvance => _autoAdvance;

  // ── Recent locations ───────────────────────────────────────────────────
  List<LocationModel> _recentLocations = [];
  List<LocationModel> get recentLocations => _recentLocations;

  // ── Init ───────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _tts.init();
    await _loadPreferences();
    await checkConnectivity();
    _tts.onComplete(_onStepSpeechCompleted);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _accessibleOnly =
        prefs.getBool(AppConfig.accessibilityPrefKey) ?? false;
    final rawRecent = prefs.getString(AppConfig.recentLocationsKey);
    if (rawRecent != null) {
      try {
        final list = jsonDecode(rawRecent) as List<dynamic>;
        _recentLocations = list
            .map((e) =>
                LocationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.accessibilityPrefKey, _accessibleOnly);
    final raw = jsonEncode(
      _recentLocations.take(10).map((l) => l.toJson()).toList(),
    );
    await prefs.setString(AppConfig.recentLocationsKey, raw);
  }

  // ── Connectivity ───────────────────────────────────────────────────────

  Future<void> checkConnectivity() async {
    _isOnline = await _api.healthCheck();
    notifyListeners();
  }

  // ── Accessibility ──────────────────────────────────────────────────────

  void setAccessibleOnly(bool value) {
    if (_accessibleOnly == value) return;
    _accessibleOnly = value;
    notifyListeners();
    _savePreferences();
    if (_fromLocation != null && _toLocation != null) {
      fetchRoute(); // re-fetch with new preference
    }
  }

  // ── Location picking ───────────────────────────────────────────────────

  void setFromLocation(LocationModel loc) {
    _fromLocation = loc;
    _addRecent(loc);
    notifyListeners();
  }

  void setToLocation(LocationModel loc) {
    _toLocation = loc;
    _addRecent(loc);
    notifyListeners();
  }

  void swapLocations() {
    final tmp = _fromLocation;
    _fromLocation = _toLocation;
    _toLocation = tmp;
    notifyListeners();
  }

  void clearFrom() {
    _fromLocation = null;
    _route = null;
    _routeError = null;
    notifyListeners();
  }

  void clearTo() {
    _toLocation = null;
    _route = null;
    _routeError = null;
    notifyListeners();
  }

  void _addRecent(LocationModel loc) {
    _recentLocations.removeWhere((l) => l.code == loc.code);
    _recentLocations.insert(0, loc);
    if (_recentLocations.length > 10) {
      _recentLocations = _recentLocations.sublist(0, 10);
    }
    _savePreferences();
  }

  // ── Search ─────────────────────────────────────────────────────────────

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    try {
      _searchResults = await _api.searchLocations(query.trim());
    } catch (_) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // ── Menu ───────────────────────────────────────────────────────────────

  Future<void> loadMenu() async {
    if (_menu.isNotEmpty) return;
    _menuLoading = true;
    notifyListeners();
    try {
      _menu = await _api.getDestinationMenu();
    } catch (_) {
      _menu = [];
    } finally {
      _menuLoading = false;
      notifyListeners();
    }
  }

  // ── Route ──────────────────────────────────────────────────────────────

  Future<void> fetchRoute() async {
    if (_fromLocation == null || _toLocation == null) return;
    _routeLoading = true;
    _routeError = null;
    _route = null;
    _currentStepIndex = 0;
    notifyListeners();
    try {
      _route = await _api.getRoute(
        fromCode: _fromLocation!.code,
        toCode: _toLocation!.code,
        accessibleOnly: _accessibleOnly,
      );
    } on ApiException catch (e) {
      _routeError = e.message;
    } catch (e) {
      _routeError = 'Could not connect to server. Check your network.';
    } finally {
      _routeLoading = false;
      notifyListeners();
    }
  }

  void clearRoute() {
    _route = null;
    _routeError = null;
    _currentStepIndex = 0;
    _isSpeaking = false;
    notifyListeners();
  }

  // ── Voice navigation ───────────────────────────────────────────────────

  Future<void> speakCurrentStep() async {
    if (_route == null) return;
    if (_currentStepIndex >= _route!.steps.length) return;
    final step = _route!.steps[_currentStepIndex];
    _isSpeaking = true;
    notifyListeners();
    await _tts.speak(step.voice);
  }

  Future<void> speakFullRoute() async {
    if (_route == null) return;
    _isSpeaking = true;
    notifyListeners();
    await _tts.speak(_route!.voiceScript);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  void nextStep() {
    if (_route == null) return;
    if (_currentStepIndex < _route!.steps.length - 1) {
      _currentStepIndex++;
      notifyListeners();
      if (_autoAdvance) speakCurrentStep();
    }
  }

  void previousStep() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      notifyListeners();
      if (_autoAdvance) speakCurrentStep();
    }
  }

  void jumpToStep(int index) {
    if (_route == null) return;
    if (index >= 0 && index < _route!.steps.length) {
      _currentStepIndex = index;
      notifyListeners();
    }
  }

  void toggleAutoAdvance() {
    _autoAdvance = !_autoAdvance;
    notifyListeners();
  }

  void _onStepSpeechCompleted() {
    _isSpeaking = false;
    notifyListeners();
  }

  // ── Single location fetch (for quick actions) ─────────────────────────

  Future<LocationModel?> getLocation(String code) async {
    try {
      return await _api.getLocation(code);
    } catch (_) {
      return null;
    }
  }

  // ── Dispose ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }
}
