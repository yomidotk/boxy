import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

class Exporter {
  static Future<bool> saveCanvas(GlobalKey key) async {
    // Check permission using Gal (it handles legacy and new permissions)
    bool hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      await Gal.requestAccess();
      hasAccess = await Gal.hasAccess();
      if (!hasAccess) return false;
    }

    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        await Gal.putImageBytes(
          byteData.buffer.asUint8List(),
          name: "boxy_export_${DateTime.now().millisecondsSinceEpoch}",
        );
        debugPrint("Export success");
        return true;
      }
    } catch (e) {
      debugPrint("Error exporting image: $e");
    }
    return false;
  }
}
