import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_config.dart';
import '../providers/navigation_provider.dart';
import '../models/location_model.dart';
import '../widgets/location_search_bar.dart';
import 'search_screen.dart';
import 'navigate_screen.dart';
import 'departments_screen.dart';
import 'ivr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<Widget> _pages = const [
    _NavigatePage(),
    DepartmentsScreen(),
    IvrScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Navigate',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital),
            label: 'Departments',
          ),
          NavigationDestination(
            icon: Icon(Icons.phone_outlined),
            selectedIcon: Icon(Icons.phone),
            label: 'IVR Helpline',
          ),
        ],
      ),
    );
  }
}

// ── Navigate tab ──────────────────────────────────────────────────────────────

class _NavigatePage extends StatelessWidget {
  const _NavigatePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildOfflineBanner(context)),
          SliverToBoxAdapter(child: _buildSearchCard(context)),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          SliverToBoxAdapter(child: _buildRecentLocations(context)),
          SliverToBoxAdapter(child: _buildInfoBanner(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PES Hospital',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'Electronic City, Bengaluru',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryDark, AppTheme.primary],
            ),
          ),
          child: const Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.local_hospital,
                  size: 48, color: Colors.white12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (_, nav, __) {
        if (nav.isOnline) return const SizedBox.shrink();
        return Container(
          color: AppTheme.warning,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No connection to server. Check your network.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Get Directions',
                  style: AppTheme.titleMedium),
              const SizedBox(height: 14),

              // FROM field
              LocationSearchBar(
                label: 'From',
                icon: Icons.my_location,
                iconColor: AppTheme.primary,
                selected: nav.fromLocation,
                onTap: () async {
                  final loc = await Navigator.push<LocationModel>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchScreen(title: 'Select Starting Point'),
                    ),
                  );
                  if (loc != null) {
                    context.read<NavigationProvider>().setFromLocation(loc);
                  }
                },
                onClear: () => context.read<NavigationProvider>().clearFrom(),
              ),

              // Swap button row
              Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Divider(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_vert,
                        color: AppTheme.primary, size: 22),
                    tooltip: 'Swap locations',
                    onPressed: () =>
                        context.read<NavigationProvider>().swapLocations(),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Divider(),
                    ),
                  ),
                ],
              ),

              // TO field
              LocationSearchBar(
                label: 'To',
                icon: Icons.place,
                iconColor: AppTheme.emergency,
                selected: nav.toLocation,
                onTap: () async {
                  final loc = await Navigator.push<LocationModel>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchScreen(title: 'Select Destination'),
                    ),
                  );
                  if (loc != null) {
                    context.read<NavigationProvider>().setToLocation(loc);
                  }
                },
                onClear: () => context.read<NavigationProvider>().clearTo(),
              ),

              const SizedBox(height: 12),

              // Accessible only toggle
              Row(
                children: [
                  const Icon(Icons.accessible_forward,
                      size: 18, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Wheelchair-accessible route only',
                        style: AppTheme.bodyMedium),
                  ),
                  Switch(
                    value: nav.accessibleOnly,
                    onChanged: (v) =>
                        context.read<NavigationProvider>().setAccessibleOnly(v),
                    activeColor: AppTheme.accent,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Get Directions button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: nav.routeLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.directions),
                  label: Text(
                    nav.routeLoading ? 'Finding route…' : 'Get Directions',
                  ),
                  onPressed: (nav.fromLocation != null &&
                          nav.toLocation != null &&
                          !nav.routeLoading)
                      ? () async {
                          await context
                              .read<NavigationProvider>()
                              .fetchRoute();
                          if (context.mounted) {
                            final n = context.read<NavigationProvider>();
                            if (n.route != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NavigateScreen(),
                                ),
                              );
                            } else if (n.routeError != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(n.routeError!)),
                              );
                            }
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideY(begin: 0.15, duration: 400.ms, curve: Curves.easeOut)
          .fade(duration: 400.ms),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    const quick = [
      _QuickAction('Emergency', Icons.emergency, AppTheme.emergency, 'GF-EMG'),
      _QuickAction('Reception', Icons.support_agent, AppTheme.primary, 'GF-REC'),
      _QuickAction('Pharmacy', Icons.medication, Color(0xFF7B1FA2), 'GF-PHA'),
      _QuickAction('Cardiology', Icons.favorite, Color(0xFFD32F2F), '3F-CARD'),
      _QuickAction('Radiology', Icons.biotech, Color(0xFF00838F), '1F-XRAY'),
      _QuickAction('Gynecology', Icons.child_care, Color(0xFF880E4F), '4F-GYN'),
      _QuickAction('Ortho', Icons.accessibility_new, Color(0xFF33691E), '2F-ORTH'),
      _QuickAction('Psychiatry', Icons.psychology, Color(0xFF4527A0), '5F-PSYC'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Access', style: AppTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quick.map((q) => _QuickChip(action: q)).toList(),
          ),
        ],
      ),
    ).animate().fade(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildRecentLocations(BuildContext context) {
    final recent = context.watch<NavigationProvider>().recentLocations;
    if (recent.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent', style: AppTheme.titleMedium),
          const SizedBox(height: 8),
          ...recent.take(4).map(
                (loc) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: Icon(loc.categoryIcon,
                        size: 18, color: AppTheme.primary),
                  ),
                  title: Text(loc.name,
                      style: AppTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(loc.floorLabel, style: AppTheme.caption),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Color(0xFFCBD5E0)),
                  onTap: () {
                    final nav = context.read<NavigationProvider>();
                    if (nav.fromLocation == null) {
                      nav.setFromLocation(loc);
                    } else {
                      nav.setToLocation(loc);
                    }
                  },
                ),
              ),
        ],
      ),
    ).animate().fade(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBBDEFB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
                SizedBox(width: 8),
                Text('Need help?', style: AppTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            _infoRow(Icons.phone, 'Helpdesk: ${AppConfig.receptionNumber}'),
            _infoRow(Icons.emergency,
                'Emergency: ${AppConfig.emergencyNumber}'),
            _infoRow(Icons.dialpad, 'IVR Navigation: ${AppConfig.ivrNumber}'),
          ],
        ),
      ),
    ).animate().fade(delay: 400.ms, duration: 400.ms);
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(text, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ── Quick action chip ─────────────────────────────────────────────────────────

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String locationCode;
  const _QuickAction(this.label, this.icon, this.color, this.locationCode);
}

class _QuickChip extends StatelessWidget {
  final _QuickAction action;
  const _QuickChip({required this.action, super.key});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(action.icon, size: 16, color: action.color),
      label: Text(action.label),
      backgroundColor: action.color.withOpacity(0.08),
      side: BorderSide(color: action.color.withOpacity(0.3)),
      labelStyle: TextStyle(
        color: action.color,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      onPressed: () async {
        final nav = context.read<NavigationProvider>();
        final loc = await nav.getLocation(action.locationCode);
        if (loc == null) return;
        nav.setToLocation(loc);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Destination set to ${loc.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}

