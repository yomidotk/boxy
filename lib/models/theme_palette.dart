import 'package:flutter/material.dart';

class ThemePalette {
  final String name;
  final Color primary;
  final Color background;
  final Color surface;
  final Color textDark;
  final Color textLight;

  ThemePalette({
    this.name = '',
    required this.primary,
    required this.background,
    required this.surface,
    required this.textDark,
    required this.textLight,
  });

  // Smart contrast helper
  Color getContrastText(Color backgroundColor) {
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textDark : textLight;
  }

  static Color _hex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static ThemePalette _make(String name, String primary, String surface, String background) {
    final bg = _hex(background);
    return ThemePalette(
      name: name,
      primary: _hex(primary),
      surface: _hex(surface),
      background: bg,
      textDark: const Color(0xFF1A1A1A),
      textLight: Colors.white,
    );
  }

  static final List<ThemePalette> presets = [
    _make('Boxy Default',       '#A855F7', '#2D2131', '#1C161D'),
    _make('Linear Minimal',     '#000000', '#FFFFFF', '#F7F7F8'),
    _make('Supabase Hacker',    '#3ECF8E', '#1C1C1C', '#121212'),
    _make('Cyberpunk 2077',     '#FCE205', '#20202B', '#0B0B12'),
    _make('Lofi Study',         '#D4A373', '#FAEDCD', '#FEFAE0'),
    _make('Midnight Ocean',     '#38BDF8', '#1E293B', '#0F172A'),
    _make('Matcha Aesthetic',   '#6B9080', '#EAF4F4', '#F6FFF8'),
    _make('Dracula',            '#FF79C6', '#44475A', '#282A36'),
    _make('Synthwave',          '#FF007F', '#2A1B3D', '#11001C'),
    _make('Sakura Pink',        '#FF99AC', '#FFF0F3', '#FFFFFF'),
    _make('Gruvbox',            '#FABD2F', '#3C3836', '#282828'),
    _make('Stripe Blurple',     '#635BFF', '#FFFFFF', '#F6F9FC'),
    _make('Nord Frost',         '#88C0D0', '#3B4252', '#2E3440'),
    _make('Brutalism',          '#FFFFFF', '#1A1A1A', '#000000'),
    _make('Outrun Vaporwave',   '#00FFFF', '#30005A', '#1A0033'),
    _make('Autumn Rust',        '#E07A5F', '#3D405B', '#2B2D42'),
    _make('Lavender Cloud',     '#8338EC', '#FFFFFF', '#F8F9FA'),
    _make('Coral Reef',         '#FF6B6B', '#292F36', '#1A1E24'),
    _make('Solarized Light',    '#268BD2', '#EEE8D5', '#FDF6E3'),
    _make('OLED Blood',         '#FF2A2A', '#111111', '#000000'),
  ];

  // Cycles through presets sequentially on each call
  static int _presetIndex = 0;

  factory ThemePalette.random() {
    final palette = presets[_presetIndex % presets.length];
    _presetIndex = (_presetIndex + 1) % presets.length;
    return palette;
  }

  // Default Boxy Theme — white page background, purple primary
  factory ThemePalette.boxy() {
    return ThemePalette(
      name: '',
      primary: const Color(0xFF8B3DFF),
      surface: Colors.white,
      background: Colors.white,
      textDark: const Color(0xFF1A1A1A),
      textLight: Colors.white,
    );
  }
}
