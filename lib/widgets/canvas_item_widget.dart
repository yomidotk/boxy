import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/layout_item.dart';
import '../providers/layout_provider.dart';

class CanvasItemWidget extends StatelessWidget {
  final LayoutItem item;

  const CanvasItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LayoutProvider>(context, listen: false);

    // V21: Granular Selection Listening
    final isSelected = context.select<LayoutProvider, bool>(
      (p) => p.selectedItem?.id == item.id,
    );

    return ListenableBuilder(
      listenable: item,
      builder: (context, child) {
        final Size canvasSize = MediaQuery.of(context).size;

        const double padding = 100.0;
        const double canvasOffset = 2100.0; // V22: (5000 - 800) / 2
        final double renderLeft = item.isFullWidth ? -padding + canvasOffset : item.position.dx - padding + canvasOffset;
        final double renderWidth = item.isFullWidth ? 800.0 : item.size.width;

        return Positioned(
          left: renderLeft,
          top: item.position.dy - padding,
          child: Transform.rotate(
            angle: item.rotation * 3.14159 / 180,
            child: SizedBox(
              width: renderWidth + (padding * 2),
              height: item.size.height + (padding * 2),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: padding,
                    top: padding,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: isSelected ? (_) => provider.setDragging(true) : null,
                      onPanEnd: (_) => provider.setDragging(false),
                      onPanCancel: () => provider.setDragging(false),
                      onTap: () {
                        provider.selectItem(item.id);
                      },
                      onPanUpdate: isSelected
                          ? (details) {
                              if (item.isFullWidth) {
                                provider.updatePosition(
                                  item.id,
                                  Offset(item.position.dx, item.position.dy + details.delta.dy),
                                  canvasSize,
                                );
                                return;
                              }
                              provider.selectItem(item.id);
                              provider.updatePosition(item.id, item.position + details.delta, canvasSize);
                            }
                          : null,
                      child: Container(
                        width: renderWidth,
                        height: item.size.height,
                        decoration: BoxDecoration(
                          border: isSelected ? Border.all(color: const Color(0xFF8B3DFF), width: 2) : null,
                          borderRadius: BorderRadius.circular(item.borderRadius),
                        ),
                        child: _buildContent(item, renderWidth),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(LayoutItem item, double width) {
    switch (item.type) {
      case ItemType.box:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
        );
      case ItemType.image:
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
          child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
        );
      case ItemType.text:
        return Center(
          child: Text(
            item.textContent,
            style: TextStyle(
              fontSize: item.fontSize,
              color: Colors.black,
            ),
          ),
        );
      case ItemType.logo:
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber, size: item.fontSize * 1.2),
              const SizedBox(width: 8),
              Text(
                item.textContent,
                style: TextStyle(
                  fontSize: item.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        );
      case ItemType.button:
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
          child: Center(
            child: Text(
              item.textContent,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case ItemType.card:
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(item.borderRadius)),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                item.textContent,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: item.fontSize),
              ),
            ),
          ),
        );
      case ItemType.navBar:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: item.navAlignment,
            children: item.navItems.map((navItem) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: item.navSpacing / 2),
                child: Text(
                  navItem,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      case ItemType.search:
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(item.textContent, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      case ItemType.dropdown:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.dropdownItems.isNotEmpty ? item.dropdownItems.first : "Select...",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20, color: Colors.black),
              ],
            ),
          ),
        );
      case ItemType.input:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.textContent,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ),
        );
      case ItemType.checkbox:
        return Row(
          children: [
            Container(width: 20, height: 20, decoration: BoxDecoration(border: Border.all(color: Colors.grey))),
            const SizedBox(width: 8),
            Text(item.textContent),
          ],
        );
      case ItemType.list:
        return Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[200]!)),
          child: Center(child: Text(item.textContent)),
        );
    }
  }
}
