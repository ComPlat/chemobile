// This screen represents an unfinished sample task, i.e. one where at least one scan result is missing

import 'package:chemobile/components/MultiLineAppBar.dart';
import 'package:chemobile/components/sample_task_card.dart';
import 'package:chemobile/components/scan_result_card.dart';
import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/cubits/ocr_result_cubit.dart';
import 'package:chemobile/cubits/sample_tasks_cubit.dart';
import 'package:chemobile/helpers/dev_print.dart';
import 'package:chemobile/models/eln_user.dart';
import 'package:chemobile/models/sample_task.dart';
import 'package:chemobile/screens/scan_screen.dart';
import 'package:chemobile/services/sample_task_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailsScreen extends StatefulWidget {
  final SampleTask sampleTask;
  const DetailsScreen({Key? key, required this.sampleTask}) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool scanInProgress = false;
  bool uploadInProgress = false;

  String _title() {
    return 'Scan Details';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MultiLineAppBar(
        title: _title(),
        subtitle: getCurrentUser(context).fullName,
        actions: [_deleteButton(context)],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SampleTaskCard(sampleTask: widget.sampleTask),
            ...scanResultCards(),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(widget.sampleTask.archivable() ? Icons.cloud_sync : Icons.add),
                label: Text(widget.sampleTask.archivable() ? 'Sync again' : 'Scan now'),
                onPressed: () {
                  if (widget.sampleTask.archivable()) {
                    if (uploadInProgress) {
                      return;
                    }
                    _resubmit(context);
                  } else {
                    _startScan(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> scanResultCards() {
    return widget.sampleTask.scanResults
        .map((scanResult) => ScanResultCard(scanResult: scanResult))
        .toList();
  }

  void _startScan(BuildContext context) {
    setState(() => scanInProgress = true);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        ScanScreen scanScreen = const ScanScreen();
        BlocProvider.of<OcrResultCubit>(context).startCamera();
        return scanScreen;
      }),
    ).then((data) {
      setState(() => scanInProgress = false);
      // pop DetailsScreen if SampleTask is finished
      if (BlocProvider.of<SampleTasksCubit>(context).state is! SampleTaskSelected) {
        Navigator.pop(context);
      }
    });
  }

  ElnUser getCurrentUser(context) {
    return BlocProvider.of<AuthCubit>(context).state.currentElnUser!;
  }

  void _resubmit(BuildContext context) async {
    setState(() {
      uploadInProgress = true;
    });
    ElnUser currentUser = getCurrentUser(context);
    bool result = await SampleTaskService()
        .resubmit(widget.sampleTask, currentUser.elnUrl, currentUser.token);
    if (result) {
      setState(() => uploadInProgress = false);
    } else {
      devPrint('Something bad happened while resubmitting the sample task');
    }
  }

  Widget _deleteButton(BuildContext context) {
    if (widget.sampleTask.archivable()) return Container(); // no deletion for archived tasks

    return IconButton(
      key: const Key('divideBy10'),
      icon: const Icon(Icons.delete),
      onPressed: () {
        _showAlertDialog(context);
      },
    );
  }

  void _showAlertDialog(BuildContext context) {
    Widget cancelButton =
        TextButton(child: const Text("No"), onPressed: () => Navigator.of(context).pop());
    Widget continueButton = TextButton(
      child: const Text("Yes, I'm sure!"),
      onPressed: () async {
        if (await SampleTaskService().delete(widget.sampleTask, getCurrentUser(context))) {
          if (mounted) {
            Navigator.of(context).pop(); // pops the AlertDialog
            Navigator.of(context).pop(); // Pops the DetailsScreen
          }
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Are you sure?"),
      content: const Text("Would you like to delete this sample task?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
