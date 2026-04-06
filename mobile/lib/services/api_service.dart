import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/location_model.dart';
import '../models/route_response.dart';
import '../models/floor_summary.dart';

/// Thin wrapper around the PES Hospital Navigation REST API.
class ApiService {
  final http.Client _client;
  final String _base;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _base = (baseUrl ?? AppConfig.baseUrl) + AppConfig.apiPrefix;

  // ── Health ────────────────────────────────────────────────────────────

  Future<bool> healthCheck() async {
    try {
      final res = await _client
          .get(Uri.parse('${AppConfig.baseUrl}/api/v1/health'))
          .timeout(AppConfig.requestTimeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Locations ─────────────────────────────────────────────────────────

  /// Search locations by keyword (name / description / category).
  Future<List<LocationModel>> searchLocations(String query) async {
    final uri = Uri.parse('$_base/locations/search')
        .replace(queryParameters: {'q': query});
    final res = await _client.get(uri).timeout(AppConfig.requestTimeout);
    _assertOk(res);
    final body = _decode(res);
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single location by its code.
  Future<LocationModel> getLocation(String code) async {
    final res = await _client
        .get(Uri.parse('$_base/locations/$code'))
        .timeout(AppConfig.requestTimeout);
    _assertOk(res);
    final body = _decode(res);
    return LocationModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// All locations on a specific floor.
  Future<List<LocationModel>> getFloorLocations(int floor) async {
    final res = await _client
        .get(Uri.parse('$_base/locations/floor/$floor'))
        .timeout(AppConfig.requestTimeout);
    _assertOk(res);
    final body = _decode(res);
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Navigation ────────────────────────────────────────────────────────

  /// Compute shortest path between two location codes.
  Future<RouteResponse> getRoute({
    required String fromCode,
    required String toCode,
    bool accessibleOnly = false,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$_base/navigation/route'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'from': fromCode,
            'to': toCode,
            'accessible': accessibleOnly,
          }),
        )
        .timeout(AppConfig.requestTimeout);
    _assertOk(res);
    final body = _decode(res);
    return RouteResponse.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Destination menu – all rooms & entrances grouped by floor.
  Future<List<FloorSummary>> getDestinationMenu() async {
    final res = await _client
        .get(Uri.parse('$_base/navigation/menu'))
        .timeout(AppConfig.requestTimeout);
    _assertOk(res);
    final body = _decode(res);
    final data = body['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => FloorSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Floor summary list (floor number + department count).
  Future<List<Map<String, dynamic>>> getFloors() async {
    final res = await _client
        .get(Uri.parse('$_base/navigation/floors'))
        .timeout(AppConfig.requestTimeout);
    _assertOk(res);
    final body = _decode(res);
    final data = body['data'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  // ── Private helpers ───────────────────────────────────────────────────

  Map<String, dynamic> _decode(http.Response res) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void _assertOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Request failed (${res.statusCode})';
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        message = body['message'] as String? ?? message;
      } catch (_) {}
      throw ApiException(message, statusCode: res.statusCode);
    }
  }
}

/// Thrown when the backend returns a non-2xx response.
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, {this.statusCode = 0});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
