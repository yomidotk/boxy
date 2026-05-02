import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../providers/layout_provider.dart';

class ItemSelectionOverlay extends StatelessWidget {
  const ItemSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LayoutProvider>(
      builder: (context, provider, child) {
        final selectedItem = provider.selectedItem;
        if (selectedItem == null) return const SizedBox.shrink();

        return ListenableBuilder(
          listenable: selectedItem,
          builder: (context, child) {
            const double padding = 100.0;
            final item = selectedItem;
            
            final double renderWidth = item.isFullWidth ? 800.0 : item.size.width;
            final double renderLeft = item.isFullWidth ? -padding : item.position.dx - padding;
            final double renderTop = item.position.dy - padding;

            return Positioned(
              left: renderLeft,
              top: renderTop,
              child: Transform.rotate(
                angle: item.rotation * math.pi / 180,
                child: SizedBox(
                  width: renderWidth + (padding * 2),
                  height: item.size.height + (padding * 2),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Resize Handle (Bottom Right)
                      Positioned(
                        left: padding + renderWidth - 40,
                        top: padding + item.size.height - 40,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanUpdate: (details) {
                            Size newSize = Size(
                              item.isFullWidth
                                  ? item.size.width
                                  : (item.size.width + details.delta.dx).clamp(30.0, 1000.0),
                              (item.size.height + details.delta.dy).clamp(30.0, 1000.0),
                            );
                            if (newSize.width.isFinite && newSize.height.isFinite) {
                              provider.updateSize(item.id, newSize);
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.transparent,
                            child: Center(child: _buildHandle()),
                          ),
                        ),
                      ),

                      // 2. Rotation Handle (Top Right)
                      Positioned(
                        left: padding + renderWidth + 20,
                        top: padding - 70,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanUpdate: (details) {
                            final double centerX = padding + renderWidth / 2;
                            final double centerY = padding + item.size.height / 2;
                            final double handleCenterX = padding + renderWidth + 20 + 40;
                            final double handleCenterY = padding - 70 + 40;

                            final double localDx = handleCenterX - centerX;
                            final double localDy = handleCenterY - centerY;

                            final double rotRad = item.rotation * math.pi / 180;
                            final double cosT = math.cos(rotRad);
                            final double sinT = math.sin(rotRad);

                            final double globalDx = localDx * cosT - localDy * sinT;
                            final double globalDy = localDx * sinT + localDy * cosT;

                            final double torque = globalDx * details.delta.dy - globalDy * details.delta.dx;
                            final double radiusSquared = globalDx * globalDx + globalDy * globalDy;

                            if (radiusSquared < 100) return;

                            final double deltaDeg = (torque / radiusSquared) * 180 / math.pi;
                            double newRot = (item.rotation + deltaDeg);
                            newRot = (newRot % 360 + 360) % 360;

                            if (newRot.isFinite) {
                              provider.updateRotation(item.id, newRot);
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.transparent,
                            child: Center(child: _buildRotationHandle()),
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
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
    );
  }

  Widget _buildRotationHandle() {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.rotate_right, color: Colors.white, size: 18),
    );
  }
}
