import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/models/floor_config.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/pdr_provider.dart';
import 'package:hospital_nav/providers/settings_provider.dart';

class SearchSheet extends StatefulWidget {
  final bool isStart;
  const SearchSheet({super.key, required this.isStart});

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final TextEditingController _controller = TextEditingController();
  List<Node> _results = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          
          // Header & Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isStart ? settingsProvider.translate('choose_starting_point') : settingsProvider.translate('choose_destination'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: settingsProvider.translate('search_rooms'),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                _results = [];
                                _isSearching = false;
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                      _results = navProvider.searchRooms(value, settingsProvider);
                    });
                  },
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Results Area
          Expanded(
            child: _isSearching
                ? _buildSearchResults(theme, navProvider, settingsProvider)
                : _buildFloorBrowseList(theme, navProvider, settingsProvider),
          ),
        ],
      ),
    );
  }

  /// Shows search results when user is typing
  Widget _buildSearchResults(ThemeData theme, NavigationProvider navProvider, SettingsProvider settingsProvider) {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(settingsProvider.translate('no_locations_found'), style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) => _buildRoomTile(_results[index], theme, settingsProvider),
    );
  }

  /// Shows all rooms grouped by floor when search is empty
  Widget _buildFloorBrowseList(ThemeData theme, NavigationProvider navProvider, SettingsProvider settingsProvider) {
    // Collect all rooms from all floors
    final Map<int, List<Node>> roomsByFloor = {};
    for (var entry in navProvider.floorManager.floorGraphs.entries) {
      final rooms = entry.value.nodes.values
          .where((n) => n.label != null && n.label!.isNotEmpty)
          .toList()
        ..sort((a, b) => (a.label ?? '').compareTo(b.label ?? ''));
      if (rooms.isNotEmpty) {
        roomsByFloor[entry.key] = rooms;
      }
    }

    final sortedFloors = roomsByFloor.keys.toList()..sort();

    if (sortedFloors.isEmpty) {
      return Center(
        child: Text(settingsProvider.translate('no_rooms_available'), style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedFloors.fold<int>(0, (sum, f) => sum + 1 + roomsByFloor[f]!.length),
      itemBuilder: (context, index) {
        // Map flat index to (floor header or room tile)
        int currentIndex = 0;
        for (final floor in sortedFloors) {
          if (index == currentIndex) {
            // This is a floor header
            final config = kFloorConfigs[floor];
            final floorName = config?.floorName ?? 'Floor $floor';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  Icon(Icons.layers, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    floorName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${roomsByFloor[floor]!.length} ${settingsProvider.translate('places')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }
          currentIndex++; // past the header

          final rooms = roomsByFloor[floor]!;
          if (index < currentIndex + rooms.length) {
            return _buildRoomTile(rooms[index - currentIndex], theme, settingsProvider);
          }
          currentIndex += rooms.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Builds a single room tile (reused by both search results and browse list)
  Widget _buildRoomTile(Node node, ThemeData theme, SettingsProvider settingsProvider) {
    final floorName = kFloorConfigs[node.floor]?.floorName ?? 'Floor ${node.floor}';
    final translatedName = settingsProvider.transliterateLabel(node.label ?? node.id);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(_getIconForRoom(node.label ?? ''), color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(translatedName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '$floorName • ${node.accessible ? settingsProvider.translate('accessible') : settingsProvider.translate('stairs_only')}',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      onTap: () => _onRoomSelected(node),
    );
  }

  /// Returns a contextual icon based on the room name
  IconData _getIconForRoom(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('pharmacy')) return Icons.local_pharmacy;
    if (lower.contains('canteen') || lower.contains('cafe') || lower.contains('food')) return Icons.restaurant;
    if (lower.contains('reception')) return Icons.desk;
    if (lower.contains('icu') || lower.contains('emergency')) return Icons.emergency;
    if (lower.contains('lab')) return Icons.science;
    if (lower.contains('ward')) return Icons.bed;
    if (lower.contains('ot') || lower.contains('operation') || lower.contains('surgery')) return Icons.medical_services;
    if (lower.contains('radiology') || lower.contains('x-ray') || lower.contains('scan')) return Icons.biotech;
    if (lower.contains('entrance') || lower.contains('exit') || lower.contains('gate')) return Icons.door_front_door;
    if (lower.contains('toilet_female')) return Icons.female;
    if (lower.contains('toilet_male')) return Icons.male;
    if (lower.contains('restroom') || lower.contains('toilet') || lower.contains('washroom')) return Icons.wc;
    if (lower.contains('office') || lower.contains('admin')) return Icons.business;
    if (lower.contains('blood')) return Icons.bloodtype;
    if (lower.contains('billing') || lower.contains('payment') || lower.contains('cashier')) return Icons.payment;
    return Icons.meeting_room;
  }

  void _onRoomSelected(Node node) {
    // Capture providers synchronously before the context is unmounted!
    final navProv = Provider.of<NavigationProvider>(context, listen: false);
    final pdrProv = Provider.of<PdrProvider>(context, listen: false);

    final isSameNode = widget.isStart
        ? navProv.destinationNode?.id == node.id
        : navProv.startNode?.id == node.id;

    if (isSameNode) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Invalid Selection'),
            ],
          ),
          content: const Text(
            'Source and destination cannot be the same. Please choose a different location.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Close the search sheet smoothly first
    Navigator.pop(context);
    
    // Delay heavy Map/Route state updates until the close animation finishes
    Future.delayed(const Duration(milliseconds: 300), () {
        if (widget.isStart) {
          navProv.setStartNode(node);
          
          // Synergize Native PDR Tracking Origin Coordinate!
          if (pdrProv.isPdrEnabled) {
             pdrProv.initializePosition(node.x, node.y, node.floor, 0.0);
          }
          
        } else {
          navProv.setDestinationNode(node);
        }
    });
  }
}
