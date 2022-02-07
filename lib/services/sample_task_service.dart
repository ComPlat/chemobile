import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chemobile/cubits/archive_cubit.dart';
import 'package:chemobile/cubits/sample_tasks_cubit.dart';
import 'package:chemobile/models/eln_user.dart';
import 'package:chemobile/models/exception.dart';
import 'package:chemobile/models/sample_task.dart';
import 'package:chemobile/models/scan_result.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SampleTaskService {
  Future<List<SampleTask>> getTasks(ElnUser user) async {
    String status = 'with_missing_scan_results';
    var url = Uri.parse("${user.elnUrl}/api/v1/sample_tasks?status=$status");
    var response = await http.get(url, headers: {"Authorization": "Bearer ${user.token}"});

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      var jsonElnTasks = jsonResponse['sample_tasks'];
      jsonElnTasks.forEach((task) => task['user_uuid'] = user.uuid);
      List<SampleTask> tasks = [];
      jsonElnTasks.forEach((task) => tasks.add(SampleTask.fromJson(task)));
      return tasks;
    } else {
      throw TaskListNotFetchableException();
    }
  }

  Future<SampleTask> create(
    SampleTask sampleTask,
    String elnUrl,
    String token,
  ) async {
    //TODO:
    //- save sample task to ELN
    //- update sampleTask with data from ELN (ID is required, so we can later identify records)
    //- return updated sampleTask object

    var url = Uri.parse("$elnUrl/api/v1/sample_tasks");

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data",
      })
      ..fields['description'] = sampleTask.description
      ..fields['required_scan_results'] = sampleTask.requiredScanResults.toString();

    var response = await request.send();
    String responseBody = await response.stream.bytesToString();
    if (response.statusCode != 201) {
      throw SendingFreeScanFailed();
    }

    var jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
    sampleTask.id = jsonResponse['id'];

    return sampleTask;
  }

  Future<bool> delete(SampleTask sampleTask, ElnUser user) async {
    var url = Uri.parse("${user.elnUrl}/api/v1/sample_tasks/${sampleTask.id}");
    var response = await http.delete(url, headers: {"Authorization": "Bearer ${user.token}"});

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addScanResultToCurrentSampleTask({
    required String value,
    required String unit,
    required Uint8List imageData,
    required ArchiveCubit archive,
    required SampleTasksCubit sampleTaskList,
    required ElnUser currentUser,
  }) async {
    SampleTask sampleTask = sampleTaskList.state.currentSampleTask!;

    // build scan result
    String uuid = const Uuid().v4();
    String imagePath = await _saveImageToFile(imageData, uuid);

    ScanResult scanResult = ScanResult(
      id: null,
      imagePath: imagePath,
      measurementValue: double.parse(value),
      measurementUnit: unit,
      position: sampleTask.scanResults.length + 1,
      title: sampleTask.scanResults.isEmpty ? 'Compound' : 'Vessel + Compound',
    );

    // save scanResult to ELN and update with id and position
    scanResult = await _createScanResult(
      scanResult: scanResult,
      sampleTaskId: sampleTask.id!,
      elnUrl: currentUser.elnUrl,
      token: currentUser.token,
    );

    // save scanResult to sampleTask
    sampleTask.scanResults.add(scanResult);

    if (sampleTask.archivable()) {
      archive.add(currentUser, sampleTask);
      sampleTaskList.remove(sampleTask);
    } else {
      sampleTaskList.updateCurrentSampleTask(sampleTask);
    }
  }

  Future<ScanResult> _createScanResult({
    required ScanResult scanResult,
    required int sampleTaskId,
    required String elnUrl,
    required String token,
  }) async {
    var url = Uri.parse("$elnUrl/api/v1/sample_tasks/$sampleTaskId/scan_results");

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data",
      })
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        scanResult.imagePath!,
      ))
      ..fields['measurement_value'] = scanResult.measurementValue.toString()
      ..fields['measurement_unit'] = scanResult.measurementUnit.toString()
      ..fields['title'] = scanResult.title.toString();

    var response = await request.send();

    String responseBody = await response.stream.bytesToString();
    if (response.statusCode != 201) {
      throw SendingFreeScanFailed();
    }

    var jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
    scanResult.id = jsonResponse['id'];
    scanResult.position = jsonResponse['position'];

    return scanResult;
  }

  Future<String> _saveImageToFile(imageData, uuid) async {
    String savePath = (await getApplicationDocumentsDirectory()).path;
    File savedFile = File("$savePath/$uuid.png");
    await savedFile.writeAsBytes(imageData);

    return savedFile.path;
  }

  Future<bool> resubmit(
    SampleTask originalSampleTask,
    String elnUrl,
    String token,
  ) async {
    SampleTask sampleTask = await create(SampleTask.copyFrom(originalSampleTask), elnUrl, token);

    for (ScanResult scanResult in sampleTask.scanResults) {
      await _createScanResult(
          scanResult: scanResult, sampleTaskId: sampleTask.id!, elnUrl: elnUrl, token: token);
    }

    return true;
  }
}
