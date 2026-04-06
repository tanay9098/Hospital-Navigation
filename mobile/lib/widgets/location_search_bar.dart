import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/location_model.dart';

/// A tappable field that shows a selected location or a placeholder.
/// Tapping opens the search screen (via [onTap]).
class LocationSearchBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final LocationModel? selected;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const LocationSearchBar({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected != null
                ? iconColor.withOpacity(0.5)
                : const Color(0xFFCDD5E0),
            width: selected != null ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: selected == null
                  ? Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF9AA5B4),
                        fontSize: 14,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected!.name,
                          style: const TextStyle(
                            color: Color(0xFF1A2332),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          selected!.floorLabel,
                          style: AppTheme.caption,
                        ),
                      ],
                    ),
            ),
            if (selected != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close,
                    size: 18, color: Color(0xFF9AA5B4)),
              )
            else
              const Icon(Icons.search, size: 18, color: Color(0xFF9AA5B4)),
          ],
        ),
      ),
    );
  }
}
