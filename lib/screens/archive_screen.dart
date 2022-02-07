import 'package:chemobile/components/MultiLineAppBar.dart';
import 'package:chemobile/components/archive_entry.dart';
import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/cubits/archive_cubit.dart';
import 'package:chemobile/models/eln_user.dart';
import 'package:chemobile/models/sample_task.dart';
import 'package:chemobile/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({Key? key}) : super(key: key);

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  Widget build(BuildContext context) {
    List<SampleTask> sampleTasks =
        BlocProvider.of<ArchiveCubit>(context).sampleTasksForCurrentUser(currentUser(context)!);

    return Scaffold(
      appBar: MultiLineAppBar(
        title: 'Previous Scans',
        subtitle: currentUser(context)!.fullName,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ListView.custom(
                childrenDelegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ArchiveEntry(
                      sampleTask: sampleTasks[index],
                      onTap: _handleTap,
                    );
                  },
                  childCount: sampleTasks.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElnUser? currentUser(BuildContext context) {
    return BlocProvider.of<AuthCubit>(context).state.currentElnUser;
  }

  void _handleTap(SampleTask sampleTask) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return DetailsScreen(sampleTask: sampleTask);
      }),
    );
  }
}
