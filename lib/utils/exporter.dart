import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Exporter {
  // The page is always 800px wide, centered inside the 5000px canvas stack.
  static const double _pageWidth = 800.0;
  static const double _pixelRatio = 3.0;

  static Future<bool> saveCanvas(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Capture the full canvas (5000px wide at 3× density)
      final ui.Image fullImage =
          await boundary.toImage(pixelRatio: _pixelRatio);

      // Compute the page region — horizontally centered in the full capture
      final double totalWidth = boundary.size.width;
      final double totalHeight = boundary.size.height;

      final double srcX =
          ((totalWidth - _pageWidth) / 2.0) * _pixelRatio;
      final double srcW = _pageWidth * _pixelRatio;
      final double srcH = totalHeight * _pixelRatio;

      // Draw only the page slice into a new image
      final recorder = ui.PictureRecorder();
      final cropCanvas = ui.Canvas(recorder);
      cropCanvas.drawImageRect(
        fullImage,
        Rect.fromLTWH(srcX, 0, srcW, srcH),
        Rect.fromLTWH(0, 0, srcW, srcH),
        Paint(),
      );
      final picture = recorder.endRecording();
      final ui.Image croppedImage =
          await picture.toImage(srcW.round(), srcH.round());

      final ByteData? byteData =
          await croppedImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return false;

      final Uint8List bytes = byteData.buffer.asUint8List();
      final blob = html.Blob([bytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
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
