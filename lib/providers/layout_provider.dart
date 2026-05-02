import 'package:flutter/material.dart';
import '../models/layout_item.dart';

class LayoutProvider extends ChangeNotifier {
  final List<LayoutItem> _items = [];
  LayoutItem? _selectedItem;
  bool _showDimensions = false; // V4: Show all dimensions toggle
  bool _isDragging = false; // V5: Track dragging state for interaction conflict

  List<LayoutItem> get items => _items;
  LayoutItem? get selectedItem => _selectedItem;
  bool get showDimensions => _showDimensions;
  bool get isDragging => _isDragging;

  void toggleDimensions(bool value) {
    _showDimensions = value;
    if (value) {
      sanitizeAllItems();
    }
    notifyListeners();
  }

  /// V21: Recover from any NaN/Infinite values that might have entered the system
  void sanitizeAllItems() {
    for (var item in _items) {
      if (!item.position.dx.isFinite || !item.position.dy.isFinite) {
        item.position = Offset.zero;
      }
      if (!item.size.width.isFinite || !item.size.height.isFinite) {
        item.size = const Size(100, 100);
      }
      if (!item.rotation.isFinite) {
        item.rotation = 0.0;
      }
    }
    notifyListeners();
  }

  void setDragging(bool value) {
    _isDragging = value;
    notifyListeners();
  }

  // Counters for auto-naming (e.g., img_1, box_2)
  final Map<ItemType, int> _typeCounters = {};

  void addItem(ItemType type, Offset position) {
    if (!position.dx.isFinite || !position.dy.isFinite) {
      return; // V21: Drop Guard
    }

    int count = (_typeCounters[type] ?? 0) + 1;
    _typeCounters[type] = count;

    String id = _generateId(type);
    Size size = LayoutItem.getDefaultSize(type);

    // Center the item on the drop position
    Offset centeredPos = position - Offset(size.width / 2, size.height / 2);

    LayoutItem newItem = LayoutItem(
      id: id,
      type: type,
      position: centeredPos,
      size: size,
      textContent: type == ItemType.logo ? "BRAND" : (type == ItemType.card ? "Card" : "Text Item"),
      label: type == ItemType.button
          ? "Click Me"
          : (type == ItemType.text
                ? "Label"
                : (type == ItemType.checkbox
                      ? "Label"
                      : (type == ItemType.input
                            ? "Placeholder"
                            : (type == ItemType.search ? "Search..." : null)))),
    );

    _items.add(newItem);
    _selectedItem = newItem;
    notifyListeners();
  }

  void selectItem(String? id) {
    if (id == null) {
      _selectedItem = null;
    } else {
      _selectedItem = _items.firstWhere((item) => item.id == id);
    }
    notifyListeners();
  }

  void updatePageSize(Size size) {
    // Only if we need to track canvas size
  }

  // V12: Free Dragging (No Snapping)
  void updatePosition(String id, Offset newPos, Size canvasSize) {
    if (!newPos.dx.isFinite || !newPos.dy.isFinite) return; // V21: NaN Guard

    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex == -1) return;

