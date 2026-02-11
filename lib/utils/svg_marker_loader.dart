import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';

class SvgMarkerLoader {
  static Future<BitmapDescriptor> loadSvg(String assetName, {double size = 100}) async {
    final String svgString = await rootBundle.loadString(assetName);
    
    // Use SvgStringLoader to load the picture
    final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
    
    // Calculate scale to fit the desired size
    final double scale = size / pictureInfo.size.width;
    final int width = (pictureInfo.size.width * scale).toInt();
    final int height = (pictureInfo.size.height * scale).toInt();

    // Draw onto a canvas
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(pictureRecorder);
    
    canvas.scale(scale);
    canvas.drawPicture(pictureInfo.picture);
    
    final ui.Picture scaledPicture = pictureRecorder.endRecording();
    
    final ui.Image image = await scaledPicture.toImage(width, height);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      throw Exception('Failed to convert SVG to image data');
    }

    return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
  }

  // A cache for loaded markers to avoid re-loading the same SVG multiple times
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> getMarkerFromSvg(String assetPath, {double size = 100}) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath]!;
    }

    try {
      final marker = await loadSvg(assetPath, size: size);
      _cache[assetPath] = marker;
      return marker;
    } catch (e) {
      // Fallback or rethrow? For now let's just log and return default if possible, 
      // but here we just rethrow so the caller handles it (e.g. by using default marker).
      debugPrint('Error loading SVG marker $assetPath: $e');
      rethrow;
    }
  }
}