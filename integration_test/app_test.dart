import 'package:chemobile/helpers/dev_print.dart';
import 'package:chemobile/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'robots/archive_robot.dart';
import 'robots/login_form_robot.dart';
import 'robots/menu_screen_robot.dart';
import 'robots/scan_screen_robot.dart';
import 'robots/task_list_robot.dart';

void main() {
  LoginFormRobot loginFormRobot;
  MenuScreenRobot menuScreenRobot;
  TaskListRobot taskListRobot;
  ScanScreenRobot scanScreenRobot;
  ArchiveRobot archiveRobot;

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('e2e test', () {
    testWidgets('whole app', (WidgetTester tester) async {
      app.main();
      // initialize robots
      loginFormRobot = LoginFormRobot(tester);
      menuScreenRobot = MenuScreenRobot(tester);
      taskListRobot = TaskListRobot(tester);
      scanScreenRobot = ScanScreenRobot(tester);
      archiveRobot = ArchiveRobot(tester);

      devPrint('Login as Matt');
      const userIdentifier = String.fromEnvironment("ELN_USERNAME");
      const password = String.fromEnvironment("ELN_PASSWORD");
      const elnUrl = String.fromEnvironment("ELN_URL");

      await loginFormRobot.login(
          userIdentifier: userIdentifier,
          password: password,
          elnUrl: elnUrl,
          validationUser: 'User6 Complat');

      devPrint('open task list');
      await menuScreenRobot.openTaskList();
      devPrint('start new scan');
      await taskListRobot.startNewScan();
      devPrint('save scan result');
      await scanScreenRobot.saveScan();
      devPrint('back to menu screen');
      await taskListRobot.backToMenuScreen();
      await menuScreenRobot.openArchive();
      await archiveRobot.findArchivedScans(count: 1);
      await archiveRobot.openFirstScan();
    });
  });
}
