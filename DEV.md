# chemobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Add this to your android.local.properties

```
flutter.minSdkVersion=21
flutter.targetSdkVersion=33
flutter.compileSdkVersion=33
```

## Editor Config for Sublime Text

- lsp-dart
- dart

Dart Plugin Settings.sublime-settings
```
{
  "tab_size": 2,
  "extensions": [
    "dart",
  ],
  "lsp_format_on_save": true,
  "rulers": [
    100,
  ],
}
```

Cmd+P -> LSP-Dart Settings
```
{
  "initializationOptions": {
    // When set to true, analysis will only be performed for projects that
    // have open files rather than the root workspace folder.
    "onlyAnalyzeProjectsWithOpenFiles": true,
    // When set to false, completion will not include synbols that are not
    // already imported into the current file.
    "suggestFromUnimportedLibraries": true,
    // When set to true, render closing labels.
    "closingLabels": true,
    // Not implemented
    "outline": false,
    // Not implemented
    "flutterOutline": false
  },
  "settings": {
    // An array of paths (absolute or relative to each workspace folder)
    // that should be excluded from analysis.
    "dart.analysisExcludedFolders": [],
    // When set to false, prevents registration (or unregisters) the SDK
    // formatter. When set to true or not supplied, will register/reregister
    // the SDK formatter.
    "dart.enableSdkFormatter": true,
    // The number of characters the formatter should wrap code at.
    "dart.lineLength": 100,
    // Completes functions/methods with their required parameters.
    "dart.completeFunctionCalls": false,
    // Whether to generate diagnostics for TODO comments.
    "dart.showTodos": false
  }
}
```

## Parse models to json
```
flutter packages pub run build_runner build
```

## Run integration tests

Replace ELN_USERNAME, ELN_PASSWORD and ELN_URL with your local credentials.

```
flutter drive \
  --dart-define=ELN_USERNAME=complat.user1@eln.edu \
  --dart-define=ELN_PASSWORD=@complat \
  --dart-define=ELN_URL=http://192.168.178.124:3000 \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart

## To specify a device
flutter drive \
  --dart-define=ELN_USERNAME=complat.user1@eln.edu \
  --dart-define=ELN_PASSWORD=@complat \
  --dart-define=ELN_URL=http://192.168.178.124:3000 \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d "<YOUR DEVICE ID from flutter devices>"

flutter drive \
  --dart-define=ELN_USERNAME=complat.user1@eln.edu \
  --dart-define=ELN_PASSWORD=@complat \
  --dart-define=ELN_URL=http://192.168.178.124:3000 \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d emu
```
