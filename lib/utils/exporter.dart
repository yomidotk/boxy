import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Exporter {
  static Future<bool> saveCanvas(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return false;

      final bytes = byteData.buffer.asUint8List();
      final blob = html.Blob([bytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
            'download',
            'boxy_export_${DateTime.now().millisecondsSinceEpoch}.png')
        ..click();

      html.Url.revokeObjectUrl(url);
      return true;
    } catch (e) {
      debugPrint('Error exporting image: $e');
      return false;
    }
  }
}
