import 'package:chemobile/components/unit_switcher.dart';
import 'package:chemobile/components/sample_task_card.dart';
import 'package:chemobile/cubits/archive_cubit.dart';
import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/cubits/ocr_result_cubit.dart';
import 'package:chemobile/cubits/sample_tasks_cubit.dart';
import 'package:chemobile/helpers/snack_bar.dart';
import 'package:chemobile/models/exception.dart';
import 'package:chemobile/services/sample_task_service.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScanDataForm extends StatefulWidget {
  const ScanDataForm({Key? key}) : super(key: key);

  @override
  State<ScanDataForm> createState() => _ScanDataFormState();
}

class _ScanDataFormState extends State<ScanDataForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _correctedValueController = TextEditingController();
  bool _sendingToELN = false;
  String _selectedUnit = 'g';

  String? _validateCorrectedValue(String? value) {
    String? numberFormatCheck = _properNumber(value);
    return (value == null || value.isEmpty || numberFormatCheck != null)
        ? 'Please make sure this is a proper number'
        : null;
  }

  String? _properNumber(String? value) {
    if (value == null) return null;

    final double? number = double.tryParse(value);
    if (number == null) return '$number is not a valid number';

    return null;
  }

  @override
  void dispose() {
    _correctedValueController.dispose();
    super.dispose();
  }

  bool _formValid() {
    return _formKey.currentState!.validate();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(border: const OutlineInputBorder(), labelText: label);
  }

  OcrResultCubit _ocrResultCubit() {
    return BlocProvider.of<OcrResultCubit>(context);
  }

  SampleTasksCubit _sampleTasksCubit() {
    return BlocProvider.of<SampleTasksCubit>(context);
  }

  OcrResultState _ocrResultState() {
    return _ocrResultCubit().state;
  }

  @override
  Widget build(BuildContext context) {
    _correctedValueController.value =
        TextEditingValue(text: _ocrResultState().selectedValue.toString());
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _valueCorrector(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
          if (_sampleTasksCubit().currentSampleTask != null)
            SampleTaskCard(sampleTask: _sampleTasksCubit().currentSampleTask!),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                OutlinedButton(
                    key: const Key('submitScan'),
                    onPressed: () async {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      if (_formValid() && !_sendingToELN) {
                        setState(() {
                          _sendingToELN = true;
                        });
                        _addToArchiveAndSendToEln(context);
                      }
                    },
                    child: !_sendingToELN
                        ? const Text('Save and send to ELN')
                        : Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.blue,
                              strokeWidth: 3,
                            ),
                          )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToArchiveAndSendToEln(BuildContext context) async {
    try {
      await SampleTaskService().addScanResultToCurrentSampleTask(
        value: _correctedValueController.text,
        unit: _selectedUnit,
        imageData: _ocrResultState().image!,
        archive: BlocProvider.of<ArchiveCubit>(context),
        sampleTaskList: _sampleTasksCubit(),
        currentUser: BlocProvider.of<AuthCubit>(context).state.currentElnUser!,
      );
      setState(() {
        _sendingToELN = false;
      });
      _ocrResultCubit().done();
    } on ChemobileException catch (exception) {
      showSnackBar(context, exception.message);
      setState(() {
        _sendingToELN = false;
      });
    }
  }

  Widget _valueCorrector() {
    return Row(
      children: <Widget>[
        IconButton(
          key: const Key('divideBy10'),
          icon: const Icon(Icons.chevron_left),
          onPressed: _divideBy10,
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
        Expanded(
          child: TextFormField(
            key: const Key('valueInput'),
            controller: _correctedValueController,
            decoration: _inputDecoration('Edit to correct'),
            keyboardType: TextInputType.number,
            validator: _validateCorrectedValue,
          ),
        ),
        IconButton(
          key: const Key('multiplyBy10'),
          icon: const Icon(Icons.chevron_right),
          onPressed: _multiplyBy10,
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
        UnitSwitcher(onUnitChange: (String unit) => _selectedUnit = unit),
      ],
    );
  }

  void _divideBy10() {
    Decimal currentValue = Decimal.parse(_correctedValueController.text);
    Decimal newValue = currentValue * Decimal.parse("0.1");
    _correctedValueController.text = newValue.toString();
  }

  void _multiplyBy10() {
    Decimal currentValue = Decimal.parse(_correctedValueController.text);
    Decimal newValue = currentValue * Decimal.fromInt(10);
    _correctedValueController.text = newValue.toString();
  }
}
