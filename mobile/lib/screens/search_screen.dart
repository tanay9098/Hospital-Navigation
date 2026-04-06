import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/location_model.dart';
import '../models/floor_summary.dart';
import '../providers/navigation_provider.dart';

class SearchScreen extends StatefulWidget {
  final String title;
  const SearchScreen({super.key, required this.title});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().loadMenu();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<NavigationProvider>().search(q);
    });
  }

  void _select(LocationModel loc) {
    context.read<NavigationProvider>().clearSearch();
    Navigator.of(context).pop(loc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Browse by Floor'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search departments, facilities…',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.primary),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          context.read<NavigationProvider>().clearSearch();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SearchTab(onSelect: _select),
                _BrowseTab(onSelect: _select),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search results tab ────────────────────────────────────────────────────────

class _SearchTab extends StatelessWidget {
  final void Function(LocationModel) onSelect;
  const _SearchTab({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    if (nav.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (nav.searchResults.isEmpty) {
      // Show recents
      final recent = nav.recentLocations;
      if (recent.isEmpty) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 56, color: Color(0xFFCBD5E0)),
              SizedBox(height: 12),
              Text('Type to search departments',
                  style: TextStyle(color: Color(0xFF9AA5B4))),
            ],
          ),
        );
      }
      return _LocationList(
        header: 'Recent',
        locations: recent,
        onSelect: onSelect,
      );
    }

    return _LocationList(
      header: '${nav.searchResults.length} results',
      locations: nav.searchResults,
      onSelect: onSelect,
    );
  }
}

// ── Browse by floor tab ───────────────────────────────────────────────────────

class _BrowseTab extends StatelessWidget {
  final void Function(LocationModel) onSelect;
  const _BrowseTab({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    if (nav.menuLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (nav.menu.isEmpty) {
      return const Center(
        child: Text('Could not load department list.',
            style: TextStyle(color: Color(0xFF9AA5B4))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: nav.menu.length,
      itemBuilder: (_, i) {
        final floor = nav.menu[i];
        return _FloorSection(floor: floor, onSelect: onSelect);
      },
    );
  }
}

class _FloorSection extends StatelessWidget {
  final FloorSummary floor;
  final void Function(LocationModel) onSelect;
  const _FloorSection({required this.floor, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: floor.floor == 0,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppTheme.primary,
        child: Text(
          floor.floor == 0 ? 'G' : '${floor.floor}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(floor.floorName, style: AppTheme.titleMedium),
      subtitle: Text('${floor.locations.length} locations',
          style: AppTheme.caption),
      children: floor.locations
          .map((loc) => _LocationTile(loc: loc, onTap: () => onSelect(loc)))
          .toList(),
    );
  }
}

class _LocationList extends StatelessWidget {
  final String header;
  final List<LocationModel> locations;
  final void Function(LocationModel) onSelect;
  const _LocationList(
      {required this.header,
      required this.locations,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: locations.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(header, style: AppTheme.caption),
          );
        }
        final loc = locations[i - 1];
        return _LocationTile(
          loc: loc,
          onTap: () => onSelect(loc),
        );
      },
    );
  }
}

class _LocationTile extends StatelessWidget {
  final LocationModel loc;
  final VoidCallback onTap;
  const _LocationTile({required this.loc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: _categoryColor(loc.category).withOpacity(0.1),
        child: Icon(loc.categoryIcon,
            size: 20, color: _categoryColor(loc.category)),
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
            const Icon(Icons.stairs, size: 12, color: AppTheme.warning),
          ],
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: Color(0xFFCBD5E0)),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'department':   return AppTheme.primary;
      case 'facility':     return AppTheme.accent;
      case 'administrative': return const Color(0xFF546E7A);
      default:             return AppTheme.stepTransit;
    }
  }
}
