import 'dart:io';

import 'package:chemobile/models/sample_task.dart';

class SampleTaskListMerger {
  SampleTaskListMerger();

  List<SampleTask> merge({deviceTasks, elnTasks}) {
    List<SampleTask> resultTasks = [];

    elnTasks.forEach((elnTask) {
      int indexOnDevice = deviceTasks.indexWhere((deviceTask) => deviceTask.id == elnTask.id);
      bool taskNotOnDevice = (indexOnDevice == -1);
      if (taskNotOnDevice) {
        // add new tasks directly
        resultTasks.add(elnTask);
      } else {
        // merge tasks
        SampleTask deviceTask = deviceTasks[indexOnDevice];
        SampleTask mergedTask = SampleTask(
          elnTask.id,
          elnTask.requiredScanResults,
          elnTask.sampleId,
          elnTask.shortLabel,
          deviceTask.scanResults,
          elnTask.displayName,
          elnTask.description,
          deviceTask.userUuid,
          elnTask.targetAmountValue,
          elnTask.targetAmountUnit,
          elnTask.sampleSvgFile,
        );
        resultTasks.add(mergedTask);
      }
    });

    // delete images for SampleTasks that are NOT in the eln list (to prevent a memory leak)
    deviceTasks.forEach((deviceTask) {
      int indexInResultList =
          resultTasks.indexWhere((resultTask) => deviceTask.id == resultTask.id);
      if (indexInResultList == -1) {
        // device Task is not in result List
        deviceTask.scanResults.forEach((scanResult) async {
          await File(scanResult.imagePath).delete();
        });
      }
    });
    return resultTasks;
  }
}
