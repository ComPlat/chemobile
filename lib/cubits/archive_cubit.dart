import 'package:chemobile/models/eln_user.dart';
import 'package:chemobile/models/sample_task.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ArchiveCubit extends HydratedCubit<ArchiveState> {
  ArchiveCubit() : super(SampleTasksEmpty(sampleTasks: {}));

  void add(ElnUser user, SampleTask sampleTask) async {
    Map<String, List<SampleTask>> sampleTasks = state.sampleTasks;
    if (!sampleTasks.containsKey(user.uuid)) {
      sampleTasks[user.uuid] = [];
    }
    sampleTasks[user.uuid]!.insert(0, sampleTask);
    emit(SampleTasksAvailable(sampleTasks: sampleTasks));
  }

  List<SampleTask> sampleTasksForCurrentUser(ElnUser currentUser) {
    String currentUserUuid = currentUser.uuid;
    if (!state.sampleTasks.containsKey(currentUserUuid)) {
      return [];
    }

    return state.sampleTasks[currentUserUuid]!;
  }

  @override
  ArchiveState fromJson(Map<String, dynamic> json) {
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
  Map<String, dynamic> toJson(ArchiveState state) {
    Map<String, dynamic> json = {};
    state.sampleTasks.forEach((uuid, sampleTaskList) {
      json[uuid] = sampleTaskList.map((sampleTask) => sampleTask.toJson()).toList();
    });
    return json;
  }
}

class ArchiveState {
  final Map<String, List<SampleTask>> sampleTasks;

  ArchiveState({required this.sampleTasks});
}

class SampleTasksEmpty extends ArchiveState {
  SampleTasksEmpty({required Map<String, List<SampleTask>> sampleTasks})
      : super(sampleTasks: sampleTasks);
}

class SampleTasksAvailable extends ArchiveState {
  SampleTasksAvailable({required Map<String, List<SampleTask>> sampleTasks})
      : super(sampleTasks: sampleTasks);
}
