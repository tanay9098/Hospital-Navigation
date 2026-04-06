/// Utility helpers shared across the app.
class Helpers {
  Helpers._();

  /// Converts a floor number to a human-readable label.
  static String floorLabel(int floor) {
    if (floor == 0) return 'Ground Floor';
    final suffixes = ['th', 'st', 'nd', 'rd'];
    final v = floor % 100;
    final suffix =
        (v >= 11 && v <= 13) ? 'th' : (suffixes[floor % 10 < 4 ? floor % 10 : 0]);
    return '${floor}${suffix} Floor';
  }

  /// Formats seconds into "X min Y sec" string.
  static String formatDuration(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return secs > 0 ? '$mins min $secs sec' : '$mins min';
  }

  /// Returns a friendly distance string.
  static String formatDistance(double metres) {
    if (metres < 10) return 'a few steps';
    if (metres < 1000) return '${metres.round()} m';
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }
}
