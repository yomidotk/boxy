import 'package:flutter/material.dart';

enum ItemType {
  box,
  image,
  button,
  text,
  card,
  logo,
  navBar,
  dropdown,
  input,
  checkbox,
  list,
  search,
  // V24: New Tools
  profileImage,
  chart,
  toggle,
  table,
  pricingCard,
  sidebar,
  article,
  gallery,
}

class LayoutItem extends ChangeNotifier {
  final String id;
  final ItemType type;
  Offset _position;
  Size _size;
  String? _label;

  // V2: NavBar Properties
  List<String> _navItems;
  MainAxisAlignment _navAlignment;
  double _navSpacing;

  // V6: Style Properties
  double _rotation; // Degrees (0-360)
  double _borderRadius; // Pixels

  // V9: Text Properties
  String _textContent;
  double _fontSize;

  // V11: Full Width Option
  bool _isFullWidth;

  // V22: Dropdown Items
  List<String> _dropdownItems;

  // V23: Theme Colors
  Color? _backgroundColor;
  Color? _textColor;
  Color? _iconColor;
  Color? _borderColor;

  // V25: AI Context
  String _aiContext;

  Offset get position => _position;
  Size get size => _size;
  String? get label => _label;
  List<String> get navItems => _navItems;
  MainAxisAlignment get navAlignment => _navAlignment;
  double get navSpacing => _navSpacing;
  double get rotation => _rotation;
  double get borderRadius => _borderRadius;
  String get textContent => _textContent;
  double get fontSize => _fontSize;
  bool get isFullWidth => _isFullWidth;
  List<String> get dropdownItems => _dropdownItems;
  Color? get backgroundColor => _backgroundColor;
  Color? get textColor => _textColor;
  Color? get iconColor => _iconColor;
  Color? get borderColor => _borderColor;
  String get aiContext => _aiContext;

  set position(Offset value) {
    if (_position == value) return;
    _position = value;
    notifyListeners();
  }

  set size(Size value) {
    if (_size == value) return;
    _size = value;
    notifyListeners();
  }

  set label(String? value) {
    if (_label == value) return;
    _label = value;
    notifyListeners();
  }

  set navItems(List<String> value) {
    _navItems = value;
    notifyListeners();
  }

  set navAlignment(MainAxisAlignment value) {
    if (_navAlignment == value) return;
    _navAlignment = value;
    notifyListeners();
  }

  set navSpacing(double value) {
    if (_navSpacing == value) return;
    _navSpacing = value;
    notifyListeners();
  }

  set rotation(double value) {
    if (_rotation == value) return;
    _rotation = value;
    notifyListeners();
  }

  set borderRadius(double value) {
    if (_borderRadius == value) return;
    _borderRadius = value;
    notifyListeners();
  }

  set textContent(String value) {
    if (_textContent == value) return;
    _textContent = value;
    notifyListeners();
  }

  set fontSize(double value) {
    if (_fontSize == value) return;
    _fontSize = value;
    notifyListeners();
  }

  set isFullWidth(bool value) {
    if (_isFullWidth == value) return;
    _isFullWidth = value;
    notifyListeners();
  }

  set dropdownItems(List<String> value) {
    _dropdownItems = value;
    notifyListeners();
  }

  set backgroundColor(Color? value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    notifyListeners();
  }

  set textColor(Color? value) {
    if (_textColor == value) return;
    _textColor = value;
    notifyListeners();
  }

  set iconColor(Color? value) {
    if (_iconColor == value) return;
    _iconColor = value;
    notifyListeners();
  }

  set borderColor(Color? value) {
    if (_borderColor == value) return;
    _borderColor = value;
    notifyListeners();
  }

  set aiContext(String value) {
    if (_aiContext == value) return;
    _aiContext = value;
    notifyListeners();
  }

  LayoutItem copy({String? newId, Offset? newPosition}) {
    return LayoutItem(
      id: newId ?? id,
      type: type,
      position: newPosition ?? _position,
      size: _size,
      label: _label,
      navItems: List<String>.from(_navItems),
      navAlignment: _navAlignment,
      navSpacing: _navSpacing,
      rotation: _rotation,
      borderRadius: _borderRadius,
      textContent: _textContent,
      fontSize: _fontSize,
      isFullWidth: _isFullWidth,
      dropdownItems: List<String>.from(_dropdownItems),
      backgroundColor: _backgroundColor,
      textColor: _textColor,
      iconColor: _iconColor,
      borderColor: _borderColor,
      aiContext: _aiContext,
    );
  }

  LayoutItem({
    required this.id,
    required this.type,
    required Offset position,
    Size size = const Size(100, 100),
    String? label,
    List<String> navItems = const ["Home", "About", "Contact"],
    MainAxisAlignment navAlignment = MainAxisAlignment.spaceAround,
    double navSpacing = 20.0,
    double rotation = 0.0,
    double borderRadius = 8.0,
    String textContent = "Text Item",
    double fontSize = 16.0,
    bool isFullWidth = false,
    List<String> dropdownItems = const ["Option 1", "Option 2"],
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    Color? borderColor,
    String aiContext = '',
  })  : _position = position,
        _size = size,
        _label = label,
        _navItems = navItems,
        _navAlignment = navAlignment,
        _navSpacing = navSpacing,
        _rotation = rotation,
        _borderRadius = borderRadius,
        _textContent = textContent,
        _fontSize = fontSize,
        _isFullWidth = isFullWidth,
        _dropdownItems = dropdownItems,
        _backgroundColor = backgroundColor,
        _textColor = textColor,
        _iconColor = iconColor,
        _borderColor = borderColor,
        _aiContext = aiContext;

  // Helper to get default size for types
  static Size getDefaultSize(ItemType type) {
    switch (type) {
      case ItemType.box:
        return const Size(150, 150);
      case ItemType.image:
        return const Size(200, 150);
      case ItemType.button:
        return const Size(120, 50);
      case ItemType.text:
        return const Size(100, 40);
      case ItemType.card:
        return const Size(300, 180);
      case ItemType.logo:
        return const Size(80, 80);
      case ItemType.navBar:
        return const Size(800, 60); // Wide by default
      case ItemType.dropdown:
        return const Size(150, 40);
      case ItemType.input:
        return const Size(250, 50); // Standard Input Field
      case ItemType.checkbox:
        return const Size(150, 40); // Label + Box
      case ItemType.list:
        return const Size(300, 200); // List Container
      case ItemType.search:
        return const Size(200, 40); // Search Bar
      case ItemType.profileImage:
        return const Size(100, 100);
      case ItemType.chart:
        return const Size(300, 200);
      case ItemType.toggle:
        return const Size(60, 30);
      case ItemType.table:
        return const Size(400, 250);
      case ItemType.pricingCard:
        return const Size(250, 350);
      case ItemType.sidebar:
        return const Size(250, 600);
      case ItemType.article:
        return const Size(600, 300);
      case ItemType.gallery:
        return const Size(400, 400);
    }
  }
}
