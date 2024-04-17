// imgLib -> Image package from https://pub.dartlang.org/packages/image
import 'dart:typed_data';

import 'package:chemobile/helpers/dev_print.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';

Future<Uint8List> convertCameraImageToPng(CameraImage image) async {
  try {
    imglib.Image img;
    if (image.format.group == ImageFormatGroup.yuv420) {
      img = _convertYUV420toImageColor(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      img = _convertBGRA8888(image);
    } else {
      img = _convertYUV420(image);
    }

    if (img.height < img.width) {
      img = imglib.copyRotate(img, angle: 90);
    }

    imglib.PngEncoder pngEncoder = imglib.PngEncoder();

    // Convert to png
    List<int> png = pngEncoder.encode(img);

    return Uint8List.fromList(png);
  } catch (e, stacktrace) {
    devPrint(">>>>>>>>>>>> ERROR:$e");
    devPrint('Stacktrace: $stacktrace');
  }
  return Uint8List.fromList([]);
}

// CameraImage BGRA8888 -> PNG
// Color
imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: image.planes[0].bytes,
    format: imglib.Format.bgra,
  );
}

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black
imglib.Image _convertYUV420(CameraImage image) {
  var img = imglib.Image(width: image.width, height: image.height); // Create Image buffer

  Plane plane = image.planes[0];
  const int shift = (0xFF << 24);

  // Fill image buffer with plane[0] from YUV420_888
  for (int x = 0; x < image.width; x++) {
    for (int planeOffset = 0;
        planeOffset < image.height * image.width;
        planeOffset += image.width) {
      final pixelColor = plane.bytes[planeOffset + x];
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      // Calculate pixel color
      var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

      img.data[planeOffset + x] = newVal;
    }
  }

  return img;
}

imglib.Image _convertYUV420toImageColor(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;
  var img = imglib.Image(width: width, height: height); // Create Image buffer
  // Fill image buffer with plane[0] from YUV420_888
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
    }
  }
  return img;
}
