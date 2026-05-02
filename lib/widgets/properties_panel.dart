import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/layout_item.dart';
import '../providers/layout_provider.dart';

class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // V21: Granular Listener for Selected Item
    final selectedItem = context.select<LayoutProvider, LayoutItem?>(
      (p) => p.selectedItem,
    );
    final provider = Provider.of<LayoutProvider>(context, listen: false);

    if (selectedItem == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Select an item to edit its properties",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    // V21: Listen only to this item's changes
    return ListenableBuilder(
      listenable: selectedItem,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(selectedItem.id, selectedItem.type),
              const SizedBox(height: 12),

              // AI Context — shown at top so it's the first thing you fill in
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B3DFF).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF8B3DFF).withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF8B3DFF)),
                        const SizedBox(width: 6),
                        const Text(
                          "AI CONTEXT",
                          style: TextStyle(
                            color: Color(0xFF8B3DFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Describe what this element should do — its behavior, styling intent, interactions, etc. This is written as an HTML comment to guide AI coding tools when they implement your design.",
                      style: TextStyle(color: Colors.white38, fontSize: 10, height: 1.5),
                    ),
                    const SizedBox(height: 10),
                    _AiContextEditor(
                      key: ValueKey('ai_\${selectedItem.id}'),
                      initialValue: selectedItem.aiContext,
                      onChanged: (v) => provider.updateAiContext(selectedItem.id, v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Layout Section
              _buildSectionTitle("LAYOUT"),
              Row(
                children: [
                  Expanded(
                    child: _buildNumericField(
                      label: "X",
                      value: selectedItem.position.dx,
                      onChanged: (v) => provider.updatePosition(
                        selectedItem.id,
                        Offset(v, selectedItem.position.dy),
                        Size.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNumericField(
                      label: "Y",
                      value: selectedItem.position.dy,
                      onChanged: (v) => provider.updatePosition(
                        selectedItem.id,
                        Offset(selectedItem.position.dx, v),
                        Size.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildNumericField(
                      label: "W",
                      value: selectedItem.size.width,
                      onChanged: (v) => provider.updateSize(
                        selectedItem.id,
                        Size(v, selectedItem.size.height),
                      ),
                      enabled: !selectedItem.isFullWidth,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildNumericField(
                      label: "H",
                      value: selectedItem.size.height,
                      onChanged: (v) => provider.updateSize(
                        selectedItem.id,
                        Size(selectedItem.size.width, v),
                      ),
                    ),
                  ),
                ],
              ),

              // Full Width Toggle — hidden for fixed-shape items
              if (![ItemType.text, ItemType.logo, ItemType.dropdown, ItemType.input,
                    ItemType.toggle, ItemType.profileImage, ItemType.checkbox, ItemType.button]
                  .contains(selectedItem.type)) ...[
                const SizedBox(height: 10),
                _buildToggle(
                  label: "Full Width",
                  value: selectedItem.isFullWidth,
                  onChanged: (v) => provider.toggleFullWidth(selectedItem.id, v),
                ),
              ],

              const SizedBox(height: 20),

              // Style Section
              _buildSectionTitle("STYLE"),
              // Rotation — hidden for layout-anchored elements
              if (![ItemType.navBar, ItemType.sidebar, ItemType.table]
                  .contains(selectedItem.type))
                _buildSlider(
                  label: "Rotation",
                  value: selectedItem.rotation,
                  min: 0,
                  max: 360,
                  onChanged: (v) => provider.updateRotation(selectedItem.id, v),
                ),
              // Corner Radius — hidden for shape-fixed items
              if (![ItemType.text, ItemType.profileImage, ItemType.toggle,
                    ItemType.table]
                  .contains(selectedItem.type)) ...[
                _buildSlider(
                  label: "Corner Radius",
                  value: selectedItem.borderRadius,
                  min: 0,
                  max: 50,
                  onChanged: (v) =>
                      provider.updateBorderRadius(selectedItem.id, v),
                ),
              ],

              const SizedBox(height: 20),

              // Type Specific Content (Text-Enabled Items)
              if ([ItemType.text, ItemType.button, ItemType.logo, ItemType.search, ItemType.input].contains(selectedItem.type)) ...[
                _buildSectionTitle("TEXT"),
                _TextContentEditor(
                  // Key on item ID ensures controller resets when a different item is selected,
                  // but NOT on every keystroke within the same item.
                  key: ValueKey(selectedItem.id),
                  // Always use textContent — canvas renders textContent for all these types.
                  initialValue: selectedItem.textContent,
                  onChanged: (v) => provider.updateTextContent(selectedItem.id, v),
                ),
                const SizedBox(height: 12),
                
                // V21: Presets ONLY for text items
                if (selectedItem.type == ItemType.text) ...[
                  _buildTextPresets(provider, selectedItem),
                  const SizedBox(height: 12),
                ],

                _buildSlider(
                  label: "Font Size",
                  value: selectedItem.fontSize,
                  min: 8,
                  max: 120,
                  onChanged: (v) => provider.updateFontSize(selectedItem.id, v),
                ),
              ],

              if (selectedItem.type == ItemType.navBar) ...[
                _buildSectionTitle("NAVIGATION"),
                ..._buildNavItemsList(context, provider, selectedItem),
                const SizedBox(height: 12),
                _buildNavAlignmentDropdown(provider, selectedItem),
                _buildNavSpacingSlider(provider, selectedItem),
              ],

              if (selectedItem.type == ItemType.dropdown) ...[
                _buildSectionTitle("DROPDOWN OPTIONS"),
                ..._buildDropdownItemsList(context, provider, selectedItem),
              ],

              if (selectedItem.type == ItemType.list) ...[
                _buildSectionTitle("LIST ROWS"),
                ..._buildListItemsList(context, provider, selectedItem),
              ],

              const SizedBox(height: 30),
              _buildDuplicateButton(provider, selectedItem),
              const SizedBox(height: 10),
              _buildDeleteButton(provider, selectedItem),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(String id, ItemType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("ID", id),
        _buildInfoRow("Type", type.name.toUpperCase()),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: Colors.white70,
            letterSpacing: 1.2,
          ),
        ),
        const Divider(color: Colors.white10, height: 20),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericField({
    required String label,
    required double value,
    required Function(double) onChanged,
    bool enabled = true,
  }) {
    return TextFormField(
      // V21: Robust key to ensure UI updates when data changes from other sources
      key: ValueKey("${label}_${value.toString()}"),
      initialValue: value.toStringAsFixed(0),
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? Colors.white10 : Colors.white.withValues(alpha: 0.05),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 10),
        isDense: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      style: TextStyle(
        color: enabled ? Colors.white : Colors.white38,
        fontSize: 13,
      ),
      keyboardType: TextInputType.number,
      onFieldSubmitted: (val) {
        double? newVal = double.tryParse(val);
        if (newVal != null) onChanged(newVal);
      },
    );
  }

  Widget _buildToggle({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        SizedBox(
          height: 30,
          child: Switch(
            value: value,
            activeTrackColor: const Color(0xFF8B3DFF),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ${value.toInt()}",
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: const Color(0xFF8B3DFF),
          inactiveColor: Colors.white10,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Kept for non-text-content uses (if any future use)
  // The TEXT CONTENT field now uses _TextContentEditor instead.

  List<Widget> _buildNavItemsList(
    BuildContext context,
    LayoutProvider provider,
    LayoutItem item,
  ) {
    return <Widget>[
      ...item.navItems.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.value,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.redAccent,
                  size: 18,
                ),
                onPressed: () {
                  var newItems = List<String>.from(item.navItems);
                  newItems.removeAt(entry.key);
                  provider.updateNavItems(item.id, newItems);
                },
              ),
            ],
          ),
        );
      }),
      OutlinedButton.icon(
        onPressed: () => _showAddNavItemDialog(context, provider, item),
        icon: const Icon(Icons.add, size: 14, color: Colors.white),
        label: const Text(
          "Add Link",
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
        ),
      ),
    ];
  }

  void _showAddNavItemDialog(
    BuildContext context,
    LayoutProvider provider,
    LayoutItem item,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title:
            const Text("Add Menu Item", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Link Name",
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                var newItems = List<String>.from(item.navItems);
                newItems.add(controller.text);
                provider.updateNavItems(item.id, newItems);
                Navigator.pop(c);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildNavAlignmentDropdown(LayoutProvider provider, LayoutItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Align", style: TextStyle(color: Colors.grey, fontSize: 12)),
        DropdownButton<MainAxisAlignment>(
          dropdownColor: Colors.black,
          underline: const SizedBox(),
          value: item.navAlignment,
          items: MainAxisAlignment.values.map((align) {
            return DropdownMenuItem(
              value: align,
              child: Text(
                align.name,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              provider.updateNavProperties(item.id, alignment: val);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNavSpacingSlider(LayoutProvider provider, LayoutItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Spacing", style: TextStyle(color: Colors.grey, fontSize: 12)),
        Slider(
          value: item.navSpacing.clamp(0, 100),
          min: 0,
          max: 100,
          activeColor: Colors.white,
          inactiveColor: Colors.white10,
          onChanged: (val) =>
              provider.updateNavProperties(item.id, spacing: val),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(LayoutProvider provider, LayoutItem item) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          foregroundColor: Colors.redAccent,
          elevation: 0,
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        onPressed: () => provider.removeItem(item.id),
        icon: const Icon(Icons.delete_outline, size: 18),
        label: const Text(
          "Delete Item",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDuplicateButton(LayoutProvider provider, LayoutItem item) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B3DFF).withValues(alpha: 0.1),
          foregroundColor: const Color(0xFF8B3DFF),
          elevation: 0,
          side: const BorderSide(color: Color(0xFF8B3DFF), width: 1),
        ),
        onPressed: () => provider.duplicateItem(item.id),
        icon: const Icon(Icons.copy, size: 18),
        label: const Text(
          "Duplicate Item",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextPresets(LayoutProvider provider, LayoutItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PRESETS",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _presetButton(provider, item.id, "Title", "title"),
            const SizedBox(width: 8),
            _presetButton(provider, item.id, "Sub", "subtitle"),
            const SizedBox(width: 8),
            _presetButton(provider, item.id, "Body", "paragraph"),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildDropdownItemsList(
    BuildContext context,
    LayoutProvider provider,
    LayoutItem item,
  ) {
    return <Widget>[
      ...item.dropdownItems.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.value,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.redAccent,
                  size: 18,
                ),
                onPressed: () {
                  var newItems = List<String>.from(item.dropdownItems);
                  newItems.removeAt(entry.key);
                  provider.updateDropdownItems(item.id, newItems);
                },
              ),
            ],
          ),
        );
      }),
      OutlinedButton.icon(
        onPressed: () => _showAddDropdownItemDialog(context, provider, item),
        icon: const Icon(Icons.add, size: 14, color: Colors.white),
        label: const Text(
          "Add Option",
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
        ),
      ),
    ];
  }

  List<Widget> _buildListItemsList(
    BuildContext context,
    LayoutProvider provider,
    LayoutItem item,
  ) {
    return <Widget>[
      ...item.listItems.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.drag_indicator, color: Colors.white24, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  entry.value,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () => _showEditListItemDialog(context, provider, item, entry.key, entry.value),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () {
                  final newItems = List<String>.from(item.listItems)..removeAt(entry.key);
                  provider.updateListItems(item.id, newItems);
                },
              ),
            ],
          ),
        );
      }),
      const SizedBox(height: 4),
      OutlinedButton.icon(
        onPressed: () => _showAddListItemDialog(context, provider, item),
        icon: const Icon(Icons.add, size: 14, color: Colors.white),
        label: const Text("Add Row", style: TextStyle(color: Colors.white, fontSize: 12)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
      ),
    ];
  }

  void _showEditListItemDialog(
    BuildContext context,
    LayoutProvider provider,
    LayoutItem item,
    int index,
    String currentValue,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Edit Row", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Row title",
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newItems = List<String>.from(item.listItems);
                newItems[index] = controller.text;
                provider.updateListItems(item.id, newItems);
                Navigator.pop(c);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showAddListItemDialog(
    BuildContext context,
    LayoutProvider provider,
    LayoutItem item,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Add Row", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Row title",
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newItems = List<String>.from(item.listItems)..add(controller.text);
                provider.updateListItems(item.id, newItems);
                Navigator.pop(c);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAddDropdownItemDialog(
    BuildContext context,
    LayoutProvider provider,
    LayoutItem item,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Add Dropdown Option",
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Option Name",
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                var newItems = List<String>.from(item.dropdownItems);
                newItems.add(controller.text);
                provider.updateDropdownItems(item.id, newItems);
                Navigator.pop(c);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _presetButton(
      LayoutProvider provider, String id, String label, String preset) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4),
          side: const BorderSide(color: Colors.white24),
          foregroundColor: Colors.white,
        ),
        onPressed: () => provider.applyTextPreset(id, preset),
        child: Text(label, style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}

/// A StatefulWidget for editing text content without losing focus on rebuild.
/// It uses a persistent TextEditingController keyed only on item ID,
/// so typing a letter does NOT destroy and recreate the field.
class _TextContentEditor extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;

  const _TextContentEditor({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_TextContentEditor> createState() => _TextContentEditorState();
}

class _TextContentEditorState extends State<_TextContentEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_TextContentEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync the controller if the text changed externally
    // (e.g. from a preset button), preserving cursor position otherwise.
    if (widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      maxLines: 3,
      decoration: InputDecoration(
        labelText: "Content",
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 10),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
      onChanged: widget.onChanged,
    );
  }
}

/// Persistent text editor for the AI Context field.
class _AiContextEditor extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;

  const _AiContextEditor({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_AiContextEditor> createState() => _AiContextEditorState();
}

class _AiContextEditorState extends State<_AiContextEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_AiContextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "e.g. Submit the contact form when clicked",
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF8B3DFF)),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
      onChanged: widget.onChanged,
    );
  }
}
