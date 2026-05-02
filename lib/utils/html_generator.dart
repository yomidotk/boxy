import 'package:flutter/material.dart';
import '../models/layout_item.dart';

class HtmlGenerator {
  static String generate(List<LayoutItem> items) {
    StringBuffer html = StringBuffer();
    StringBuffer css = StringBuffer();

    // specific: Reset & Container CSS
    css.writeln("""
body {
  margin: 0;
  padding: 50px;
  background-color: #f0f2f5; /* V22: Light Blue Grey verify BG */
  font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  display: flex;
  justify-content: center;
}
.boxy-wrapper {
  background-color: white;
  width: 800px;
  height: 2000px;
  position: relative;
  box-shadow: 0 10px 40px rgba(0,0,0,0.1);
  overflow: hidden;
}
.boxy-item {
  position: absolute;
  box-sizing: border-box;
  display: flex;
  align-items: center;
  pointer-events: auto; /* Ensure events pass through if needed */
}
""");

    html.writeln('<!DOCTYPE html>');
    html.writeln('<html lang="en">');
    html.writeln('<head>');
    html.writeln('<meta charset="UTF-8">');
    html.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
    html.writeln('<title>Boxy Pro Export</title>');
    html.writeln('<style>');

    // Generate Item CSS
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      String id = "item-${item.id}";
      css.writeln("#$id {");
      
      // V22: Core Leveling
      css.writeln("  z-index: ${i + 1};");

      // Position & Size
      if (item.isFullWidth) {
        css.writeln("  left: 0;");
        css.writeln("  width: 800px;");
      } else {
        css.writeln("  left: ${item.position.dx}px;");
        css.writeln("  width: ${item.size.width}px;");
      }
      css.writeln("  top: ${item.position.dy}px;");
      css.writeln("  height: ${item.size.height}px;");

      // Rotation
      if (item.rotation != 0) {
        css.writeln("  transform: rotate(${item.rotation}deg);");
      }

      // Border Radius
      if (item.borderRadius > 0 && item.type != ItemType.text) {
        css.writeln("  border-radius: ${item.borderRadius}px;");
      }

      // Styling based on Type
      switch (item.type) {
        case ItemType.box:
          css.writeln("  background-color: #f0f0f0;");
          css.writeln("  border: 1px solid #ddd;");
          break;
        case ItemType.image:
          css.writeln("  background-color: #eeeeee;");
          css.writeln("  border: 1px dashed #ccc;");
          css.writeln("  justify-content: center;");
          break;
        case ItemType.button:
          css.writeln("  background-color: #000000;");
          css.writeln("  color: #ffffff;");
          css.writeln("  font-size: ${item.fontSize}px;");
          css.writeln("  font-weight: bold;");
          css.writeln("  justify-content: center;");
          css.writeln("  cursor: pointer;");
          css.writeln("  border: none;");
          break;
        case ItemType.text:
          css.writeln("  font-size: ${item.fontSize}px;");
          css.writeln("  color: #000000;");
          css.writeln("  justify-content: center;");
          css.writeln("  white-space: nowrap;");
          break;
        case ItemType.logo:
          css.writeln("  color: #000000;");
          css.writeln("  font-size: ${item.fontSize}px;");
          css.writeln("  font-weight: 800;");
          css.writeln("  gap: 8px;");
          break;
        case ItemType.navBar:
          css.writeln("  background-color: #ffffff;");
          css.writeln("  border-bottom: 1px solid #eee;");
          String justify = "space-around";
          switch (item.navAlignment) {
            case MainAxisAlignment.start: justify = "flex-start"; break;
            case MainAxisAlignment.end: justify = "flex-end"; break;
            case MainAxisAlignment.center: justify = "center"; break;
            case MainAxisAlignment.spaceBetween: justify = "space-between"; break;
            case MainAxisAlignment.spaceAround: justify = "space-around"; break;
            case MainAxisAlignment.spaceEvenly: justify = "space-evenly"; break;
          }
          css.writeln("  justify-content: $justify;");
          css.writeln("  padding: 0 20px;");
          break;
        case ItemType.search:
          css.writeln("  background-color: #f8f8f8;");
          css.writeln("  border: 1px solid #ddd;");
          css.writeln("  padding: 0 15px;");
          css.writeln("  color: #888;");
          break;
        case ItemType.input:
          css.writeln("  background-color: #ffffff;");
          css.writeln("  border: 1px solid #ddd;");
          css.writeln("  padding: 0 15px;");
          css.writeln("  color: #666;");
          break;
        case ItemType.checkbox:
          css.writeln("  gap: 10px;");
          break;
        case ItemType.card:
          css.writeln("  background-color: #ffffff;");
          css.writeln("  box-shadow: 0 4px 15px rgba(0,0,0,0.08);");
          css.writeln("  justify-content: center;");
          break;
        case ItemType.dropdown:
          css.writeln("  background-color: #ffffff;");
          css.writeln("  border: 1px solid #ddd;");
          css.writeln("  padding: 0 10px;");
          css.writeln("  cursor: pointer;");
          break;
        default:
          css.writeln("  border: 1px solid #eee;");
          break;
      }

      css.writeln("}");
    }

    html.writeln(css.toString());
    html.writeln('</style>');
    html.writeln('</head>');
    html.writeln('<body>');
    html.writeln('<div class="boxy-wrapper">');

    // Generate HTML Nodes
    for (var item in items) {
      String id = "item-${item.id}";
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
          content = '<span style="color: #FFB300; font-size: 1.2em;">★</span> <span>${item.textContent}</span>';
          break;
        case ItemType.search:
          content = '<span style="margin-right: 8px;">🔍</span> ${item.textContent}';
          break;
        case ItemType.dropdown:
          tag = "select";
          content = item.dropdownItems.map((opt) => '<option>$opt</option>').join("");
          break;
        case ItemType.card:
          content = item.textContent;
          break;
        case ItemType.navBar:
          content = item.navItems.map((s) => '<a href="#" style="text-decoration: none; color: black; margin: 0 ${item.navSpacing/2}px; font-weight: 600; font-size: 14px;">$s</a>').join("");
          break;
        case ItemType.checkbox:
          content = '<div style="width: 18px; height: 18px; border: 2px solid #ddd; border-radius: 4px;"></div> <span>${item.textContent}</span>';
          break;
        default:
          content = item.textContent.isNotEmpty ? item.textContent : item.type.name.toUpperCase();
      }

      html.writeln('  <$tag id="$id" class="boxy-item">$content</$tag>');
    }

    html.writeln('</div>');
    html.writeln('</body>');
    html.writeln('</html>');

    return html.toString();
  }
}
