import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/layout_provider.dart';
import '../models/theme_palette.dart';

class ThemePanel extends StatefulWidget {
  const ThemePanel({super.key});

  @override
  State<ThemePanel> createState() => _ThemePanelState();
}

class _ThemePanelState extends State<ThemePanel> {
  final TextEditingController _primaryCtrl = TextEditingController();
  final TextEditingController _surfaceCtrl = TextEditingController();
  final TextEditingController _bgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateControllers();
  }

  void _updateControllers() {
    final theme = Provider.of<LayoutProvider>(context, listen: false).currentTheme;
    _primaryCtrl.text = _colorToHex(theme.primary);
    _surfaceCtrl.text = _colorToHex(theme.surface);
    _bgCtrl.text = _colorToHex(theme.background);
  }

  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  void _applyCustomTheme() {
    try {
      final newTheme = ThemePalette(
        primary: _hexToColor(_primaryCtrl.text),
        surface: _hexToColor(_surfaceCtrl.text),
        background: _hexToColor(_bgCtrl.text),
        textDark: const Color(0xFF1A1A1A),
        textLight: Colors.white,
      );
      Provider.of<LayoutProvider>(context, listen: false).applyTheme(newTheme);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Hex Code (Use #RRGGBB)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LayoutProvider>(context);
    final theme = provider.currentTheme;

    // Keep controllers in sync if theme changes externally (like random generation)
    _primaryCtrl.text = _colorToHex(theme.primary);
    _surfaceCtrl.text = _colorToHex(theme.surface);
    _bgCtrl.text = _colorToHex(theme.background);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SMART PALETTE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Automatically applies colors to all items while ensuring high contrast.",
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const Divider(color: Colors.white10, height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B3DFF),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                provider.applyTheme(ThemePalette.random());
              },
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text("Generate Random Palette"),
            ),
          ),
          if (theme.name.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    theme.name,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 30),
          
          const Text(
            "CUSTOM THEME",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const Divider(color: Colors.white10, height: 20),
          
          _buildColorRow("Primary (Buttons, Accents)", _primaryCtrl, theme.primary),
          const SizedBox(height: 12),
          _buildColorRow("Surface (Boxes, Cards)", _surfaceCtrl, theme.surface),
          const SizedBox(height: 12),
          _buildColorRow("Background", _bgCtrl, theme.background),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                foregroundColor: Colors.white,
              ),
              onPressed: _applyCustomTheme,
              child: const Text("Apply Custom Colors"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(String label, TextEditingController ctrl, Color preview) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: preview,
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.grey, fontSize: 10),
              filled: true,
              fillColor: Colors.white10,
              isDense: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
