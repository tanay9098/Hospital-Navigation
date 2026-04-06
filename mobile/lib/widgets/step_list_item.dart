import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/navigation_step.dart';

/// A single row in the navigation step list.
class StepListItem extends StatelessWidget {
  final NavigationStep step;
  final bool isCurrent;
  final VoidCallback onTap;

  const StepListItem({
    super.key,
    required this.step,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: isCurrent
            ? step.stepColor.withOpacity(0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number + connector line
            _StepIndicator(step: step, isCurrent: isCurrent),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.text,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isCurrent
                                ? step.stepColor
                                : const Color(0xFF2D3748),
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (step.distance > 0)
                        Text(
                          '${step.distance.round()} m',
                          style: AppTheme.caption,
                        ),
                    ],
                  ),
                  if (step.locationName.isNotEmpty && !step.isStart) ...[
                    const SizedBox(height: 3),
                    Text(
                      step.locationName,
                      style: AppTheme.caption.copyWith(
                        color: step.stepColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final NavigationStep step;
  final bool isCurrent;
  const _StepIndicator({required this.step, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCurrent ? step.stepColor : step.stepColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: step.stepColor, width: 2)
                  : null,
            ),
            child: Icon(
              step.stepIcon,
              size: 16,
              color: isCurrent ? Colors.white : step.stepColor,
            ),
          ),
        ],
      ),
    );
  }
}
