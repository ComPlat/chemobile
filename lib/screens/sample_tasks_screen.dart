// This screen displays a list of unfinished sample tasks

import 'package:chemobile/components/MultiLineAppBar.dart';
import 'package:chemobile/components/sample_task_list.dart';
import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/cubits/ocr_result_cubit.dart';
import 'package:chemobile/cubits/sample_tasks_cubit.dart';
import 'package:chemobile/helpers/snack_bar.dart';
import 'package:chemobile/models/exception.dart';
import 'package:chemobile/models/sample_task.dart';
import 'package:chemobile/screens/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SampleTasksScreen extends StatefulWidget {
  const SampleTasksScreen({Key? key}) : super(key: key);

  @override
  State<SampleTasksScreen> createState() => _SampleTasksScreenState();
}

class _SampleTasksScreenState extends State<SampleTasksScreen> {
  bool scanInProgress = false;
  @override
  void initState() {
    super.initState();
    initTasks();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SampleTasksCubit, SampleTasksState>(
      builder: (context, state) {
        return Scaffold(
          appBar: MultiLineAppBar(
              title: 'Unfinished sample tasks',
              subtitle: _authenticator(context).currentUser()!.fullName,
              actions: <Widget>[
                IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      initTasks();
                    })
              ]),
          body: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BlocConsumer<SampleTasksCubit, SampleTasksState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is SampleTasksAvailable || state is SampleTaskSelected) {
                      return const SampleTaskList();
                    } else if (state is SampleTasksLoading) {
                      return const Text('Loading tasks...');
                    } else {
                      return const Text('No tasks available.');
                    }
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Start single scan'),
              BottomNavigationBarItem(icon: doubleScanIcon(), label: 'Start double scan')
            ],
            onTap: (index) => _startScan(context, index),
          ),
        );
      },
    );
  }

  Widget doubleScanIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [Icon(Icons.science), Icon(Icons.science)],
    );
  }

  Future<void> initTasks() async {
    try {
      await _sampleTaskList(context).loadTasks();
    } on TaskListNotFetchableException catch (exception) {
      showSnackBar(context, exception.message);
    }
  }

  void _startScan(context, index) {
    setState(() => scanInProgress = true);
    int requiredScanResults = (index == 0 ? 1 : 2);

    // create new empty sample task
    SampleTask newSingleScan =
        SampleTask.newScan(_authenticator(context).state.currentElnUser!.uuid, requiredScanResults);
    // push into cubit
    _sampleTaskList(context).addAndSelectTask(newSingleScan);
    _openScanScreen(context);
  }

  void _openScanScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        ScanScreen scanScreen = const ScanScreen();
        BlocProvider.of<OcrResultCubit>(context).startCamera();
        return scanScreen;
      }),
    ).then((data) {
      setState(() => scanInProgress = false);
      initTasks();
    });
  }

  AuthCubit _authenticator(BuildContext context) {
    return BlocProvider.of<AuthCubit>(context);
  }

  SampleTasksCubit _sampleTaskList(BuildContext context) {
    return BlocProvider.of<SampleTasksCubit>(context);
  }
}
