import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/navigation_step.dart';
import '../providers/navigation_provider.dart';
import '../widgets/floor_map_painter.dart';
import '../widgets/step_list_item.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final PageController _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);

    // Speak first step on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = context.read<NavigationProvider>();
      if (nav.route != null && nav.route!.steps.isNotEmpty) {
        nav.speakCurrentStep();
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final route = nav.route;
    if (route == null) {
      return const Scaffold(
        body: Center(child: Text('No route loaded.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(route.to.name,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'End navigation',
            onPressed: () {
              context.read<NavigationProvider>().stopSpeaking();
              context.read<NavigationProvider>().clearRoute();
              Navigator.of(context).pop();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.directions), text: 'Steps'),
            Tab(icon: Icon(Icons.map_outlined), text: 'Floor Map'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSummaryBar(context, nav),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildStepsView(context, nav),
                FloorMapView(route: route),
              ],
            ),
          ),
          _buildVoiceControls(context, nav),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context, NavigationProvider nav) {
    final route = nav.route!;
    return Container(
      color: AppTheme.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              route.from.name,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_forward, color: Colors.white54, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              route.to.name,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                route.estimatedTimeText,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                '${route.distance.round()} m',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          if (route.accessible) ...[
            const SizedBox(width: 8),
            const Icon(Icons.accessible, color: AppTheme.accent, size: 18),
          ],
        ],
      ),
    );
  }

  Widget _buildStepsView(BuildContext context, NavigationProvider nav) {
    final steps = nav.route!.steps;
    return Column(
      children: [
        // Current step highlighted
        _buildCurrentStepCard(context, nav, steps[nav.currentStepIndex]),
        // Full step list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: steps.length,
            itemBuilder: (_, i) => StepListItem(
              step: steps[i],
              isCurrent: i == nav.currentStepIndex,
              onTap: () => nav.jumpToStep(i),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepCard(
      BuildContext context, NavigationProvider nav, NavigationStep step) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: step.stepColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: step.stepColor.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            child: Icon(step.stepIcon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${step.step} of ${nav.route!.totalSteps}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  step.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                if (step.distance > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${step.distance.round()} m',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate(key: ValueKey(step.step))
        .slideX(begin: 0.1, duration: 300.ms, curve: Curves.easeOut)
        .fade(duration: 300.ms);
  }

  Widget _buildVoiceControls(BuildContext context, NavigationProvider nav) {
    final steps = nav.route!.steps;
    final isFirst = nav.currentStepIndex == 0;
    final isLast = nav.currentStepIndex == steps.length - 1;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Step progress
            LinearProgressIndicator(
              value: (nav.currentStepIndex + 1) / steps.length,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${nav.currentStepIndex + 1} / ${steps.length}',
                  style: AppTheme.caption,
                ),
                Row(
                  children: [
                    const Icon(Icons.volume_up,
                        size: 14, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => nav.toggleAutoAdvance(),
                      child: Text(
                        nav.autoAdvance ? 'Auto-read ON' : 'Auto-read OFF',
                        style: TextStyle(
                          color: nav.autoAdvance
                              ? AppTheme.primary
                              : const Color(0xFF9AA5B4),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Previous
                _NavButton(
                  icon: Icons.skip_previous,
                  label: 'Prev',
                  enabled: !isFirst,
                  onTap: () => nav.previousStep(),
                ),
                const SizedBox(width: 10),

                // Speak / Stop
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                        nav.isSpeaking ? Icons.stop : Icons.volume_up),
                    label: Text(
                        nav.isSpeaking ? 'Stop' : 'Read Step'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: nav.isSpeaking
                          ? AppTheme.warning
                          : AppTheme.primary,
                    ),
                    onPressed: () {
                      if (nav.isSpeaking) {
                        nav.stopSpeaking();
                      } else {
                        nav.speakCurrentStep();
                      }
                    },
                  ),
                ),

                const SizedBox(width: 10),

                // Next
                _NavButton(
                  icon: Icons.skip_next,
                  label: 'Next',
                  enabled: !isLast,
                  onTap: () => nav.nextStep(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
