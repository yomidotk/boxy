import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/layout_item.dart';

class BlueprintPainter extends CustomPainter {
  final LayoutItem? selectedItem;
  final List<LayoutItem> allItems;
  final bool showDimensions;

  BlueprintPainter({
    required this.selectedItem,
    required this.allItems,
    this.showDimensions = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || !size.height.isFinite) return;

    if (showDimensions) {
      // Draw dimensions for ALL items
      for (var item in allItems) {
        if (item.position.dx.isFinite &&
            item.position.dy.isFinite &&
            item.size.width.isFinite &&
            item.size.height.isFinite &&
            item.rotation.isFinite) {
          _drawTechnicalDimensions(
            canvas,
            item,
            size,
            isSelected: item == selectedItem,
          );
        }
      }
    } else if (selectedItem != null) {
      // Only draw for selected
      if (selectedItem!.position.dx.isFinite &&
          selectedItem!.position.dy.isFinite &&
          selectedItem!.size.width.isFinite &&
          selectedItem!.size.height.isFinite &&
          selectedItem!.rotation.isFinite) {
        _drawTechnicalDimensions(canvas, selectedItem!, size, isSelected: true);
      }
    }

    // Always draw Smart Gaps for Selected Item (if any)
    if (selectedItem != null &&
        selectedItem!.position.dx.isFinite &&
        selectedItem!.position.dy.isFinite) {
      _drawSmartGaps(canvas, selectedItem!);
    }
  }

  void _drawTechnicalDimensions(
    Canvas canvas,
    LayoutItem item,
    Size size, {
    bool isSelected = false,
  }) {
    // 0. Setup Drawing Variables (Handle Full Width)
    final double drawX = item.isFullWidth ? 0.0 : item.position.dx;
    final double drawW = item.isFullWidth ? 800.0 : item.size.width;
    final double drawY = item.position.dy;
    final double drawH = item.size.height;

    // 0. Setup Rotation Transform (V21: Hardened checks for NaN)
    final double centerX = drawX + drawW / 2;
    final double centerY = drawY + drawH / 2;

    if (!centerX.isFinite || !centerY.isFinite || !item.rotation.isFinite) {
      return;
    }

    canvas.save();
    canvas.translate(centerX, centerY);
    // Rotate canvas to match item
    canvas.rotate(item.rotation * math.pi / 180);
    // Translate back so we can draw using standard coordinates
    canvas.translate(-centerX, -centerY);

    final Paint linePaint = Paint()
      ..color = Colors
          .black // Monochrome Black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Technical Drawing Style: Arrowheads
    void drawDoubleArrow(
      Offset start,
      Offset end,
      String text, {
      bool vertical = false,
    }) {
      // Main Line
      canvas.drawLine(start, end, linePaint);

      // Arrowheads
      // Arrow at Start (Points towards Start)
      // Standard technical arrow: <---|
      final double angle = (end - start).direction;
      const double arrowLen = 6.0;

      // Start Arrow
      canvas.drawLine(
        start,
        start + Offset.fromDirection(angle + 0.5, arrowLen),
        linePaint,
      );
      canvas.drawLine(
        start,
        start + Offset.fromDirection(angle - 0.5, arrowLen),
        linePaint,
      );

      // End Arrow
      canvas.drawLine(
        end,
        end + Offset.fromDirection(angle + 3.1415 + 0.5, arrowLen),
        linePaint,
      );
      canvas.drawLine(
        end,
        end + Offset.fromDirection(angle + 3.1415 - 0.5, arrowLen),
        linePaint,
      );

      // Text Label (Centered)
      Offset mid = (start + end) / 2;

      canvas.save();
      canvas.translate(mid.dx, mid.dy);
      // For text, we might want it to be readable.
      // If we are already rotated by item.rotation, standard drawing aligns with the line.
      // Vertical lines need -90 deg rotation relative to the current canvas (which is already rotated).
      if (vertical) {
        canvas.rotate(-1.5708); // -90 degrees
      }

      // OPTIONAL: Keep text upright?
      // Technical drawings typically align text with the dimension line.
      // So no extra logic needed here.

      _drawTextCentered(canvas, text, Offset.zero);
      canvas.restore();
    }

    // Helper: Check if a given label/arrow area intersects with ANY other item
    // Note: checkCollision is Axis-Aligned calculation. It might be slightly inaccurate for rotated environment
    // but suffices for basic placement.
    bool checkCollision(Rect area) {
      if (area.top < 0 || area.left < 0) return true; // Screen Edge Collision
      // Check against all other items
      for (var other in allItems) {
        if (other.id == item.id) continue;
        // Simple bounding box collision
        // V16: Use effective bounds for collision check too
        double otherX = other.isFullWidth ? 0.0 : other.position.dx;
        double otherW = other.isFullWidth ? 800.0 : other.size.width;

        Rect otherRect = Rect.fromLTWH(
          otherX,
          other.position.dy,
          otherW,
          other.size.height,
        );
        if (area.overlaps(otherRect)) return true;
      }
      return false;
    }

    // 1. Width Dimension logic
    // 1. Width Dimension
    // Default: Top (20px Above)
    // Rule: item.top < 50 ? Draw BELOW : Draw ABOVE
    // We also check advanced collision

    // Define the area we want to draw in (roughly 40px high strip above)
    Rect topArea = Rect.fromLTWH(drawX, drawY - 40, drawW, 40);

    // Check collision (Edge < 0 or Overlap other items)
    // Note: User specified y < 50 for edge. checkCollision uses < 0.
    // We can combine:
    bool forceBottom = drawY < 50;
    bool collisionTop = forceBottom || checkCollision(topArea);

    double yPos = collisionTop
        ? drawY +
              drawH +
              20 // Below (20px)
        : drawY - 20; // Above (20px)

    double extY1 = collisionTop ? drawY + drawH : drawY;

    // Draw Width Extension Lines
    canvas.drawLine(
      Offset(drawX, extY1),
      Offset(drawX, yPos),
      linePaint..color = Colors.grey[400]!, // Lighter Grey
    );
    canvas.drawLine(
      Offset(drawX + drawW, extY1),
      Offset(drawX + drawW, yPos),
      linePaint..color = Colors.grey[400]!,
    );

    // Reset Color to Black for Main Arrow
    linePaint.color = Colors.black;

    // Draw Width Arrow
    drawDoubleArrow(
      Offset(drawX, yPos),
      Offset(drawX + drawW, yPos),
      "${drawW.toInt()}px",
    );

    // 2. Height Dimension
    // Default: Right (20px to Right)
    // Rule: If close to right edge (canvas width) or collision -> Draw LEFT
    // We need canvas size? 'size' passed to paint is the canvas size.

    Rect rightArea = Rect.fromLTWH(drawX + drawW, drawY, 40, drawH);

    // Check right edge collision explicitly logic since checkCollision does < 0 for left/top
    bool forceLeft = (drawX + drawW + 50) > size.width;
    bool collisionRight = forceLeft || checkCollision(rightArea);

    double xPos = collisionRight
        ? drawX -
              20 // Left (20px)
        : drawX + drawW + 20; // Right (20px)

    double extX1 = collisionRight ? drawX : drawX + drawW;

    // Draw Height Extension Lines
    canvas.drawLine(
      Offset(extX1, drawY),
      Offset(xPos, drawY),
      linePaint..color = Colors.grey[400]!,
    );
    canvas.drawLine(
      Offset(extX1, drawY + drawH),
      Offset(xPos, drawY + drawH),
      linePaint..color = Colors.grey[400]!,
    );

    // Reset Color
    linePaint.color = Colors.black;

    // Draw Height Arrow
    drawDoubleArrow(
      Offset(xPos, drawY + drawH),
      Offset(xPos, drawY),
      "${drawH.toInt()}px",
      vertical: true,
    );

    canvas.restore();
  }

