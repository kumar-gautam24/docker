import 'package:flutter/material.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// The main widget for the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: [
              {'icon': Icons.person, 'name': 'Person'},
              {'icon': Icons.message, 'name': 'Messages'},
              {'icon': Icons.call, 'name': 'Calls'},
              {'icon': Icons.camera, 'name': 'Camera'},
              {'icon': Icons.photo, 'name': 'Photos'},
            ],
          ),
        ),
      ),
    );
  }
}

/// A dock widget that allows dragging, reordering, and displaying icon names on tap.
class Dock extends StatefulWidget {
  const Dock({super.key, this.items = const []});

  /// List of initial icons and their names in the dock.
  final List<Map<String, dynamic>> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<Map<String, dynamic>> _icons; // List of icons with names
  Offset? _draggedOffset;
  int? _draggedIndex;
  Map<int, bool> _showName = {}; // Map to track name visibility for each icon

  @override
  void initState() {
    super.initState();
    _icons = List.from(widget.items);
    _showName = {
      for (int i = 0; i < _icons.length; i++) i: false
    }; // Initialize all names as hidden
  }

  @override
  Widget build(BuildContext context) {
    final dockWidth = _icons.length *
        65.0; // Calculate dock width based on the number of icons

    return Container(
      width: dockWidth,
      height: 130, // Increased height to accommodate icon names
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: List.generate(_icons.length, (index) {
          final iconData = _icons[index];
          final isDragged = _draggedIndex == index;

          return AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: isDragged ? _draggedOffset?.dx ?? index * 60.0 : index * 60.0,
            top: isDragged
                ? _draggedOffset?.dy.clamp(-20.0, 20.0) ??
                    0 // Clamp vertical drag to -20 to 20
                : 0,
            child: GestureDetector(
              onPanStart: (details) => _onDragStart(index, details),
              onPanUpdate: (details) => _onDragUpdate(details),
              onPanEnd: (_) => _onDragEnd(index),
              // onTap: () => _onIconTap(index), // Toggle name visibility
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    _buildIconContainer(
                      iconData['icon'],
                      Colors.primaries[
                          iconData['icon'].hashCode % Colors.primaries.length],
                    ),
                    if (_showName[index] ??
                        false) // Display name only when dragged
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          iconData['name'],
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Builds a visually styled container for an icon.
  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      width: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color,
      ),
      child: Center(child: Icon(icon, color: Colors.white)),
    );
  }

  /// Handles the start of a drag by initializing drag state.
  void _onDragStart(int index, DragStartDetails details) {
    setState(() {
      _showName[index] = !_showName[index]!;
      _draggedIndex = index;
      _draggedOffset =
          Offset(index * 60.0, 0); // Initial position of the dragged icon
    });
  }

  /// Handles dragging by updating the position and reordering icons dynamically.
  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _draggedOffset = _draggedOffset! + details.delta;

      // Constrain horizontal movement within the dock
      _draggedOffset = Offset(
        _draggedOffset!.dx.clamp(0, (_icons.length - 1) * 60.0),
        _draggedOffset!.dy.clamp(-20, 20), // Vertical snapping range
      );

      // Determine the new index based on horizontal position
      final newIndex =
          (_draggedOffset!.dx / 60).clamp(0, _icons.length - 1).round();
      if (newIndex != _draggedIndex) {
        _updateIconOrder(newIndex);
      }
    });
  }

  /// Finalizes dragging by resetting the drag state.
  void _onDragEnd(int index) {
    setState(() {
      _showName[index] = !_showName[index]!;
      _draggedOffset = null;
      _draggedIndex = null;
    });
  }

  /// Updates the icon order based on the new index.
  void _updateIconOrder(int newIndex) {
    final draggedIcon = _icons.removeAt(_draggedIndex!);
    _icons.insert(newIndex, draggedIcon);
    _draggedIndex = newIndex;
  }

  /// Toggles the visibility of an icon's name.
  void _onIconTap(int index) {
    setState(() {
      _showName[index] = !_showName[index]!;
    });
  }
}
