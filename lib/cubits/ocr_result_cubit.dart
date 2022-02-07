import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

class OcrResultCubit extends Cubit<OcrResultState> {
  OcrResultCubit() : super(OcrResultInitial());

  // TODO: hier noch WeightedSampleTask als optionalen Parameter einbringen um die Unit zu übernehmen
  void startCamera() {
    emit(OcrResultPrepareForScanning());
  }

  void startImageRecognition() {
    emit(OcrResultEmpty());
  }

  void reset() {
    emit(OcrResultInitial());
  }

  void done() {
    emit(OcrResultDone());
  }

  void signalOcrResultAvailable(Uint8List? image, List<double>? values) {
    List<double> scannedValues = values ?? [];
    if (scannedValues.isEmpty) {
      return;
    } else if (scannedValues.length == 1) {
      emit(OcrResultValueSelected(
          scannedValues: values, image: image, selectedValue: scannedValues[0]));
    } else {
      emit(OcrResultAvailable(scannedValues: values, image: image));
    }
  }

  void selectValue(double? selectedValue) {
    emit(OcrResultValueSelected(
        scannedValues: state.scannedValues, image: state.image, selectedValue: selectedValue));
  }

  void unselectValue() {
    emit(OcrResultAvailable(scannedValues: state.scannedValues, image: state.image));
  }
}

class OcrResultState {
  final List<double>? scannedValues;
  final Uint8List? image;
  final double? selectedValue;

  OcrResultState({this.scannedValues, this.image, this.selectedValue});
}

class OcrResultInitial extends OcrResultState {
  OcrResultInitial() : super(scannedValues: [], image: null, selectedValue: null);
}

class OcrResultDone extends OcrResultState {
  OcrResultDone() : super(scannedValues: [], image: null, selectedValue: null);
}

class OcrResultPrepareForScanning extends OcrResultState {
  OcrResultPrepareForScanning() : super(scannedValues: [], image: null, selectedValue: null);
}

class OcrResultEmpty extends OcrResultState {
  OcrResultEmpty() : super(scannedValues: [], image: null, selectedValue: null);
}

class OcrResultAvailable extends OcrResultState {
  OcrResultAvailable(
      {required List<double>? scannedValues, required Uint8List? image, String? selectedUnit})
      : super(scannedValues: scannedValues, image: image);
}

class OcrResultValueSelected extends OcrResultState {
  OcrResultValueSelected({
    required scannedValues,
    required image,
    required selectedValue,
  }) : super(
          scannedValues: scannedValues,
          image: image,
          selectedValue: selectedValue,
        );
}
