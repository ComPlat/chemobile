import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/models/eln_user.dart';
import 'package:chemobile/models/exception.dart';
import 'package:chemobile/models/sample_task.dart';
import 'package:chemobile/services/sample_task_list_merger.dart';
import 'package:chemobile/services/sample_task_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SampleTasksCubit extends HydratedCubit<SampleTasksState> {
  final AuthCubit authCubit;
  SampleTasksCubit(this.authCubit) : super(SampleTasksEmpty(sampleTasks: {}));

  ElnUser _currentUser() {
    ElnUser? currentUser = authCubit.currentUser();
    if (currentUser == null) {
      throw CurrentUserNotFoundException();
    }

    return currentUser;
  }

  Future<void> loadTasks() async {
    emit(SampleTasksLoading(
        currentSampleTask: state.currentSampleTask, sampleTasks: state.sampleTasks));
    ElnUser currentUser = _currentUser();

    List<SampleTask> myTasks = await SampleTaskService().getTasks(currentUser);

    List<SampleTask> updatedTaskList =
        SampleTaskListMerger().merge(deviceTasks: sampleTasksForCurrentUser, elnTasks: myTasks);
    updatedTaskList.sort((a, b) => b.id!.compareTo(a.id!));

    Map<String, List<SampleTask>> sampleTasks = state.sampleTasks;
    sampleTasks[currentUser.uuid] = updatedTaskList;

    if (updatedTaskList.isNotEmpty) {
      emit(SampleTasksAvailable(sampleTasks: sampleTasks));
    } else {
      emit(SampleTasksEmpty(sampleTasks: sampleTasks));
    }
  }

  Future<void> addAndSelectTask(SampleTask task) async {
    ElnUser currentUser = _currentUser();
    // show spinner to clarify that the new sample task will be directly saved to the ELN
    emit(SampleTasksSaving(
      currentSampleTask: state.currentSampleTask,
      sampleTasks: state.sampleTasks,
    ));

    // send to ELN and update sample task with returned ID
    SampleTask taskWithId =
        await SampleTaskService().create(task, currentUser.elnUrl, currentUser.token);
    Map<String, List<SampleTask>> sampleTasks = state.sampleTasks;
    if (!sampleTasks.containsKey(currentUser.uuid)) {
      sampleTasks[currentUser.uuid] = [];
    }
    sampleTasks[currentUser.uuid]!.insert(0, taskWithId);

    // then "save" sample task within cubit
    emit(SampleTaskSelected(selectedSampleTask: taskWithId, sampleTasks: sampleTasks));
  }

  void selectTask(SampleTask task) {
    emit(SampleTaskSelected(
      selectedSampleTask: task,
      sampleTasks: state.sampleTasks,
    ));
  }

  void updateCurrentSampleTask(SampleTask updatedTask) {
    String uuid = _currentUser().uuid;
    int index =
        state.sampleTasks[uuid]!.indexWhere((sampleTask) => sampleTask.id == updatedTask.id);
    if (index != -1) {
      Map<String, List<SampleTask>> sampleTasks = state.sampleTasks;
      sampleTasks[uuid]!.replaceRange(index, index, [updatedTask]);

      emit(SampleTaskSelected(
        selectedSampleTask: updatedTask,
        sampleTasks: sampleTasks,
      ));
    }
  }

  void remove(SampleTask sampleTask) {
    String currentUserUuid = _currentUser().uuid;
    if (!state.sampleTasks.containsKey(currentUserUuid)) {
      return; // should not happen
    }
    Map<String, List<SampleTask>> sampleTasks = state.sampleTasks;
    sampleTasks[currentUserUuid]!
        .removeWhere((existingSampleTask) => existingSampleTask.id == sampleTask.id);
    emit(SampleTasksAvailable(sampleTasks: sampleTasks));
  }

  @override
  SampleTasksState fromJson(Map<String, dynamic> json) {
    Map<String, List<SampleTask>> sampleTasks = {};
    for (MapEntry entry in json.entries) {
      String uuid = entry.key;
      List<dynamic> sampleTasksJson = entry.value;
      sampleTasks[uuid] = [];
      for (var sampleTaskJson in sampleTasksJson) {
        sampleTasks[uuid]!.add(SampleTask.fromJson(sampleTaskJson));
      }
    }

    return sampleTasks.isEmpty
        ? SampleTasksEmpty(sampleTasks: sampleTasks)
        : SampleTasksAvailable(sampleTasks: sampleTasks);
  }

  @override
  Map<String, dynamic> toJson(SampleTasksState state) {
    Map<String, dynamic> json = {};
    state.sampleTasks.forEach((uuid, sampleTaskList) {
      json[uuid] = sampleTaskList.map((sampleTask) => sampleTask.toJson()).toList();
    });
    return json;
  }

  List<SampleTask> get sampleTasksForCurrentUser {
    String currentUserUuid = _currentUser().uuid;
    if (!state.sampleTasks.containsKey(currentUserUuid)) {
      return [];
    }

    return state.sampleTasks[currentUserUuid]!;
  }

  SampleTask? get currentSampleTask {
    return state.currentSampleTask;
  }
}

class SampleTasksState {
  final SampleTask? currentSampleTask;
  final Map<String, List<SampleTask>> sampleTasks;

  SampleTasksState({
    required this.currentSampleTask,
    this.sampleTasks = const {},
  });
}

class SampleTasksEmpty extends SampleTasksState {
  SampleTasksEmpty({required Map<String, List<SampleTask>> sampleTasks})
      : super(currentSampleTask: null, sampleTasks: sampleTasks);
}

class SampleTasksLoading extends SampleTasksState {
  SampleTasksLoading({required currentSampleTask, required sampleTasks})
      : super(currentSampleTask: currentSampleTask, sampleTasks: sampleTasks);
}

class SampleTasksSaving extends SampleTasksState {
  SampleTasksSaving({required currentSampleTask, required sampleTasks})
      : super(currentSampleTask: currentSampleTask, sampleTasks: sampleTasks);
}

class SampleTasksAvailable extends SampleTasksState {
  SampleTasksAvailable({required sampleTasks})
      : super(currentSampleTask: null, sampleTasks: sampleTasks);
}

class SampleTaskSelected extends SampleTasksState {
  SampleTaskSelected({
    required SampleTask selectedSampleTask,
    required Map<String, List<SampleTask>> sampleTasks,
  }) : super(
          currentSampleTask: selectedSampleTask,
          sampleTasks: sampleTasks,
        );
}