    _items[itemIndex].position = newPos;
  }

  void updateSize(String id, Size newSize) {
    if (!newSize.width.isFinite || !newSize.height.isFinite) {
      return; // V21: NaN Guard
    }

    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex != -1) {
      _items[itemIndex].size = newSize;
    }
  }

  void updateNavItems(String id, List<String> newItems) {
    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex != -1) {
      _items[itemIndex].navItems = newItems;
    }
  }

  void updateNavProperties(
    String id, {
    MainAxisAlignment? alignment,
    double? spacing,
  }) {
    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex != -1) {
      if (alignment != null) {
        _items[itemIndex].navAlignment = alignment;
      }
      if (spacing != null) {
        _items[itemIndex].navSpacing = spacing;
      }
    }
  }

  // V6: Style Updates
  void updateRotation(String id, double rotation) {
    if (!rotation.isFinite) return; // V21: NaN Guard

    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].rotation = rotation;
    }
  }

  void updateDropdownItems(String id, List<String> newItems) {
    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex != -1) {
      _items[itemIndex].dropdownItems = newItems;
    }
  }

  void updateBorderRadius(String id, double radius) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].borderRadius = radius;
    }
  }

  // V9: Text Updates
  void updateTextContent(String id, String text) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].textContent = text;
      _updateSizeToFitText(_items[index]);
    }
  }

  void updateFontSize(String id, double size) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].fontSize = size;
      _updateSizeToFitText(_items[index]);
    }
  }

  void updateLabel(String id, String label) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].label = label;
      _updateSizeToFitText(_items[index]);
    }
  }

  void moveItem(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _items.length ||
        newIndex < 0 ||
        newIndex > _items.length) {
      return;
    }
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    if (_selectedItem?.id == id) {
      _selectedItem = null;
    }
    notifyListeners();
  }

  // V11: Full Width Toggle
  void toggleFullWidth(String id, bool value) {
    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex == -1) return;

    final item = _items[itemIndex];
    item.isFullWidth = value;

    if (value) {
      // V21: Automatically update data to match visual "Full Width"
      item.position = Offset(0, item.position.dy);
      item.size = Size(800, item.size.height);
    }
  }

  void duplicateItem(String id) {
    final originalIndex = _items.indexWhere((item) => item.id == id);
    if (originalIndex == -1) return;

    final original = _items[originalIndex];
    final String newId = _generateId(original.type);
    
    // Shift slightly from original (20px)
    final Offset newPosition =
        Offset(original.position.dx + 20, original.position.dy + 20);

    if (!newPosition.dx.isFinite || !newPosition.dy.isFinite) {
      return; // V21: Duplicate Guard
    }

    final LayoutItem copy =
        original.copy(newId: newId, newPosition: newPosition);
    _items.add(copy);

    _selectedItem = copy;
    notifyListeners();
  }

  void applyTextPreset(String id, String preset) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    
    final item = _items[index];
    switch (preset) {
      case 'title':
        item.fontSize = 32.0;
        break;
      case 'subtitle':
        item.fontSize = 24.0;
        break;
      case 'paragraph':
        item.fontSize = 14.0;
        break;
    }
    _updateSizeToFitText(item);
  }

  void _updateSizeToFitText(LayoutItem item) {
    if (item.type != ItemType.text) {
      return;
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: item.type == ItemType.text
            ? item.textContent
            : (item.label ?? (item.type == ItemType.logo ? "LOGO" : "Text")),
        style: TextStyle(
          fontSize: item.fontSize,
          fontWeight: [ItemType.button, ItemType.logo].contains(item.type)
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Add some padding to the calculated size
    double paddingX =
        [ItemType.button, ItemType.search, ItemType.logo].contains(item.type)
            ? 40.0
            : 20.0;
            
    // V21: Extra padding for Logo Star Icon
    if (item.type == ItemType.logo) {
      paddingX += item.fontSize * 1.5; 
    }

    final double paddingY =
        [ItemType.button, ItemType.search, ItemType.logo].contains(item.type)
            ? 20.0
            : 10.0;

    final Size newSize = Size(
      textPainter.width + paddingX,
      textPainter.height + paddingY,
    );

    if (newSize.width.isFinite && newSize.height.isFinite) {
      item.size = newSize;
    }
  }

  String _generateId(ItemType type) {
    int count = (_typeCounters[type] ?? 0) + 1;
    _typeCounters[type] = count;

    String prefix;
    switch (type) {
      case ItemType.box: prefix = "box"; break;
      case ItemType.image: prefix = "img"; break;
      case ItemType.button: prefix = "btn"; break;
      case ItemType.text: prefix = "txt"; break;
      case ItemType.card: prefix = "card"; break;
      case ItemType.logo: prefix = "logo"; break;
      case ItemType.navBar: prefix = "nav"; break;
      case ItemType.dropdown: prefix = "drop"; break;
      case ItemType.input: prefix = "inp"; break;
      case ItemType.checkbox: prefix = "chk"; break;
      case ItemType.list: prefix = "lst"; break;
      case ItemType.search: prefix = "srch"; break;
    }
    return "${prefix}_$count";
  }
}
