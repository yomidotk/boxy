import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/layout_item.dart';

class BlueprintPainter extends CustomPainter {
  final LayoutItem? selectedItem;
  final List<LayoutItem> allItems;
  final bool showDimensions;
  final Color backgroundColor;

  BlueprintPainter({
    required this.selectedItem,
    required this.allItems,
    this.showDimensions = false,
    this.backgroundColor = Colors.white,
  });

  // Adaptive colors derived from background luminance
  bool get _isDark => backgroundColor.computeLuminance() < 0.5;
  Color get _lineColor => _isDark ? Colors.white : Colors.black;
  Color get _extensionColor => _isDark ? const Color(0x66FFFFFF) : Colors.grey.shade400;
  Color get _textColor => _isDark ? Colors.white : Colors.black;
  Color get _textBgColor => _isDark ? const Color(0xDD1A1A1A) : const Color(0xDDFFFFFF);
  Color get _textBorderColor => _isDark ? const Color(0x55FFFFFF) : Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || !size.height.isFinite) return;

    const double canvasOffset = 2100.0;
    canvas.save();
    canvas.translate(canvasOffset, 0);

    if (showDimensions) {
      for (var item in allItems) {
        if (item.position.dx.isFinite &&
            item.position.dy.isFinite &&
            item.size.width.isFinite &&
            item.size.height.isFinite &&
            item.rotation.isFinite) {
          _drawTechnicalDimensions(canvas, item, size, isSelected: item == selectedItem);
        }
      }
    } else if (selectedItem != null) {
      if (selectedItem!.position.dx.isFinite &&
          selectedItem!.position.dy.isFinite &&
          selectedItem!.size.width.isFinite &&
          selectedItem!.size.height.isFinite &&
          selectedItem!.rotation.isFinite) {
        _drawTechnicalDimensions(canvas, selectedItem!, size, isSelected: true);
      }
    }

    if (selectedItem != null &&
        selectedItem!.position.dx.isFinite &&
        selectedItem!.position.dy.isFinite) {
      _drawSmartGaps(canvas, selectedItem!);
    }

    canvas.restore();
  }

  void _drawTechnicalDimensions(
    Canvas canvas,
    LayoutItem item,
    Size size, {
    bool isSelected = false,
  }) {
    final double drawX = item.isFullWidth ? 0.0 : item.position.dx;
    final double drawW = item.isFullWidth ? 800.0 : item.size.width;
    final double drawY = item.position.dy;
    final double drawH = item.size.height;

    final double centerX = drawX + drawW / 2;
    final double centerY = drawY + drawH / 2;

    if (!centerX.isFinite || !centerY.isFinite || !item.rotation.isFinite) return;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(item.rotation * math.pi / 180);
    canvas.translate(-centerX, -centerY);

    final Paint linePaint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    void drawDoubleArrow(Offset start, Offset end, String text, {bool vertical = false}) {
      canvas.drawLine(start, end, linePaint);

      final double angle = (end - start).direction;
      const double arrowLen = 6.0;

      canvas.drawLine(start, start + Offset.fromDirection(angle + 0.5, arrowLen), linePaint);
      canvas.drawLine(start, start + Offset.fromDirection(angle - 0.5, arrowLen), linePaint);
      canvas.drawLine(end, end + Offset.fromDirection(angle + math.pi + 0.5, arrowLen), linePaint);
      canvas.drawLine(end, end + Offset.fromDirection(angle + math.pi - 0.5, arrowLen), linePaint);

      Offset mid = (start + end) / 2;
      canvas.save();
      canvas.translate(mid.dx, mid.dy);
      if (vertical) canvas.rotate(-1.5708);
      _drawTextCentered(canvas, text, Offset.zero);
      canvas.restore();
    }

    bool checkCollision(Rect area) {
      if (area.top < 0 || area.left < -2100) return true;
      for (var other in allItems) {
        if (other.id == item.id) continue;
        double otherX = other.isFullWidth ? 0.0 : other.position.dx;
        double otherW = other.isFullWidth ? 800.0 : other.size.width;
        Rect otherRect = Rect.fromLTWH(otherX, other.position.dy, otherW, other.size.height);
        if (area.overlaps(otherRect)) return true;
      }
      return false;
    }

    // Width dimension
    Rect topArea = Rect.fromLTWH(drawX, drawY - 40, drawW, 40);
    bool forceBottom = drawY < 50;
    bool collisionTop = forceBottom || checkCollision(topArea);
    double yPos = collisionTop ? drawY + drawH + 20 : drawY - 20;
    double extY1 = collisionTop ? drawY + drawH : drawY;

    canvas.drawLine(Offset(drawX, extY1), Offset(drawX, yPos), linePaint..color = _extensionColor);
    canvas.drawLine(Offset(drawX + drawW, extY1), Offset(drawX + drawW, yPos), linePaint..color = _extensionColor);
    linePaint.color = _lineColor;
    drawDoubleArrow(Offset(drawX, yPos), Offset(drawX + drawW, yPos), "${drawW.toInt()}px");

    // Height dimension
    Rect rightArea = Rect.fromLTWH(drawX + drawW, drawY, 40, drawH);
    bool forceLeft = (drawX + drawW + 50) > 2900;
    bool collisionRight = forceLeft || checkCollision(rightArea);
    double xPos = collisionRight ? drawX - 20 : drawX + drawW + 20;
    double extX1 = collisionRight ? drawX : drawX + drawW;

    canvas.drawLine(Offset(extX1, drawY), Offset(xPos, drawY), linePaint..color = _extensionColor);
    canvas.drawLine(Offset(extX1, drawY + drawH), Offset(xPos, drawY + drawH), linePaint..color = _extensionColor);
    linePaint.color = _lineColor;
    drawDoubleArrow(Offset(xPos, drawY + drawH), Offset(xPos, drawY), "${drawH.toInt()}px", vertical: true);

    canvas.restore();
  }

  void _drawSmartGaps(Canvas canvas, LayoutItem item) {
    final Paint smartGapPaint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var other in allItems) {
      if (other.id == item.id) continue;

      if (item.position.dx + item.size.width < other.position.dx) {
        double gap = other.position.dx - (item.position.dx + item.size.width);
        if (gap < 60 && gap > 0) {
          Offset start = Offset(item.position.dx + item.size.width, item.position.dy + item.size.height / 2);
          Offset end = Offset(other.position.dx, item.position.dy + item.size.height / 2);
          if ((item.position.dy - other.position.dy).abs() < 50) {
            canvas.drawLine(start, end, smartGapPaint);
            TextSpan span = TextSpan(
              style: TextStyle(color: _textColor, fontSize: 10, fontWeight: FontWeight.bold),
              text: "${gap.toInt()}",
            );
            TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
            tp.layout();
            tp.paint(canvas, Offset(start.dx + gap / 2 - tp.width / 2, start.dy - 15));
          }
        }
      }
    }
  }

  void _drawTextCentered(Canvas canvas, String text, Offset center) {
    TextSpan span = TextSpan(
      style: TextStyle(color: _textColor, fontSize: 11, fontWeight: FontWeight.bold),
      text: text,
    );
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();

    // Background pill
    final bgPaint = Paint()..color = _textBgColor;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: tp.width + 6, height: tp.height + 4),
      bgPaint,
    );
    // Border
    canvas.drawRect(
      Rect.fromCenter(center: center, width: tp.width + 6, height: tp.height + 4),
      Paint()..color = _textBorderColor..style = PaintingStyle.stroke..strokeWidth = 1,
    );

    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant BlueprintPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.selectedItem != selectedItem ||
        oldDelegate.showDimensions != showDimensions;
  }
}
