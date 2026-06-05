import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  static const Set<String> _compressible = {
    'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif',
  };

  static bool isCompressible(String path) {
    final ext = path.split('.').last.toLowerCase();
    return _compressible.contains(ext);
  }

  /// Compress image bytes to max 1024px on longest side at 80% quality.
  /// Returns compressed bytes if smaller than original, otherwise returns original.
  static Future<Uint8List> compressBytes(Uint8List bytes) async {
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 1024,
      minHeight: 1024,
      quality: 80,
    );
    return compressed.length < bytes.length ? compressed : bytes;
  }
}
