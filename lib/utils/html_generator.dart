import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import '../models/layout_item.dart';

class HtmlGenerator {
  static String _colorToCss(Color? color, String fallback) {
    if (color == null) return fallback;
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static String generate(List<LayoutItem> items) {
    StringBuffer html = StringBuffer();
    StringBuffer css = StringBuffer();

    css.writeln("""
*, *::before, *::after { box-sizing: border-box; }
html, body {
  margin: 0;
  padding: 0;
  width: 100%;
  overflow-x: hidden;
}
body {
  background-color: #f0f2f5;
  font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
}
.scale-container {
  transform-origin: top left;
  width: 800px;
}
.boxy-wrapper {
  width: 800px;
  height: 2000px;
  position: relative;
  background-color: transparent;
  overflow: visible;
}
.boxy-item {
  position: absolute;
  box-sizing: border-box;
  display: flex;
  align-items: center;
}

/* ── Button reset ── */
.boxy-item.boxy-button {
  padding: 0;
  cursor: pointer;
  font-family: inherit;
  width: 100%;
  height: 100%;
  border: none;
}

/* ── Input / Search ── */
.boxy-inner-input {
  width: 100%;
  height: 100%;
  border: none;
  background: transparent;
  font-family: inherit;
  font-size: 14px;
  outline: none;
  color: inherit;
}

/* ── Checkbox ── */
.boxy-checkbox-label {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  width: 100%;
  height: 100%;
  font-size: 14px;
}
.boxy-checkbox-label input[type=checkbox] {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
  cursor: pointer;
  accent-color: #8B3DFF;
}

/* ── Toggle ── */
.boxy-toggle-track {
  width: 100%;
  height: 100%;
  border-radius: inherit;
  cursor: pointer;
  display: flex;
  align-items: center;
  padding: 4px;
  transition: background 0.2s;
  user-select: none;
}
.boxy-toggle-thumb {
  height: calc(100% - 0px);
  aspect-ratio: 1;
  background: white;
  border-radius: 50%;
  transition: transform 0.2s;
  box-shadow: 0 1px 4px rgba(0,0,0,0.25);
}
.boxy-toggle-track.off { justify-content: flex-start; background: #ccc !important; }
.boxy-toggle-track.on  { justify-content: flex-end; }

/* ── Table ── */
.boxy-table {
  width: 100%;
  height: 100%;
  border-collapse: collapse;
  table-layout: fixed;
  font-size: 13px;
}
.boxy-table th, .boxy-table td {
  padding: 8px 12px;
  text-align: left;
  border-bottom: 1px solid rgba(0,0,0,0.09);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: inherit;
}
.boxy-table th { font-weight: 700; }
.boxy-table tr:last-child td { border-bottom: none; }

/* ── Pricing Card ── */
.boxy-pricing-features {
  list-style: none;
  padding: 0;
  margin: 12px 0;
  width: 100%;
  text-align: left;
  font-size: 13px;
}
.boxy-pricing-features li {
  padding: 4px 0;
  display: flex;
  align-items: center;
  gap: 8px;
}
.boxy-pricing-features li::before {
  content: '';
  display: inline-block;
  width: 16px;
  height: 16px;
  background: #22c55e;
  border-radius: 50%;
  flex-shrink: 0;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='3' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='20 6 9 17 4 12'/%3E%3C/svg%3E");
  background-size: 10px;
  background-repeat: no-repeat;
  background-position: center;
}
.boxy-pricing-btn {
  margin-top: auto;
  width: 100%;
  padding: 12px;
  text-align: center;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
  border: none;
  font-family: inherit;
  font-size: 14px;
}
""");

    html.writeln(
      '<!-- AI INSTRUCTIONS: Abandon the 800px fixed width/height and the whole .boxy-wrapper rules. Convert all absolute pixel coordinates into a fully responsive modern Flexbox/Grid layout that spans 100% of the viewport. -->',
    );
    html.writeln(
      '<!-- AI INSTRUCTIONS: Remove the .boxy-wrapper div entirely in your final code. Apply the responsive layout directly to the semantic HTML structure (like <body> or <main>). -->',
    );
    html.writeln('<!DOCTYPE html>');
    html.writeln('<html lang="en">');
    html.writeln('<head>');
    html.writeln('<meta charset="UTF-8">');
    html.writeln(
      '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
    );
    html.writeln('<title>Boxy Pro Export</title>');
    html.writeln('<style>');

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final String id = "item-${item.id}";
      css.writeln("#$id {");
      css.writeln("  z-index: ${i + 1};");

      if (item.isFullWidth) {
        css.writeln("  left: 0px;");
        css.writeln("  width: 800px;");
      } else {
        css.writeln("  left: ${item.position.dx.toStringAsFixed(1)}px;");
        css.writeln("  width: ${item.size.width.toStringAsFixed(1)}px;");
      }
      css.writeln("  top: ${item.position.dy.toStringAsFixed(1)}px;");
      css.writeln("  height: ${item.size.height.toStringAsFixed(1)}px;");

      if (item.rotation != 0) {
        css.writeln("  transform: rotate(${item.rotation}deg);");
      }
      if (item.borderRadius > 0 && item.type != ItemType.text) {
        css.writeln("  border-radius: ${item.borderRadius}px;");
      }

      switch (item.type) {
        case ItemType.box:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln(
            "  border: 1px solid ${_colorToCss(item.borderColor, 'transparent')};",
          );
          break;
        case ItemType.image:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#EEEEEE')};",
          );
          css.writeln(
            "  border: 1px dashed ${_colorToCss(item.borderColor, '#CCCCCC')};",
          );
          css.writeln("  justify-content: center;");
          break;
        case ItemType.button:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#000000')};",
          );
          css.writeln("  color: ${_colorToCss(item.textColor, '#FFFFFF')};");
          css.writeln("  font-size: ${item.fontSize}px;");
          css.writeln("  font-weight: bold;");
          css.writeln("  justify-content: center;");
          css.writeln("  cursor: pointer;");
          if (item.borderColor != null) {
            css.writeln(
              "  border: 1px solid ${_colorToCss(item.borderColor, 'transparent')};",
            );
          } else {
            css.writeln("  border: none;");
          }
          break;
        case ItemType.text:
          css.writeln("  font-size: ${item.fontSize}px;");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  justify-content: center;");
          css.writeln("  white-space: nowrap;");
          break;
        case ItemType.logo:
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  font-size: ${item.fontSize}px;");
          css.writeln("  font-weight: 800;");
          css.writeln("  gap: 8px;");
          break;
        case ItemType.navBar:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln(
            "  border-bottom: 1px solid ${_colorToCss(item.borderColor, '#EEEEEE')};",
          );
          String justify = "space-around";
          switch (item.navAlignment) {
            case MainAxisAlignment.start:
              justify = "flex-start";
              break;
            case MainAxisAlignment.end:
              justify = "flex-end";
              break;
            case MainAxisAlignment.center:
              justify = "center";
              break;
            case MainAxisAlignment.spaceBetween:
              justify = "space-between";
              break;
            case MainAxisAlignment.spaceAround:
              justify = "space-around";
              break;
            case MainAxisAlignment.spaceEvenly:
              justify = "space-evenly";
              break;
          }
          css.writeln("  justify-content: $justify;");
          css.writeln("  padding: 0 20px;");
          break;
        case ItemType.search:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#F8F8F8')};",
          );
          css.writeln(
            "  border: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};",
          );
          css.writeln("  color: ${_colorToCss(item.textColor, '#888888')};");
          css.writeln("  padding: 0 8px 0 12px;");
          css.writeln("  gap: 6px;");
          break;
        case ItemType.input:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln(
            "  border: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};",
          );
          css.writeln("  color: ${_colorToCss(item.textColor, '#666666')};");
          css.writeln("  padding: 0 15px;");
          break;
        case ItemType.checkbox:
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          break;
        case ItemType.card:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          if (item.borderColor != null) {
            css.writeln(
              "  border: 1px solid ${_colorToCss(item.borderColor, 'transparent')};",
            );
          }
          css.writeln("  box-shadow: 0 4px 15px rgba(0,0,0,0.08);");
          css.writeln("  justify-content: center;");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          break;
        case ItemType.dropdown:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln(
            "  border: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};",
          );
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  padding: 0 10px;");
          css.writeln("  cursor: pointer;");
          break;
        case ItemType.list:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln(
            "  border: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};",
          );
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  flex-direction: column;");
          css.writeln("  align-items: stretch;");
          css.writeln("  justify-content: flex-start;");
          css.writeln("  overflow: hidden;");
          css.writeln("  padding: 4px 0;");
          break;
        case ItemType.profileImage:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#EEEEEE')};",
          );
          css.writeln("  border-radius: 50%;");
          if (item.borderColor != null)
            css.writeln(
              "  border: 2px solid ${_colorToCss(item.borderColor, 'transparent')};",
            );
          css.writeln("  justify-content: center;");
          break;
        case ItemType.chart:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln("  border-radius: ${item.borderRadius}px;");
          if (item.borderColor != null)
            css.writeln(
              "  border: 1px solid ${_colorToCss(item.borderColor, 'transparent')};",
            );
          css.writeln("  padding: 16px;");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  flex-direction: column;");
          break;
        case ItemType.toggle:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#2196F3')};",
          );
          css.writeln("  border-radius: ${item.size.height / 2}px;");
          css.writeln("  padding: 0;");
          break;
        case ItemType.table:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln("  border-radius: ${item.borderRadius}px;");
          css.writeln(
            "  border: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};",
          );
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  overflow: hidden;");
          css.writeln("  display: block;");
          css.writeln("  padding: 0;");
          break;
        case ItemType.pricingCard:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln("  border-radius: ${item.borderRadius}px;");
          if (item.borderColor != null)
            css.writeln(
              "  border: 1px solid ${_colorToCss(item.borderColor, 'transparent')};",
            );
          css.writeln("  box-shadow: 0 4px 15px rgba(0,0,0,0.08);");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  padding: 20px;");
          css.writeln("  flex-direction: column;");
          css.writeln("  align-items: center;");
          css.writeln("  overflow: hidden;");
          break;
        case ItemType.sidebar:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln(
            "  border-right: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};",
          );
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  flex-direction: column;");
          css.writeln("  align-items: flex-start;");
          break;
        case ItemType.article:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln("  border-radius: ${item.borderRadius}px;");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  padding: 24px;");
          css.writeln("  flex-direction: column;");
          css.writeln("  align-items: flex-start;");
          break;
        case ItemType.gallery:
          css.writeln(
            "  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};",
          );
          css.writeln("  border-radius: ${item.borderRadius}px;");
          css.writeln("  display: grid !important;");
          css.writeln("  grid-template-columns: 1fr 1fr;");
          css.writeln("  gap: 8px;");
          css.writeln("  padding: 8px;");
          break;
      }

      css.writeln("}");
    }

    html.writeln(css.toString());
    html.writeln('</style>');
    html.writeln('</head>');
    html.writeln('<body>');
    html.writeln('<div class="scale-container">');
    html.writeln('<div class="boxy-wrapper">');

    for (var item in items) {
      final String id = "item-${item.id}";
      String content = "";
      String tag = "div";

      switch (item.type) {
        case ItemType.text:
          content = item.textContent;
          break;

        case ItemType.button:
          tag = "button";
          content = item.textContent;
          break;

        case ItemType.logo:
          content =
              '<span style="color:${_colorToCss(item.iconColor, '#FFB300')};font-size:1.2em;">★</span>'
              '<span>${item.textContent}</span>';
          break;

        case ItemType.input:
          content =
              '<input type="text" class="boxy-inner-input" placeholder="${item.textContent}" '
              'style="font-size:${item.fontSize}px;">';
          break;

        case ItemType.search:
          final iconColor = _colorToCss(item.iconColor, '#888888');
          final textColor = _colorToCss(item.textColor, '#888888');
          content =
              '<input type="search" class="boxy-inner-input" placeholder="${item.textContent}" '
              'style="font-size:14px;color:$textColor;">'
              '<button onclick="this.previousElementSibling.focus()" style="background:none;border:none;cursor:pointer;padding:4px;display:flex;align-items:center;">'
              '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="$iconColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">'
              '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>'
              '</svg>'
              '</button>';
          break;

        case ItemType.dropdown:
          tag = "select";
          content = item.dropdownItems
              .map((opt) => '<option>$opt</option>')
              .join("");
          break;

        case ItemType.box:
          content = '';
          break;

        case ItemType.image:
          final imgIcon = _colorToCss(item.borderColor, '#AAAAAA');
          content =
              '<svg xmlns="http://www.w3.org/2000/svg" width="40%" height="40%" viewBox="0 0 24 24" '
              'fill="none" stroke="$imgIcon" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">'
              '<rect x="3" y="3" width="18" height="18" rx="2"/>'
              '<circle cx="8.5" cy="8.5" r="1.5"/>'
              '<polyline points="21 15 16 10 5 21"/>'
              '</svg>';
          break;

        case ItemType.card:
          final cardLabel = item.textContent.isNotEmpty ? item.textContent : 'Card';
          content =
              '<span style="font-size:${item.fontSize}px;'
              'color:${_colorToCss(item.textColor, "#000000")};'
              'font-weight:600;opacity:0.5;">$cardLabel</span>';
          break;

        case ItemType.navBar:
          content = item.navItems
              .map(
                (s) =>
                    '<a href="#" style="text-decoration:none;color:${_colorToCss(item.textColor, '#000000')};'
                    'margin:0 ${item.navSpacing / 2}px;font-weight:600;font-size:14px;">$s</a>',
              )
              .join("");
          break;

        case ItemType.checkbox:
          content =
              '<label class="boxy-checkbox-label">'
              '<input type="checkbox" style="accent-color:${_colorToCss(item.textColor, '#8B3DFF')};">'
              '<span style="font-size:${item.fontSize}px;">${item.textContent}</span>'
              '</label>';
          break;

        case ItemType.toggle:
          final trackColor = _colorToCss(item.backgroundColor, '#2196F3');
          final uid = 'tgl_${item.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
          content =
              '<div class="boxy-toggle-track on" id="$uid" '
              'style="background:$trackColor;" '
              'onclick="this.classList.toggle(\'on\'); this.classList.toggle(\'off\');">'
              '<div class="boxy-toggle-thumb"></div>'
              '</div>';
          break;

        case ItemType.profileImage:
          final pfpColor = _colorToCss(item.iconColor, '#9E9E9E');
          content =
              '<svg viewBox="0 0 24 24" width="60%" height="60%" fill="$pfpColor" xmlns="http://www.w3.org/2000/svg">'
              '<path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4z"/>'
              '<path d="M12 14c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>'
              '</svg>';
          break;

        case ItemType.chart:
          final cHex = _colorToCss(item.textColor, '#4F6EF7');
          final chartW = item.size.width - 32;
          final chartH = (item.size.height - 52).clamp(40.0, 9999.0);
          switch (item.chartType) {
            case ChartType.bar:
              final vals = [0.40, 0.80, 0.55, 1.0, 0.65, 0.30, 0.90];
              final bw = (chartW / vals.length * 0.55).toStringAsFixed(1);
              final gap = chartW / vals.length;
              final bars = vals
                  .asMap()
                  .entries
                  .map((e) {
                    final bh = (chartH * e.value).toStringAsFixed(1);
                    final bx = (gap * e.key + (gap - double.parse(bw)) / 2)
                        .toStringAsFixed(1);
                    final by = (chartH - double.parse(bh)).toStringAsFixed(1);
                    final opacity = (0.3 + e.value * 0.7).toStringAsFixed(2);
                    return '<rect x="$bx" y="$by" width="$bw" height="$bh" rx="3" fill="$cHex" opacity="$opacity"/>';
                  })
                  .join('');
              content =
                  '<strong style="font-size:12px;">Analytics</strong>'
                  '<svg width="${chartW.toStringAsFixed(0)}" height="${chartH.toStringAsFixed(0)}" xmlns="http://www.w3.org/2000/svg" style="margin-top:8px;display:block;">$bars</svg>';
              break;
            case ChartType.line:
              final vals2 = [0.42, 0.78, 0.55, 0.91, 0.63, 0.38, 0.85];
              final pts2 = List.generate(
                vals2.length,
                (i) => Offset(
                  chartW / (vals2.length - 1) * i,
                  chartH - chartH * vals2[i],
                ),
              );
              // Build cubic bezier path (same algorithm as Flutter canvas)
              String curvePath =
                  'M ${pts2[0].dx.toStringAsFixed(1)},${pts2[0].dy.toStringAsFixed(1)}';
              for (int i = 0; i < pts2.length - 1; i++) {
                final midX = (pts2[i].dx + pts2[i + 1].dx) / 2;
                curvePath +=
                    ' C ${midX.toStringAsFixed(1)},${pts2[i].dy.toStringAsFixed(1)}'
                    ' ${midX.toStringAsFixed(1)},${pts2[i + 1].dy.toStringAsFixed(1)}'
                    ' ${pts2[i + 1].dx.toStringAsFixed(1)},${pts2[i + 1].dy.toStringAsFixed(1)}';
              }
              final fillPath2 =
                  'M 0,${chartH.toStringAsFixed(1)} L ${pts2[0].dx.toStringAsFixed(1)},${pts2[0].dy.toStringAsFixed(1)}' +
                  curvePath.substring(curvePath.indexOf(' ')) +
                  ' L ${chartW.toStringAsFixed(1)},${chartH.toStringAsFixed(1)} Z';
              final bgHex2 = _colorToCss(item.backgroundColor, '#fff');
              content =
                  '<strong style="font-size:12px;">Analytics</strong>'
                  '<svg width="${chartW.toStringAsFixed(0)}" height="${chartH.toStringAsFixed(0)}" xmlns="http://www.w3.org/2000/svg" style="margin-top:8px;display:block;">'
                  '<path d="$fillPath2" fill="$cHex" opacity="0.12"/>'
                  '<path d="$curvePath" fill="none" stroke="$cHex" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
                  '${pts2.map((p) => '<circle cx="${p.dx.toStringAsFixed(1)}" cy="${p.dy.toStringAsFixed(1)}" r="3.5" fill="$bgHex2" stroke="$cHex" stroke-width="1.5"/>').join()}'
                  '</svg>';
              break;
            case ChartType.pie:
              final segs = [0.30, 0.22, 0.18, 0.15, 0.15];
              final cx2 = chartW / 2;
              final cy2 = chartH / 2;
              final r2 = (chartW < chartH ? chartW : chartH) / 2 * 0.95;
              final r2i = r2 * 0.40;
              const pieColors = [
                '#6C63FF',
                '#3ECFCF',
                '#FF6584',
                '#FFA849',
                '#4CAF7D',
              ];
              final bgHex = _colorToCss(item.backgroundColor, '#fff');
              String arcs = '';
              double angle = -1.5708;
              for (int si = 0; si < segs.length; si++) {
                final sweep = segs[si] * 6.2832;
                final x1 = cx2 + r2 * cos(angle);
                final y1 = cy2 + r2 * sin(angle);
                final x2 = cx2 + r2 * cos(angle + sweep);
                final y2 = cy2 + r2 * sin(angle + sweep);
                final largeArc = sweep > 3.1416 ? 1 : 0;
                arcs +=
                    '<path d="M $cx2 $cy2 L ${x1.toStringAsFixed(2)} ${y1.toStringAsFixed(2)} A $r2 $r2 0 $largeArc 1 ${x2.toStringAsFixed(2)} ${y2.toStringAsFixed(2)} Z" '
                    'fill="${pieColors[si]}" stroke="$bgHex" stroke-width="2"/>';
                // pct label inside segment if large enough
                if (segs[si] > 0.12) {
                  final mid = angle + sweep / 2;
                  final lr = r2 * 0.70;
                  final lx2 = cx2 + lr * cos(mid);
                  final ly2 = cy2 + lr * sin(mid);
                  final pct = '${(segs[si] * 100).round()}%';
                  arcs +=
                      '<text x="${lx2.toStringAsFixed(1)}" y="${ly2.toStringAsFixed(1)}" text-anchor="middle" dominant-baseline="central" '
                      'font-size="9" font-weight="bold" fill="white" font-family="sans-serif">$pct</text>';
                }
                angle += sweep;
              }
              arcs += '<circle cx="$cx2" cy="$cy2" r="$r2i" fill="$bgHex"/>';
              arcs +=
                  '<text x="$cx2" y="${(cy2 - 6).toStringAsFixed(1)}" text-anchor="middle" font-size="7" fill="$cHex" opacity="0.5" font-family="sans-serif">Total</text>';
              arcs +=
                  '<text x="$cx2" y="${(cy2 + 7).toStringAsFixed(1)}" text-anchor="middle" font-size="11" font-weight="bold" fill="$cHex" font-family="sans-serif">8.4k</text>';
              content =
                  '<strong style="font-size:12px;">Analytics</strong>'
                  '<svg width="${chartW.toStringAsFixed(0)}" height="${chartH.toStringAsFixed(0)}" xmlns="http://www.w3.org/2000/svg" style="margin-top:8px;display:block;">$arcs</svg>';
              break;
          }
          break;

        case ItemType.table:
          tag = "div";
          content =
              '<table class="boxy-table">'
              '<thead><tr>'
              '<th>ID</th><th>Name</th><th>Status</th>'
              '</tr></thead>'
              '<tbody>'
              '<tr><td>#1001</td><td>User 1</td><td style="color:#22c55e;font-weight:600;">Active</td></tr>'
              '<tr><td>#1002</td><td>User 2</td><td style="color:#22c55e;font-weight:600;">Active</td></tr>'
              '<tr><td>#1003</td><td>User 3</td><td style="color:#f59e0b;font-weight:600;">Pending</td></tr>'
              '</tbody>'
              '</table>';
          break;

        case ItemType.pricingCard:
          final btnBg = _colorToCss(item.textColor, '#000000');
          final btnText = _colorToCss(item.backgroundColor, '#FFFFFF');
          content =
              '<b style="font-size:15px;">Pro Plan</b>'
              '<div style="font-size:28px;font-weight:800;margin:8px 0;">\$29<span style="font-size:14px;font-weight:400;">/mo</span></div>'
              '<ul class="boxy-pricing-features">'
              '<li>Unlimited Projects</li>'
              '<li>Priority Support</li>'
              '<li>Advanced Analytics</li>'
              '</ul>'
              '<button class="boxy-pricing-btn" style="background:$btnBg;color:$btnText;">Subscribe</button>';
          break;

        case ItemType.sidebar:
          content =
              '<b style="padding:20px;opacity:0.5;font-size:11px;letter-spacing:1px;">MENU</b>'
              '<div style="padding:12px 20px;">Dashboard</div>'
              '<div style="padding:12px 20px;">Users</div>'
              '<div style="padding:12px 20px;">Settings</div>'
              '<div style="padding:12px 20px;">Reports</div>';
          break;

        case ItemType.article:
          content =
              '<h2 style="margin-top:0;">Article Headline</h2>'
              '<p style="opacity:0.8;line-height:1.6;">Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>';
          break;

        case ItemType.gallery:
          final gBg = _colorToCss(item.borderColor, '#DDDDDD');
          content =
              '<div style="background:$gBg;opacity:0.3;border-radius:8px;"></div>'
              '<div style="background:$gBg;opacity:0.3;border-radius:8px;"></div>'
              '<div style="background:$gBg;opacity:0.3;border-radius:8px;"></div>'
              '<div style="background:$gBg;opacity:0.3;border-radius:8px;"></div>';
          break;

        case ItemType.list:
          final textHex = _colorToCss(item.textColor, '#000000');
          final rows = item.listItems
              .asMap()
              .entries
              .map((e) {
                final hour = 9 + e.key;
                final timeLabel = '$hour:00 AM';
                final isLast = e.key == item.listItems.length - 1;
                final divider = isLast
                    ? ''
                    : '<div style="height:1px;background:rgba(0,0,0,0.07);margin-left:48px;"></div>';
                return '<div style="display:flex;align-items:center;padding:7px 10px;gap:10px;">'
                    '<div style="width:28px;height:28px;flex-shrink:0;background:rgba(0,0,0,0.06);border-radius:6px;display:flex;align-items:center;justify-content:center;">'
                    '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="$textHex" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 16 12 14 15 10 15 8 12 2 12"/><path d="M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z"/></svg>'
                    '</div>'
                    '<span style="flex:1;font-weight:700;font-size:13px;color:$textHex;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${e.value}</span>'
                    '<span style="font-size:10px;color:$textHex;opacity:0.45;flex-shrink:0;">$timeLabel</span>'
                    '</div>$divider';
              })
              .join('');
          content = rows;
          break;

        default:
          content = item.textContent.isNotEmpty
              ? item.textContent
              : item.type.name.toUpperCase();
      }

      if (item.aiContext.isNotEmpty) {
        html.writeln('  <!-- AI Context: ${item.aiContext} -->');
      }

      html.writeln('  <$tag id="$id" class="boxy-item">$content</$tag>');
    }

    html.writeln('</div>');
    html.writeln('</div>');
    html.writeln('<script>');
    html.writeln('function applyScale(){');
    html.writeln('  var s=window.innerWidth/800;');
    html.writeln('  var c=document.querySelector(".scale-container");');
    html.writeln('  if(c){c.style.transform="scale("+s+")";document.body.style.height=(2000*s)+"px";}');
    html.writeln('}');
    html.writeln('applyScale();');
    html.writeln('window.addEventListener("resize",applyScale);');
    html.writeln('</script>');
    html.writeln('</body>');
    html.writeln('</html>');

    return html.toString();
  }
}
