import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../main.dart';

class OcrCamera extends StatefulWidget {
  final Function(InputImage inputImage, CameraImage cameraImage) onImage;
  final CameraLensDirection initialLensDirection;
  final Widget overlay;

  const OcrCamera({
    Key? key,
    required this.onImage,
    required this.overlay,
    this.initialLensDirection = CameraLensDirection.back,
  }) : super(key: key);

  @override
  State<OcrCamera> createState() => _OcrCameraState();
}

class _OcrCameraState extends State<OcrCamera> {
  CameraController? _controller;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();

    _cameraIndex =
        cameras.indexWhere((camera) => camera.lensDirection == widget.initialLensDirection);
    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    return CameraPreview(_controller!, child: widget.overlay);
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    _controller?.initialize().then((_) async {
      if (!mounted) return;

      await _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);

      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    if (_controller?.value.isInitialized == true) {
      await _controller?.stopImageStream();
      await _controller?.dispose();
    }
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
        InputImageRotation.rotation0deg;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;


    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);

    widget.onImage(inputImage, image);
  }
}
