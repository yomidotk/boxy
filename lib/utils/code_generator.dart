import '../models/layout_item.dart';

class CodeGenerator {
  static String generateHtml(List<LayoutItem> items) {
    StringBuffer buffer = StringBuffer();

    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html>');
    buffer.writeln('<head>');
    buffer.writeln('<style>');
    buffer.writeln(
      '  body { margin: 0; padding: 0; position: relative; width: 100vw; height: 100vh; }',
    );
    buffer.writeln(
      '  .component { position: absolute; box-sizing: border-box; }',
    );
    buffer.writeln('</style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');

    for (var item in items) {
      buffer.writeln(_generateItemHtml(item));
    }

    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  static String _generateItemHtml(LayoutItem item) {
    final style =
        'top: ${item.position.dy}px; left: ${item.position.dx}px; width: ${item.size.width}px; height: ${item.size.height}px;';

    switch (item.type) {
      case ItemType.box:
        return '<div id="${item.id}" class="component" style="$style background-color: #e0e0e0;"></div>';
      case ItemType.image:
        return '<img id="${item.id}" class="component" src="placeholder.jpg" style="$style object-fit: cover; background-color: #ccc;" alt="Image">';
      case ItemType.button:
        return '<button id="${item.id}" class="component" style="$style background-color: cyan; border: none; border-radius: 30px; font-weight: bold;">${item.label ?? "Click Me"}</button>';
      case ItemType.text:
        return '<div id="${item.id}" class="component" style="$style display: flex; align-items: center; justify-content: center;">${item.label ?? "Text"}</div>';
      case ItemType.card:
        return '<div id="${item.id}" class="component" style="$style background-color: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">Card Content</div>';
      case ItemType.logo:
        return '<div id="${item.id}" class="component" style="$style border: 4px solid black; display: flex; align-items: center; justify-content: center; font-weight: 900;">LOGO</div>';
      case ItemType.navBar:
        return '<nav id="${item.id}" class="component" style="$style background-color: #eceff1; display: flex; align-items: center; justify-content: space-around;"><a href="#">Home</a><a href="#">About</a><a href="#">Contact</a></nav>';
      case ItemType.dropdown:
        return '<select id="${item.id}" class="component" style="$style"><option>Select...</option></select>';
      default:
        return '<div id="${item.id}" class="component" style="$style border: 1px dashed gray;">New Item</div>';
    }
  }
}
