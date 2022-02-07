class ChemobileException implements Exception {
  String message;

  ChemobileException(this.message);
}

class CurrentUserNotFoundException extends ChemobileException {
  CurrentUserNotFoundException() : super("Please log in first");
}

class UserNotFoundException extends ChemobileException {
  UserNotFoundException() : super('User not found');
}

class TaskListNotFetchableException extends ChemobileException {
  TaskListNotFetchableException() : super('Could not load list of tasks');
}

class TaskNotUpdateableException extends ChemobileException {
  TaskNotUpdateableException() : super('Could not update task');
}

class SendingFreeScanFailed extends ChemobileException {
  SendingFreeScanFailed() : super('Sending scan to ELN failed');
}
