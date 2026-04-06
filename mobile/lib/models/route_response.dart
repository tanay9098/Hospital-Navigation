import 'navigation_step.dart';

/// Full route returned by POST /api/v1/navigation/route
class RouteResponse {
  final RouteLocation from;
  final RouteLocation to;
  final double distance;          // total metres
  final int estimatedTime;        // seconds
  final String estimatedTimeText; // "4 min 5 sec"
  final bool accessible;
  final int totalSteps;
  final List<NavigationStep> steps;
  final String voiceScript;
  final String textSummary;

  const RouteResponse({
    required this.from,
    required this.to,
    required this.distance,
    required this.estimatedTime,
    required this.estimatedTimeText,
    required this.accessible,
    required this.totalSteps,
    required this.steps,
    required this.voiceScript,
    required this.textSummary,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    final rawSteps = (json['steps'] as List<dynamic>? ?? []);
    return RouteResponse(
      from: RouteLocation.fromJson(
          json['from'] as Map<String, dynamic>? ?? {}),
      to: RouteLocation.fromJson(
          json['to'] as Map<String, dynamic>? ?? {}),
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      estimatedTime: (json['estimatedTime'] as num?)?.toInt() ?? 0,
      estimatedTimeText: json['estimatedTimeText'] as String? ?? '',
      accessible: json['accessible'] as bool? ?? false,
      totalSteps: (json['totalSteps'] as num?)?.toInt() ?? 0,
      steps: rawSteps
          .map((s) => NavigationStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      voiceScript: json['voiceScript'] as String? ?? '',
      textSummary: json['textSummary'] as String? ?? '',
    );
  }
}

/// Compact location reference (as returned nested in RouteResponse).
class RouteLocation {
  final String code;
  final String name;
  final int floor;

  const RouteLocation({
    required this.code,
    required this.name,
    required this.floor,
  });

  factory RouteLocation.fromJson(Map<String, dynamic> json) => RouteLocation(
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
        floor: (json['floor'] as num?)?.toInt() ?? 0,
      );
}
