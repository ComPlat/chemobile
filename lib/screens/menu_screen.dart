import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/cubits/archive_cubit.dart';
import 'package:chemobile/cubits/ocr_result_cubit.dart';
import 'package:chemobile/cubits/sample_tasks_cubit.dart';
import 'package:chemobile/models/eln_user.dart';
import 'package:chemobile/models/menu_entry.dart';
import 'package:chemobile/models/sample_task.dart';
import 'package:chemobile/screens/archive_screen.dart';
import 'package:chemobile/screens/sample_tasks_screen.dart';
import 'package:chemobile/screens/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool scanInProgress = false;
  List<MenuEntry> menuEntries() {
    return [
      MenuEntry(
        ident: 'unfinished_tasks',
        title: 'Unfinished tasks',
        icon: const Icon(Icons.monitor_weight, size: 48),
      ),
      MenuEntry(
          ident: 'finished_tasks',
          title: 'Finished tasks',
          icon: const Icon(Icons.settings_overscan, size: 48)),
      MenuEntry(
        ident: 'logout',
        title: 'Logout',
        subTitle: 'Change or create current user',
        icon: const Icon(Icons.logout, size: 48),
      ),
    ];
  }

  void _handleTap(BuildContext context, MenuEntry entry) {
    if (entry.ident == 'unfinished_tasks') {
      _openUnfinishedTasks(context);
    } else if (entry.ident == 'finished_tasks') {
      _openFinishedTasks(context);
    } else if (entry.ident == 'logout') {
      _initiateLogout(context);
    } else {
      _initiateLogout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ElnUser currentUser = _authenticator(context).state.currentElnUser!;
    BlocProvider.of<ArchiveCubit>(context).sampleTasksForCurrentUser(currentUser).length;
    List<MenuEntry> menu = menuEntries();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(currentUser.fullName),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.custom(
                childrenDelegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    MenuEntry entry = menu[index];

                    return Card(
                      child: ListTile(
                        leading: entry.icon,
                        title: Text(entry.title, textAlign: TextAlign.left),
                        subtitle: entry.subTitle == null
                            ? null
                            : Text(
                                entry.subTitle!,
                                textAlign: TextAlign.left,
                                textScaleFactor: 0.8,
                              ),
                        onTap: () => _handleTap(context, entry),
                      ),
                    );
                  },
                  childCount: menu.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget doubleScanIcon() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(Icons.science), Icon(Icons.science)],
    );
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

  void _openUnfinishedTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return const SampleTasksScreen();
      }),
    ).then((someStuffToIgnore) {
      _sampleTaskList(context).loadTasks();
    });
  }

  void _openScanScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        ScanScreen scanScreen = const ScanScreen();
        BlocProvider.of<OcrResultCubit>(context).startCamera();
        return scanScreen;
      }),
    ).then((someStuffToIgnore) {
      setState(() => scanInProgress = false);
      // if no task is selected, pop the details screen
      // this assumes we always have a details screen on the stack!
      _sampleTaskList(context).loadTasks();
    });
  }

  void _openFinishedTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return const ArchiveScreen();
      }),
    );
  }

  void _initiateLogout(BuildContext context) {
    _authenticator(context).logout();
  }

  AuthCubit _authenticator(BuildContext context) {
    return BlocProvider.of<AuthCubit>(context);
  }

  SampleTasksCubit _sampleTaskList(BuildContext context) {
    return BlocProvider.of<SampleTasksCubit>(context);
  }
}
