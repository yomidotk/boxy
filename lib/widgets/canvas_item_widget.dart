import 'dart:math' show cos, sin;
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
            color: item.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(item.borderRadius),
            border: item.borderColor != null ? Border.all(color: item.borderColor!) : null,
          ),
        );
      case ItemType.image:
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.grey[200],
            borderRadius: BorderRadius.circular(item.borderRadius),
            border: item.borderColor != null ? Border.all(color: item.borderColor!) : null,
          ),
          child: Center(child: Icon(Icons.image, color: item.iconColor ?? Colors.grey, size: 40)),
        );
      case ItemType.text:
        return Center(
          child: Text(
            item.textContent,
            style: TextStyle(
              fontSize: item.fontSize,
              color: item.textColor ?? Colors.black,
            ),
          ),
        );
      case ItemType.logo:
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: item.iconColor ?? Colors.amber, size: item.fontSize * 1.2),
              const SizedBox(width: 8),
              Text(
                item.textContent,
                style: TextStyle(
                  fontSize: item.fontSize,
                  fontWeight: FontWeight.bold,
                  color: item.textColor ?? Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        );
      case ItemType.button:
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.black,
            borderRadius: BorderRadius.circular(item.borderRadius),
            border: item.borderColor != null ? Border.all(color: item.borderColor!) : null,
          ),
          child: Center(
            child: Text(
              item.textContent,
              style: TextStyle(
                color: item.textColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case ItemType.card:
        return Card(
          elevation: 4,
          color: item.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(item.borderRadius),
            side: item.borderColor != null ? BorderSide(color: item.borderColor!) : BorderSide.none,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                item.textContent,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: item.fontSize, color: item.textColor ?? Colors.black),
              ),
            ),
          ),
        );
      case ItemType.navBar:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(item.borderRadius),
            border: item.borderRadius > 0
                ? Border.all(color: item.borderColor ?? Colors.grey[300]!)
                : Border(bottom: BorderSide(color: item.borderColor ?? Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: item.navAlignment,
            children: item.navItems.map((navItem) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: item.navSpacing / 2),
                child: Text(
                  navItem,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: item.textColor ?? Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      case ItemType.search:
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.grey[100],
            border: Border.all(color: item.borderColor ?? Colors.grey[300]!),
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: item.iconColor ?? Colors.grey),
                const SizedBox(width: 8),
                Text(item.textContent, style: TextStyle(color: item.textColor ?? Colors.grey)),
              ],
            ),
          ),
        );
      case ItemType.dropdown:
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.white,
            border: Border.all(color: item.borderColor ?? Colors.grey[300]!),
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
                    style: TextStyle(color: item.textColor ?? Colors.black),
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 20, color: item.iconColor ?? Colors.black),
              ],
            ),
          ),
        );
      case ItemType.input:
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.white,
            border: Border.all(color: item.borderColor ?? Colors.grey[300]!),
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.textContent,
                style: TextStyle(color: item.textColor ?? Colors.grey[600], fontSize: 14),
              ),
            ),
          ),
        );
      case ItemType.checkbox:
        return Row(
          children: [
            Container(width: 20, height: 20, decoration: BoxDecoration(
              color: item.backgroundColor,
              border: Border.all(color: item.borderColor ?? Colors.grey)
            )),
            const SizedBox(width: 8),
            Text(item.textContent, style: TextStyle(color: item.textColor ?? Colors.black)),
          ],
        );
      case ItemType.list:
        final listBg = item.backgroundColor ?? Colors.white;
        final listText = item.textColor ?? Colors.black87;
        final listSubtle = listText.withValues(alpha: 0.45);
        final listIconBg = listText.withValues(alpha: 0.08);
        final dividerColor = listText.withValues(alpha: 0.08);
        return Container(
          decoration: BoxDecoration(
            color: listBg,
            border: Border.all(color: item.borderColor ?? Colors.grey.shade200),
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(item.borderRadius),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: item.listItems.length,
              separatorBuilder: (_, _) => Divider(height: 1, thickness: 1, color: dividerColor, indent: 48),
              itemBuilder: (_, index) {
                final entry = item.listItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: listIconBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.inbox_outlined, size: 15, color: listText),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry,
                          style: TextStyle(
                            color: listText,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${9 + index}:00 AM',
                        style: TextStyle(
                          color: listSubtle,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      
      // V24: New Tools UI
      case ItemType.profileImage:
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.grey[300],
            shape: BoxShape.circle,
            border: item.borderColor != null ? Border.all(color: item.borderColor!, width: 2) : null,
          ),
          child: Center(
            child: Icon(Icons.person, size: item.size.width * 0.6, color: item.iconColor ?? Colors.grey[600]),
          ),
        );
      
      case ItemType.chart:
        final chartColor = item.textColor ?? Colors.blue;
        final chartBg = item.backgroundColor ?? Colors.white;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: chartBg,
            borderRadius: BorderRadius.circular(item.borderRadius),
            border: item.borderColor != null ? Border.all(color: item.borderColor!) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Analytics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: chartColor)),
              const SizedBox(height: 8),
              Expanded(
                child: CustomPaint(
                  painter: _ChartPainter(
                    type: item.chartType,
                    color: chartColor,
                    bgColor: chartBg,
                  ),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        );
        
      case ItemType.toggle:
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.blue,
            borderRadius: BorderRadius.circular(item.size.height / 2),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: item.size.height - 8,
                height: item.size.height - 8,
                decoration: BoxDecoration(
                  color: item.borderColor ?? Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
        
      case ItemType.table:
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(item.borderRadius),
            border: Border.all(color: item.borderColor ?? Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: item.borderColor ?? Colors.grey[300]!)),
                  color: item.borderColor?.withValues(alpha: 0.1) ?? Colors.grey[100],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("ID", style: TextStyle(fontWeight: FontWeight.bold, color: item.textColor ?? Colors.black)),
                    Text("Name", style: TextStyle(fontWeight: FontWeight.bold, color: item.textColor ?? Colors.black)),
                    Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: item.textColor ?? Colors.black)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: item.borderColor ?? Colors.grey[200]!))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("#100${index+1}", style: TextStyle(color: item.textColor ?? Colors.black87)),
                          Text("User ${index+1}", style: TextStyle(color: item.textColor ?? Colors.black87)),
                          Text("Active", style: TextStyle(color: item.textColor ?? Colors.green)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
        
      case ItemType.pricingCard:
        return Card(
          elevation: 4,
          color: item.backgroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(item.borderRadius),
            side: item.borderColor != null ? BorderSide(color: item.borderColor!) : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text("Pro Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: item.textColor ?? Colors.black)),
                const SizedBox(height: 16),
                Text("\$29/mo", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: item.textColor ?? Colors.black)),
                const SizedBox(height: 24),
                ...List.generate(3, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 16, color: item.textColor?.withValues(alpha: 0.7) ?? Colors.green),
                      const SizedBox(width: 8),
                      Text("Premium Feature ${index+1}", style: TextStyle(color: item.textColor ?? Colors.black87)),
                    ],
                  ),
                )),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: item.textColor ?? Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text("Subscribe", style: TextStyle(color: item.backgroundColor ?? Colors.white, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
        );
        
      case ItemType.sidebar:
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.white,
            border: Border(right: BorderSide(color: item.borderColor ?? Colors.grey[300]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("MENU", style: TextStyle(fontWeight: FontWeight.bold, color: item.textColor?.withValues(alpha: 0.5) ?? Colors.grey)),
              ),
              ...["Dashboard", "Users", "Settings", "Reports"].map((label) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 12, color: item.textColor?.withValues(alpha: 0.5) ?? Colors.grey),
                    const SizedBox(width: 12),
                    Text(label, style: TextStyle(fontSize: 16, color: item.textColor ?? Colors.black87)),
                  ],
                ),
              )),
            ],
          ),
        );
        
      case ItemType.article:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Article Headline", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: item.textColor ?? Colors.black)
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
                  style: TextStyle(fontSize: 14, color: item.textColor?.withValues(alpha: 0.8) ?? Colors.black87, height: 1.5),
                ),
              )
            ],
          ),
        );
        
      case ItemType.gallery:
        return Container(
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(item.borderRadius),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 4,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: item.borderColor?.withValues(alpha: 0.3) ?? Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Icon(Icons.image, color: item.iconColor ?? Colors.grey)),
              );
            },
          ),
        );
    }
  }
}

