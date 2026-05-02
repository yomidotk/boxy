import 'package:flutter/material.dart';
import '../models/layout_item.dart';

class ToolSidebar extends StatelessWidget {
  const ToolSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.black, // Monochrome Black
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            "TOOLS",
            style: TextStyle(
              color: Colors.white, // White Text
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildToolIcon(
                  ItemType.box,
                  Icons.check_box_outline_blank,
                  "BOX",
                ),
                _buildToolIcon(ItemType.image, Icons.image, "IMAGE"),
                _buildToolIcon(ItemType.button, Icons.smart_button, "BUTTON"),
                _buildToolIcon(ItemType.text, Icons.text_fields, "TEXT"),
                _buildToolIcon(ItemType.card, Icons.credit_card, "CARD"),
                _buildToolIcon(ItemType.logo, Icons.star_border, "LOGO"),
                _buildToolIcon(ItemType.navBar, Icons.menu, "NAV"),
                _buildToolIcon(
                  ItemType.dropdown,
                  Icons.arrow_drop_down_circle,
                  "DROP",
                ),
                _buildToolIcon(ItemType.input, Icons.input, "INPUT"),
                _buildToolIcon(ItemType.checkbox, Icons.check_box, "CHECK"),
                _buildToolIcon(ItemType.list, Icons.list, "LIST"),
                _buildToolIcon(ItemType.search, Icons.search, "SEARCH"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(ItemType type, IconData icon, String label) {
    return Draggable<ItemType>(
      data: type,
      feedback: Transform.scale(
        scale: 0.8,
        child: _ToolIcon(icon: icon, label: label, isDriving: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _ToolIcon(icon: icon, label: label),
      ),
      child: _ToolIcon(icon: icon, label: label),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDriving;

  const _ToolIcon({
    required this.icon,
    required this.label,
    this.isDriving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDriving
            ? Colors.white
            : Colors.transparent, // White feedback if dragging
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDriving
              ? Colors.transparent
              : Colors.white24, // Subtle White Border
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isDriving
                ? Colors.black
                : Colors.white, // Invert colors when dragging
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDriving ? Colors.black : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