  void _drawSmartGaps(Canvas canvas, LayoutItem item) {
    final Paint smartGapPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var other in allItems) {
      if (other.id == item.id) continue;

      if (item.position.dx + item.size.width < other.position.dx) {
        double gap = other.position.dx - (item.position.dx + item.size.width);
        if (gap < 60 && gap > 0) {
          // ... (Existing implementation shortened for brevity, but retaining logic)
          // Re-implementing simplified smart gap for this pass
          Offset start = Offset(
            item.position.dx + item.size.width,
            item.position.dy + item.size.height / 2,
          );
          Offset end = Offset(
            other.position.dx,
            item.position.dy + item.size.height / 2,
          );
          if ((item.position.dy - other.position.dy).abs() < 50) {
            canvas.drawLine(start, end, smartGapPaint);
            // Label
            TextSpan span = TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              text: "${gap.toInt()}",
            );
            TextPainter tp = TextPainter(
              text: span,
              textDirection: TextDirection.ltr,
            );
            tp.layout();
            tp.paint(
              canvas,
              Offset(start.dx + gap / 2 - tp.width / 2, start.dy - 15),
            );
          }
        }
      }
    }
  }

  void _drawTextCentered(Canvas canvas, String text, Offset center) {
    TextSpan span = TextSpan(
      style: const TextStyle(
        color: Colors.black, // Black Text
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    // White Background
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: tp.width + 6,
        height: tp.height + 4,
      ),
      paint,
    );
    // Border for text box
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: tp.width + 6,
        height: tp.height + 4,
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant BlueprintPainter oldDelegate) {
    // V21: Since we use ListenableBuilder with mutable objects,
    // we should repaint whenever the builder triggers.
    return true;
  }
}