class _ChartPainter extends CustomPainter {
  final ChartType type;
  final Color color;
  final Color bgColor;

  // Realistic fake data
  static const _labels  = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
  static const _rawVals = [42.0, 78.0, 55.0, 91.0, 63.0, 38.0, 85.0]; // out of 100
  static const _pieLabels  = ['Direct', 'Social', 'Search', 'Email', 'Other'];
  static const _pieSegs    = [0.31, 0.23, 0.19, 0.14, 0.13];
  static const _pieColors  = [
    Color(0xFF6C63FF), // violet
    Color(0xFF3ECFCF), // teal
    Color(0xFFFF6584), // pink-red
    Color(0xFFFFA849), // amber
    Color(0xFF4CAF7D), // green
  ];

  _ChartPainter({required this.type, required this.color, required this.bgColor});

  TextPainter _tp(String text, double size, Color c, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: c,
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp;
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case ChartType.bar:  _drawBar(canvas, size);  break;
      case ChartType.line: _drawLine(canvas, size); break;
      case ChartType.pie:  _drawPie(canvas, size);  break;
    }
  }

  void _drawBar(Canvas canvas, Size size) {
    const labelH = 14.0;
    const leftPad = 26.0;
    final chartH = size.height - labelH - 4;
    final chartW = size.width - leftPad;

    final labelColor = color.withValues(alpha: 0.45);
    final gridColor  = color.withValues(alpha: 0.08);

    // Y-axis grid lines + labels: 0, 25, 50, 75, 100
    for (final v in [0, 25, 50, 75, 100]) {
      final y = chartH - (chartH * v / 100);
      canvas.drawLine(
        Offset(leftPad, y), Offset(size.width, y),
        Paint()..color = gridColor..strokeWidth = 1,
      );
      final tp = _tp('$v', 7.5, labelColor);
      tp.paint(canvas, Offset(leftPad - tp.width - 3, y - tp.height / 2));
    }

    // Bars
    final count = _rawVals.length;
    final gap   = chartW / count;
    final barW  = gap * 0.52;
    for (int i = 0; i < count; i++) {
      final v = _rawVals[i] / 100;
      final h = chartH * v;
      final x = leftPad + gap * i + (gap - barW) / 2;
      final y = chartH - h;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.35 + v * 0.65)
        ..style  = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barW, h), const Radius.circular(3)),
        paint,
      );
      // value label on top of bar
      final vtp = _tp('${_rawVals[i].toInt()}', 7.5, color.withValues(alpha: 0.7), bold: true);
      vtp.paint(canvas, Offset(x + barW / 2 - vtp.width / 2, y - vtp.height - 1));

      // x-axis label
      final ltp = _tp(_labels[i], 8, labelColor);
      ltp.paint(canvas, Offset(x + barW / 2 - ltp.width / 2, chartH + 3));
    }
  }

  void _drawLine(Canvas canvas, Size size) {
    const labelH = 14.0;
    const leftPad = 26.0;
    final chartH = size.height - labelH - 4;
    final chartW = size.width - leftPad;

    final labelColor = color.withValues(alpha: 0.45);
    final gridColor  = color.withValues(alpha: 0.08);

    // Grid lines
    for (final v in [0, 25, 50, 75, 100]) {
      final y = chartH - (chartH * v / 100);
      canvas.drawLine(
        Offset(leftPad, y), Offset(size.width, y),
        Paint()..color = gridColor..strokeWidth = 1,
      );
      final tp = _tp('$v', 7.5, labelColor);
      tp.paint(canvas, Offset(leftPad - tp.width - 3, y - tp.height / 2));
    }

    final count = _rawVals.length;
    final pts = List.generate(count, (i) {
      final x = leftPad + (chartW / (count - 1)) * i;
      final y = chartH - chartH * (_rawVals[i] / 100);
      return Offset(x, y);
    });

    // Fill
    final fillPath = Path()..moveTo(leftPad, chartH);
    fillPath.lineTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i+1].dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i+1].dx, pts[i+1].dy);
    }
    fillPath.lineTo(size.width, chartH);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = color.withValues(alpha: 0.12)..style = PaintingStyle.fill);

    // Stroke
    final linePath = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i+1].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i+1].dx, pts[i+1].dy);
    }
    canvas.drawPath(linePath, Paint()
      ..color = color..strokeWidth = 2
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Dots + value labels
    for (int i = 0; i < pts.length; i++) {
      final pt = pts[i];
      canvas.drawCircle(pt, 3.5, Paint()..color = bgColor..style = PaintingStyle.fill);
      canvas.drawCircle(pt, 3.5, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5);

      // x-axis label
      final ltp = _tp(_labels[i], 8, labelColor);
      ltp.paint(canvas, Offset(pt.dx - ltp.width / 2, chartH + 3));
      // value above dot
      final vtp = _tp('${_rawVals[i].toInt()}', 7.5, color.withValues(alpha: 0.75), bold: true);
      vtp.paint(canvas, Offset(pt.dx - vtp.width / 2, pt.dy - vtp.height - 4));
    }
  }

  void _drawPie(Canvas canvas, Size size) {
    const legendH = 36.0;
    final pieSize = size.height - legendH;
    final cx = size.width / 2;
    final cy = pieSize / 2;
    final r  = (size.width < pieSize ? size.width : pieSize) / 2 * 0.95;

    double startAngle = -1.5708;
    for (int i = 0; i < _pieSegs.length; i++) {
      final sweep = _pieSegs[i] * 6.2832;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle, sweep, true,
        Paint()..color = _pieColors[i]..style = PaintingStyle.fill,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle, sweep, true,
        Paint()..color = bgColor..style = PaintingStyle.stroke..strokeWidth = 2,
      );

      // percentage label inside segment (only if big enough)
      if (_pieSegs[i] > 0.12) {
        final midAngle = startAngle + sweep / 2;
        final labelR = r * 0.70;
        final lx = cx + labelR * cos(midAngle);
        final ly = cy + labelR * sin(midAngle);
        final pct = '${(_pieSegs[i] * 100).round()}%';
        final tp = _tp(pct, 8.5, Colors.white, bold: true);
        tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
      }

      startAngle += sweep;
    }
    // donut hole with total label
    canvas.drawCircle(Offset(cx, cy), r * 0.40, Paint()..color = bgColor..style = PaintingStyle.fill);
    final totalTp = _tp('Total', 7, color.withValues(alpha: 0.5));
    totalTp.paint(canvas, Offset(cx - totalTp.width / 2, cy - totalTp.height - 1));
    final valTp = _tp('8.4k', 11, color, bold: true);
    valTp.paint(canvas, Offset(cx - valTp.width / 2, cy + 1));

    // Legend row at bottom
    final itemW = size.width / _pieLabels.length;
    for (int i = 0; i < _pieLabels.length; i++) {
      final lx = itemW * i + itemW / 2;
      final ly = size.height - legendH + 6;
      canvas.drawCircle(
        Offset(lx - 12, ly + 5),
        4,
        Paint()..color = _pieColors[i]..style = PaintingStyle.fill,
      );
      final ltp = _tp(_pieLabels[i], 7.5, color.withValues(alpha: 0.6));
      ltp.paint(canvas, Offset(lx - 8, ly));
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.type != type || old.color != color || old.bgColor != bgColor;
}
