import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/layout_provider.dart';
import '../models/layout_item.dart';

class LayersPanel extends StatelessWidget {
  const LayersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LayoutProvider>(
      builder: (context, provider, child) {
        // Visual Logic: List starts with Top-most item (Last in stack)
        // Data Logic: Stack renders items[0] at bottom.
        // So we display items.reversed.
        final reversedItems = provider.items.reversed.toList();

        return Container(
          color: Colors.black, // Monochrome Black
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false, // We use custom handles
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: reversedItems.length,
            onReorder: (oldIndex, newIndex) {
              // 1. Simulate the change on the reversed list
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = reversedItems.removeAt(oldIndex);
              reversedItems.insert(newIndex, item);

              // 2. Determine "True" Data Indices
              // The original list is the Reverse of this new reversed list.
              // So we can find where the item SHOULD be in the real list.
              final forwardList = reversedItems.reversed.toList();
              final intendedIndex = forwardList.indexOf(item);
              final originalIndex = provider.items.indexOf(item);

              // 3. Execute Move in Provider
              provider.moveItem(originalIndex, intendedIndex);
            },
            itemBuilder: (context, index) {
              final item = reversedItems[index];
              final isSelected = provider.selectedItem?.id == item.id;

              return Container(
                key: ValueKey(item.id),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors
                            .white12 // Light White Selection
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[800]!),
                    left: isSelected
                        ? const BorderSide(color: Colors.white, width: 4)
                        : BorderSide.none,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  dense: true,
                  onTap: () => provider.selectItem(item.id),
                  leading: _getIcon(item.type, isSelected),
                  title: Text(
                    "${item.type.name.toUpperCase()} ${item.id.split('_').last}",
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                      color: Colors.white, // White Text
                    ),
                  ),
                  trailing: ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_handle,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Icon _getIcon(ItemType type, bool isSelected) {
    Color color = isSelected ? Colors.white : Colors.grey[600]!;

    switch (type) {
      case ItemType.box:
        return Icon(Icons.check_box_outline_blank, size: 16, color: color);
      case ItemType.image:
        return Icon(Icons.image, size: 16, color: color);
      case ItemType.text:
        return Icon(Icons.text_fields, size: 16, color: color);
      case ItemType.button:
        return Icon(Icons.smart_button, size: 16, color: color);
      case ItemType.card:
        return Icon(Icons.credit_card, size: 16, color: color);
      case ItemType.logo:
        return Icon(Icons.star, size: 16, color: color);
      case ItemType.navBar:
        return Icon(Icons.menu, size: 16, color: color);
      case ItemType.dropdown:
        return Icon(Icons.arrow_drop_down_circle, size: 16, color: color);
      case ItemType.input:
        return Icon(Icons.input, size: 16, color: color);
      case ItemType.checkbox:
        return Icon(Icons.check_box, size: 16, color: color);
      case ItemType.list:
        return Icon(Icons.list, size: 16, color: color);
      case ItemType.search:
        return Icon(Icons.search, size: 16, color: color);
    }
  }
}
