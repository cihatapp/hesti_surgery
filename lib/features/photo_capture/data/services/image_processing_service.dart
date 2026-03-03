import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageProcessingService {
  static const int maxDimension = 2048;
  static const int thumbnailSize = 256;
  static const int jpegQuality = 80;
  static const int minDimension = 1080;

  /// Validate minimum resolution
  bool validateResolution(int width, int height) {
    return width >= minDimension || height >= minDimension;
  }

  /// Process a raw photo: fix EXIF rotation, resize, compress
  Future<ProcessedImage> processPhoto(File rawFile) async {
    final bytes = await rawFile.readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) throw Exception('Failed to decode image');

    // Fix EXIF rotation
    image = img.bakeOrientation(image);

    // Resize if needed (maintain aspect ratio)
    if (image.width > maxDimension || image.height > maxDimension) {
      if (image.width > image.height) {
        image = img.copyResize(image, width: maxDimension);
      } else {
        image = img.copyResize(image, height: maxDimension);
      }
    }

    // Compress to JPEG
    final processedBytes = Uint8List.fromList(
      img.encodeJpg(image, quality: jpegQuality),
    );

    // Generate thumbnail
    final thumbnail = img.copyResize(image, width: thumbnailSize);
    final thumbnailBytes = Uint8List.fromList(
      img.encodeJpg(thumbnail, quality: 70),
    );

    // Save to temp directory
    final tempDir = await getTemporaryDirectory();
    final id = const Uuid().v4();

    final processedFile = File('${tempDir.path}/${id}_processed.jpg');
    await processedFile.writeAsBytes(processedBytes);

    final thumbnailFile = File('${tempDir.path}/${id}_thumb.jpg');
    await thumbnailFile.writeAsBytes(thumbnailBytes);

    return ProcessedImage(
      processedFile: processedFile,
      thumbnailFile: thumbnailFile,
      width: image.width,
      height: image.height,
      sizeBytes: processedBytes.length,
    );
  }
}

class ProcessedImage {
  final File processedFile;
  final File thumbnailFile;
  final int width;
  final int height;
  final int sizeBytes;

  ProcessedImage({
    required this.processedFile,
    required this.thumbnailFile,
    required this.width,
    required this.height,
    required this.sizeBytes,
  });
}
