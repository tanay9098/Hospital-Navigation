import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/location_model.dart';
import '../models/floor_summary.dart';
import '../providers/navigation_provider.dart';
import 'navigate_screen.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().loadMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Departments & Facilities'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white12, height: 1),
        ),
      ),
      body: Consumer<NavigationProvider>(
        builder: (_, nav, __) {
          if (nav.menuLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (nav.menu.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_hospital_outlined,
                      size: 60, color: Color(0xFFCBD5E0)),
                  const SizedBox(height: 12),
                  const Text('Could not load departments.',
                      style: TextStyle(color: Color(0xFF9AA5B4))),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () {
                      nav.menu.clear();
                      nav.loadMenu();
                    },
                  ),
                ],
              ),
            );
          }
          return _FloorList(floors: nav.menu);
        },
      ),
    );
  }
}

class _FloorList extends StatelessWidget {
  final List<FloorSummary> floors;
  const _FloorList({required this.floors});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      itemCount: floors.length,
      itemBuilder: (_, i) =>
          _FloorCard(floor: floors[i]).animate().fade(
                delay: Duration(milliseconds: i * 60),
                duration: 350.ms,
              ),
    );
  }
}

class _FloorCard extends StatelessWidget {
  final FloorSummary floor;
  const _FloorCard({required this.floor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: floor.floor == 0,
        leading: _FloorBadge(floor: floor.floor),
        title: Text(floor.floorName, style: AppTheme.titleMedium),
        subtitle: Text('${floor.locations.length} locations',
            style: AppTheme.caption),
        children: floor.locations
            .map((loc) => _DepartmentTile(loc: loc))
            .toList(),
      ),
    );
  }
}

class _FloorBadge extends StatelessWidget {
  final int floor;
  const _FloorBadge({required this.floor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        floor == 0 ? 'GF' : 'F$floor',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _DepartmentTile extends StatelessWidget {
  final LocationModel loc;
  const _DepartmentTile({required this.loc});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: _catColor(loc.category).withOpacity(0.1),
        child:
            Icon(loc.categoryIcon, size: 18, color: _catColor(loc.category)),
      ),
      title: Text(loc.name,
          style: AppTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          Text(loc.floorLabel, style: AppTheme.caption),
          if (!loc.isAccessible) ...[
            const SizedBox(width: 6),
            const Icon(Icons.stairs, size: 11, color: AppTheme.warning),
            const Text(' Stairs only',
                style: TextStyle(fontSize: 11, color: AppTheme.warning)),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.directions, size: 15),
            label: const Text('Go', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _startNavigation(context, loc),
          ),
        ],
      ),
    );
  }

  Future<void> _startNavigation(
      BuildContext context, LocationModel dest) async {
    final nav = context.read<NavigationProvider>();
    nav.setToLocation(dest);

    if (nav.fromLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set your starting location first.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    await nav.fetchRoute();
    if (context.mounted && nav.route != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NavigateScreen()),
      );
    } else if (context.mounted && nav.routeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nav.routeError!)),
      );
    }
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'department':   return AppTheme.primary;
      case 'facility':     return AppTheme.accent;
      case 'administrative': return const Color(0xFF546E7A);
      default:             return AppTheme.stepTransit;
    }
  }
}
