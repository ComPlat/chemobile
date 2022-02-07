import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:chemobile/components/MultiLineAppBar.dart';
import 'package:chemobile/components/ocr_camera.dart';
import 'package:chemobile/components/ocr_camera_countdown_overlay.dart';
import 'package:chemobile/components/scan_data_form.dart';
import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/cubits/ocr_result_cubit.dart';
import 'package:chemobile/cubits/sample_tasks_cubit.dart';
import 'package:chemobile/helpers/image_converter.dart';
import 'package:chemobile/models/eln_user.dart';
import 'package:chemobile/models/sample_task.dart';
import 'package:chemobile/services/ocr_result_cleaner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool isBusy = false;

  @override
  void dispose() async {
    super.dispose();
    await textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OcrResultCubit, OcrResultState>(builder: (context, state) {
      return Scaffold(
        appBar: MultiLineAppBar(
          leading: BackButton(onPressed: () {
            if (state is OcrResultEmpty ||
                state is OcrResultPrepareForScanning ||
                state is OcrResultDone) {
              _stateManager(context).reset();
              Navigator.pop(context);
            }
            if (state is OcrResultAvailable) _stateManager(context).startCamera();
            if (state is OcrResultValueSelected) _stateManager(context).unselectValue();
          }),
          title: 'Chemobile Scan',
          subtitle: _subtitle(context),
        ),
        body: ListView(
          key: const Key('scanScreenListView'),
          children: <Widget>[
            BlocConsumer<OcrResultCubit, OcrResultState>(
              listener: (context, state) {
                if (state is OcrResultDone) {
                  Navigator.pop(context);
                }
              },
              builder: (context, state) {
                if (state is OcrResultInitial) return Container();
                if (state is OcrResultPrepareForScanning) return _previewCamera(state);
                if (state is OcrResultEmpty) return _ocrCamera(state);
                if (state is OcrResultAvailable) return Column(children: _valueSelector(state));
                if (state is OcrResultValueSelected) {
                  return Column(children: _valueCorrector(state));
                } else {
                  return Container();
                }
              },
            )
          ],
        ),
      );
    });
  }

  String _subtitle(context) {
    String fallback = getCurrentUser(context).fullName;
    SampleTask? currentTask = _sampleTasksCubit(context).currentSampleTask;

    if (currentTask != null && currentTask!.targetAmountValue != null) {
      return "Target amount value: ${currentTask.targetAmountValue} ${currentTask.targetAmountUnit}";
    } else {
      return fallback;
    }
  }

  Widget _previewCamera(state) {
    return OcrCamera(
      onImage: (inputImage, cameraImage) {},
      overlay: OcrCameraCountdownOverlay(onZero: () {
        _stateManager(context).startImageRecognition();
      }),
    );
  }

  Widget _ocrCamera(state) {
    return OcrCamera(
      onImage: (inputImage, cameraImage) {
        _processImage(inputImage, cameraImage);
      },
      overlay: Container(),
    );
  }

  Future<void> _processImage(InputImage inputImage, CameraImage cameraImage) async {
    if (isBusy) return;

    isBusy = true;
    List<double> resultDoubles = await _findValuesInImage(inputImage);

    if (resultDoubles.isEmpty) {
      isBusy = false;
      return;
    }

    if (await Vibrate.canVibrate) Vibrate.vibrate();

    final pngImage = await convertCameraImageToPng(cameraImage);

    Future.delayed(const Duration(seconds: 1), () => isBusy = false);

    // ignore: use_build_context_synchronously
    _stateManager(context).signalOcrResultAvailable(pngImage, resultDoubles);
  }

  Future<List<double>> _findValuesInImage(InputImage inputImage) async {
    OcrResultCleaner ocrResultCleaner = OcrResultCleaner();

    final recognisedText = await textRecognizer.processImage(inputImage);

    return ocrResultCleaner.processResult(recognisedText);
  }

  List<Widget> _valueSelector(state) {
    List<Widget> buttons = [];
    state.scannedValues.forEach((value) {
      buttons.add(OutlinedButton(
        onPressed: () {
          _stateManager(context).selectValue(value);
        },
        child: Text(value.toString()),
      ));
    });

    final displayWidth = MediaQuery.of(context).size.width;

    return [
      Image.memory(
        state.image,
        width: displayWidth,
        fit: BoxFit.fitWidth,
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
      // Add task display here when implemented
      Container(
        key: const Key('valueSelector'),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: buttons,
        ),
      ),
    ];
  }

  List<Widget> _valueCorrector(state) {
    final displayWidth = MediaQuery.of(context).size.width;
    Image image = Image.memory(
      state.image,
      width: displayWidth,
      fit: BoxFit.fitWidth,
    );

    return [
      image,
      const Padding(padding: EdgeInsets.symmetric(vertical: 8.00)),
      // Add task display here when implemented
      Container(
        key: const Key('valueCorrector'),
        margin: const EdgeInsets.all(16.0),
        child: const ScanDataForm(),
      )
    ];
  }

  SampleTasksCubit _sampleTasksCubit(context) {
    return BlocProvider.of<SampleTasksCubit>(context);
  }

  Future<ByteData> loadAsset(filePath, context) async {
    return await DefaultAssetBundle.of(context).load(filePath);
  }

  OcrResultCubit _stateManager(context) {
    return BlocProvider.of<OcrResultCubit>(context);
  }

  ElnUser getCurrentUser(context) {
    return BlocProvider.of<AuthCubit>(context).state.currentElnUser!;
  }
}
