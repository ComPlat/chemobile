import 'package:chemobile/components/sample_task_card.dart';
import 'package:chemobile/cubits/sample_tasks_cubit.dart';
import 'package:chemobile/helpers/snack_bar.dart';
import 'package:chemobile/models/exception.dart';
import 'package:chemobile/models/sample_task.dart';
import 'package:chemobile/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SampleTaskList extends StatefulWidget {
  const SampleTaskList({Key? key}) : super(key: key);

  @override
  State<SampleTaskList> createState() => _SampleTaskListState();
}

class _SampleTaskListState extends State<SampleTaskList> {
  @override
  Widget build(BuildContext context) {
    List<SampleTask> sampleTasks = _sampleTasksCubit(context).sampleTasksForCurrentUser;
    return Expanded(
      child: ListView.custom(
        childrenDelegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            SampleTask task = sampleTasks[index];

            return SampleTaskCard(
                sampleTask: task,
                onTap: () {
                  _sampleTasksCubit(context).selectTask(task);
                  _openDetailsScreen(context);
                });
          },
          childCount: sampleTasks.length,
        ),
      ),
    );
  }

  void _openDetailsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        SampleTask currentSampleTask =
            BlocProvider.of<SampleTasksCubit>(context).currentSampleTask!;
        return DetailsScreen(sampleTask: currentSampleTask);
      }),
    ).then((someStuffToIgnore) {
      reloadTasks();
    });
  }

  Future<void> reloadTasks() async {
    try {
      await _sampleTasksCubit(context).loadTasks();
    } on TaskListNotFetchableException catch (exception) {
      showSnackBar(context, exception.message);
    }
  }

  SampleTasksCubit _sampleTasksCubit(BuildContext context) {
    return BlocProvider.of<SampleTasksCubit>(context);
  }
}
