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
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          css.writeln("  border: 1px solid ${_colorToCss(item.borderColor, 'transparent')};");
          break;
        case ItemType.image:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#EEEEEE')};");
          css.writeln("  border: 1px dashed ${_colorToCss(item.borderColor, '#CCCCCC')};");
          css.writeln("  justify-content: center;");
          break;
        case ItemType.button:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#000000')};");
          css.writeln("  color: ${_colorToCss(item.textColor, '#FFFFFF')};");
          css.writeln("  font-size: ${item.fontSize}px;");
          css.writeln("  font-weight: bold;");
          css.writeln("  justify-content: center;");
          css.writeln("  cursor: pointer;");
          if (item.borderColor != null) {
            css.writeln("  border: 1px solid ${_colorToCss(item.borderColor, 'transparent')};");
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
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          css.writeln("  border-bottom: 1px solid ${_colorToCss(item.borderColor, '#EEEEEE')};");
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
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#F8F8F8')};");
          css.writeln("  border: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};");
          css.writeln("  padding: 0 15px;");
          css.writeln("  color: ${_colorToCss(item.textColor, '#888888')};");
          break;
        case ItemType.input:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          css.writeln("  border: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};");
          css.writeln("  padding: 0 15px;");
          css.writeln("  color: ${_colorToCss(item.textColor, '#666666')};");
          break;
        case ItemType.checkbox:
          css.writeln("  gap: 10px;");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          break;
        case ItemType.card:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          if (item.borderColor != null) {
            css.writeln("  border: 1px solid ${_colorToCss(item.borderColor, 'transparent')};");
          }
          css.writeln("  box-shadow: 0 4px 15px rgba(0,0,0,0.08);");
          css.writeln("  justify-content: center;");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          break;
        case ItemType.dropdown:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          css.writeln("  border: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  padding: 0 10px;");
          css.writeln("  cursor: pointer;");
          break;
        case ItemType.list:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          css.writeln("  border: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          break;
        case ItemType.profileImage:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#EEEEEE')};");
          css.writeln("  border-radius: 50%;");
          if (item.borderColor != null) css.writeln("  border: 2px solid ${_colorToCss(item.borderColor, 'transparent')};");
          css.writeln("  justify-content: center;");
          break;
        case ItemType.chart:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          css.writeln("  border-radius: ${item.borderRadius}px;");
          if (item.borderColor != null) css.writeln("  border: 1px solid ${_colorToCss(item.borderColor, 'transparent')};");
          css.writeln("  padding: 16px;");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  flex-direction: column;");
          break;
        case ItemType.toggle:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#2196F3')};");
          css.writeln("  border-radius: ${item.size.height / 2}px;");
          css.writeln("  justify-content: flex-end;");
          css.writeln("  padding: 4px;");
          break;
        case ItemType.table:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          css.writeln("  border-radius: ${item.borderRadius}px;");
          css.writeln("  border: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  flex-direction: column;");
          break;
        case ItemType.pricingCard:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          css.writeln("  border-radius: ${item.borderRadius}px;");
          if (item.borderColor != null) css.writeln("  border: 1px solid ${_colorToCss(item.borderColor, 'transparent')};");
          css.writeln("  box-shadow: 0 4px 15px rgba(0,0,0,0.08);");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  padding: 24px;");
          css.writeln("  flex-direction: column;");
          css.writeln("  align-items: center;");
          break;
        case ItemType.sidebar:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          css.writeln("  border-right: 1px solid ${_colorToCss(item.borderColor, '#DDDDDD')};");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  flex-direction: column;");
          css.writeln("  align-items: flex-start;");
          break;
        case ItemType.article:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
          css.writeln("  border-radius: ${item.borderRadius}px;");
          css.writeln("  color: ${_colorToCss(item.textColor, '#000000')};");
          css.writeln("  padding: 24px;");
          css.writeln("  flex-direction: column;");
          css.writeln("  align-items: flex-start;");
          break;
        case ItemType.gallery:
          css.writeln("  background-color: ${_colorToCss(item.backgroundColor, '#FFFFFF')};");
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
          content = '<span style="color: ${_colorToCss(item.iconColor, '#FFB300')}; font-size: 1.2em;">★</span> <span>${item.textContent}</span>';
          break;
        case ItemType.search:
          content = '<span style="margin-right: 8px; color: ${_colorToCss(item.iconColor, '#888')}">🔍</span> ${item.textContent}';
          break;
        case ItemType.dropdown:
          tag = "select";
          content = item.dropdownItems.map((opt) => '<option>$opt</option>').join("");
          break;
        case ItemType.card:
          content = item.textContent;
          break;
        case ItemType.navBar:
          content = item.navItems.map((s) => '<a href="#" style="text-decoration: none; color: ${_colorToCss(item.textColor, '#000000')}; margin: 0 ${item.navSpacing/2}px; font-weight: 600; font-size: 14px;">$s</a>').join("");
          break;
        case ItemType.checkbox:
          content = '<div style="width: 18px; height: 18px; border: 2px solid ${_colorToCss(item.borderColor, '#DDDDDD')}; border-radius: 4px; background-color: ${_colorToCss(item.backgroundColor, 'transparent')};"></div> <span>${item.textContent}</span>';
          break;
        case ItemType.profileImage:
          content = '<div style="font-size: 40px; color: ${_colorToCss(item.iconColor, '#888888')}">👤</div>';
          break;
        case ItemType.chart:
          content = '<strong>Analytics</strong><div style="flex:1; display:flex; align-items:flex-end; gap:10px; margin-top:16px; width:100%"><div style="width:20%; height:40%; background:currentColor; opacity:0.3"></div><div style="width:20%; height:80%; background:currentColor; opacity:0.6"></div><div style="width:20%; height:60%; background:currentColor; opacity:0.4"></div><div style="width:20%; height:100%; background:currentColor"></div><div style="width:20%; height:50%; background:currentColor; opacity:0.3"></div></div>';
          break;
        case ItemType.toggle:
          content = '<div style="width:${item.size.height - 8}px; height:${item.size.height - 8}px; background-color:${_colorToCss(item.borderColor, '#FFFFFF')}; border-radius:50%"></div>';
          break;
        case ItemType.table:
          content = '<div style="display:flex; justify-content:space-around; width:100%; padding:12px; border-bottom:1px solid currentColor; opacity:0.8"><b>ID</b><b>Name</b><b>Status</b></div><div style="display:flex; justify-content:space-around; width:100%; padding:12px; border-bottom:1px solid currentColor; opacity:0.5"><span>#1001</span><span>User 1</span><span style="color:green">Active</span></div>';
          break;
        case ItemType.pricingCard:
          content = '<b>Pro Plan</b><br><h2 style="margin:10px 0">\\\$29/mo</h2><ul style="list-style:none; padding:0; text-align:left; width:100%"><li>✓ Premium Feature 1</li><li>✓ Premium Feature 2</li><li>✓ Premium Feature 3</li></ul><div style="margin-top:auto; width:100%; padding:12px; background:currentColor; color:${_colorToCss(item.backgroundColor, '#FFFFFF')}; text-align:center; border-radius:8px; box-sizing:border-box"><b>Subscribe</b></div>';
          break;
        case ItemType.sidebar:
          content = '<b style="padding:20px; opacity:0.5">MENU</b><div style="padding:12px 20px">Dashboard</div><div style="padding:12px 20px">Users</div><div style="padding:12px 20px">Settings</div><div style="padding:12px 20px">Reports</div>';
          break;
        case ItemType.article:
          content = '<h2 style="margin-top:0">Article Headline</h2><p style="opacity:0.8; line-height:1.5">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>';
          break;
        case ItemType.gallery:
          content = '<div style="background:${_colorToCss(item.borderColor, '#EEEEEE')}; opacity:0.3; border-radius:8px"></div><div style="background:${_colorToCss(item.borderColor, '#EEEEEE')}; opacity:0.3; border-radius:8px"></div><div style="background:${_colorToCss(item.borderColor, '#EEEEEE')}; opacity:0.3; border-radius:8px"></div><div style="background:${_colorToCss(item.borderColor, '#EEEEEE')}; opacity:0.3; border-radius:8px"></div>';
          break;
        default:
          content = item.textContent.isNotEmpty ? item.textContent : item.type.name.toUpperCase();
      }

      // Emit AI context as HTML comment if present
      if (item.aiContext.isNotEmpty) {
        html.writeln('  <!-- AI Context: ${item.aiContext} -->');
      }
      html.writeln('  <$tag id="$id" class="boxy-item">$content</$tag>');
    }

    html.writeln('</div>');
    html.writeln('</body>');
    html.writeln('</html>');

    return html.toString();
  }
}
