import 'dart:io';

import 'package:args/args.dart';
import 'package:clean_arc/src/core/creators/module_creator.dart';

class RepositoryPatternModuleCreatorImpl
    implements RepositoryPatternModuleCreator {
  final _src = 'lib/src';

  final _application = 'application';

  final _data = 'data';

  final _domain = 'domain';

  final _presentation = 'presentation';
  final _presentationControllers = 'presentation/controllers';
  final _presentationLayouts = 'presentation/layouts';
  final _presentationScreens = 'presentation/screens';
  final _presentationWidgets = 'presentation/widgets';

  final _route = 'route';

  final String basePath;
  late final String absolutePath;

  @override
  Directory get application => Directory('$absolutePath/$_application');
  @override
  Directory get data => Directory('$absolutePath/$_data');
  @override
  Directory get domain => Directory('$absolutePath/$_domain');
  @override
  Directory get presentation => Directory('$absolutePath/$_presentation');
  @override
  Directory get presentationControllers =>
      Directory('$absolutePath/$_presentationControllers');
  @override
  Directory get presentationLayouts =>
      Directory('$absolutePath/$_presentationLayouts');
  @override
  Directory get presentationScreens =>
      Directory('$absolutePath/$_presentationScreens');
  @override
  Directory get presentationWidgets =>
      Directory('$absolutePath/$_presentationWidgets');
  @override
  Directory get route => Directory('$absolutePath/$_route');

  @override
  PackageVersion get autoExporter => '^3.5.0';
  @override
  PackageVersion get buildRunner => '^2.4.15';
  @override
  PackageVersion get customLint => '^0.7.5';
  @override
  PackageVersion get enviedGenerator => '^1.1.1';
  @override
  PackageVersion get flutterLints => '^6.0.0';
  @override
  PackageVersion get freezed => '^3.0.6';
  @override
  PackageVersion get injectableGenerator => '^2.7.0';
  @override
  PackageVersion get jsonSerializable => '^6.9.5';
  @override
  PackageVersion get riverpodGenerator => '^2.6.5';
  @override
  PackageVersion get riverpodLint => '^2.6.5';

  RepositoryPatternModuleCreatorImpl({required this.basePath});

  @override
  Future<bool> createModule() async {
    try {
      final moduleDir = Directory(basePath);

      if (await moduleDir.exists()) {
        if (!_checkIfDirIsValidFlutterPackage(absDir: moduleDir.absolute)) {
          throw ArgParserException(
            'No `lib` directory and `pubspec.yaml` file was found',
          );
        }

        final srcPath = '${moduleDir.absolute.path}/$_src';

        absolutePath = srcPath;
      } else {
        if (!_checkIfDirIsValidFlutterPackage()) {
          throw ArgParserException(
            'No `lib` directory and `pubspec.yaml` file was found',
          );
        }

        final srcPath = '${Directory.current.absolute.path}/$_src';

        absolutePath = srcPath;
      }

      final absApplication = application.absolute.path;
      final absData = data.absolute.path;
      final absDomain = domain.absolute.path;
      final absPresentation = presentation.absolute.path;
      final absPresentationControllers = presentationControllers.absolute.path;
      final absPresentationLayouts = presentationLayouts.absolute.path;
      final absPresentationScreens = presentationScreens.absolute.path;
      final absPresentationWidgets = presentationWidgets.absolute.path;
      final absRoute = route.absolute.path;

      print('creating folders...\n');

      await Directory(absolutePath).create();

      await Directory(absApplication).create();

      await Directory(absData).create();

      await Directory(absDomain).create();

      await Directory(absPresentation).create();
      await Directory(absPresentationControllers).create();
      await Directory(absPresentationLayouts).create();
      await Directory(absPresentationScreens).create();
      await Directory(absPresentationWidgets).create();

      await Directory(absRoute).create();

      print('adding basic dependencies...\n');

      await _addDependenciesToPubspec();
      await _formatCodeInPubspec();

      print('initializing injectable...');

      await _updateModuleFile();
      await _addAutoExportBuildYaml();
      await _generateInjectable();

      return true;
    } catch (e, stack) {
      stderr.writeln(e);
      stderr.writeln(stack);
      return false;
    }
  }

  Future<void> _formatCodeInPubspec() async {
    try {
      final result = await Process.run('dart', [
        'fix',
        '--apply',
      ], runInShell: true);

      if (result.exitCode != 0) {
        stderr.write(result.stderr.toString());
        throw ProcessException('dart', [
          'fix',
          '--apply',
        ], result.stderr.toString());
      } else {
        stdout.write(result.stdout.toString());
      }
    } catch (e) {
      stdout.write(e.toString());
    }
  }

  Future<void> _generateInjectable() async {
    try {
      print('\ngetting dependencies...');
      final result = await Process.run('melos', ['bootstrap']);

      if (result.exitCode != 0) {
        stderr.write(result.stderr.toString());
        throw ProcessException('melos', [
          'bootstrap',
        ], result.stderr.toString());
      } else {
        stdout.write(result.stdout.toString());
      }

      print('\nstarting to initiate injectables...');
      final res = await Process.run('dart', [
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ]);

      if (res.exitCode != 0) {
        stderr.write(res.stderr.toString());
        throw ProcessException('dart', [
          'run',
          'build_runner',
          'build',
          '--delete-conflicting-outputs',
        ], res.stderr.toString());
      } else {
        stdout.write(res.stdout.toString());
      }
    } catch (e) {
      stdout.write(e.toString());
    }
  }

  Future<void> _updateModuleFile({Directory? absDir}) async {
    final moduleDir = absDir ?? Directory.current.absolute;
    final moduleName = moduleDir.path.split('/').last;

    final moduleFile = await File(
      '${moduleDir.absolute.path}/lib/$moduleName.dart',
    ).create();

    List<String> linesToWrite = [
      'library $moduleName;',
      '\n\n',
      "import 'package:dependencies/injectable/injectable.dart';",
      '\n\n',
      "export '_exports.dart';\n",
      "export '$moduleName.module.dart';",
      '\n\n',
      '@InjectableInit.microPackage()\n',
      'void initMicroPackage() {}',
    ];

    await moduleFile.writeAsString(linesToWrite.join());

    final testFile = File('${moduleDir.path}/test/${moduleName}_test.dart');

    if (await testFile.exists()) await testFile.delete();
  }

  Future<void> _addAutoExportBuildYaml({Directory? absDir}) async {
    final moduleDir = absDir ?? Directory.current.absolute;

    final moduleFile = await File(
      '${moduleDir.absolute.path}/build.yaml',
    ).create();

    List<String> linesToWrite = [
      'targets:',
      ' \$default:',
      '   builders:',
      '     auto_exporter:',
      '       options:',
      '         default_export_all: true',
      '         project_name: _exports',
      '     json_serializable:json_serializable:',
      '       generate_for:',
      '         include:',
      '           - lib/src/domain/**_model.dart',
      '     freezed:freezed:',
      '       generate_for:',
      '         include:',
      '           - lib/src/domain/**_model.dart',
      '     injectable_generator:injectable_builder:',
      '       generate_for:',
      '         include:',
      '           - lib/src/data/**_repository.dart',
      '           - lib/src/application/**_service.dart',
      '     riverpod_generator:riverpod_generator:',
      '       generate_for:',
      '         include:',
      '           - lib/src/presentation/controllers/**_controller.dart',
      '           - lib/src/route/**_route.dart',
      '     envied_generator:envied_generator:',
      '       generate_for:',
      '         include:',
      '           - lib/src/configs/**_env.dart',
    ];

    await moduleFile.writeAsString(linesToWrite.join('\n'));
  }

  Future<void> _addDependenciesToPubspec({Directory? absDir}) async {
    final moduleDir = absDir ?? Directory.current.absolute;

    final modulePubspec = File('${moduleDir.absolute.path}/pubspec.yaml');
    var pubspecContent = await modulePubspec.readAsLines();

    if (pubspecContent.any((e) => e.contains('homepage:'))) {
      pubspecContent[pubspecContent.indexWhere((e) => e == 'homepage:')] =
          'publish_to: none';
    }

    final packagesToAdd = [
      '',
      '  core:',
      '    path: ../core',
      '  dependencies:',
      '    path: ../dependencies',
      '',
    ];

    final indexStart =
        pubspecContent.indexWhere((e) => e.contains('dependencies:')) + 3;

    for (int z = 0; z < packagesToAdd.length; z++) {
      final insertionIndex = indexStart + z;

      if (pubspecContent[insertionIndex] == packagesToAdd[z]) {
        continue;
      }

      pubspecContent.insert(insertionIndex, packagesToAdd[z]);
    }

    final updated = await modulePubspec.writeAsString(
      pubspecContent.join('\n'),
    );

    return _addDevDependenciesToPubspec(updated);
  }

  Future<void> _addDevDependenciesToPubspec(File updated) async {
    var pubspecContent = await updated.readAsLines();
    List<String> packagesToAdd = [
      '',
      '  flutter_lints: $flutterLints',
      '  custom_lint: $customLint',
      '  riverpod_lint: $riverpodLint',
      '  auto_exporter: $autoExporter',
      '  build_runner: $buildRunner',
      '  json_serializable: $jsonSerializable',
      '  freezed: $freezed',
      '  injectable_generator: $injectableGenerator',
      '  riverpod_generator: $riverpodGenerator',
      '  envied_generator: $enviedGenerator',
    ];

    final indexStart =
        pubspecContent.indexWhere((e) => e.contains('flutter_test')) + 2;

    for (int i = 0; i < packagesToAdd.length; i++) {
      final insertionIndex = indexStart + i;

      if (pubspecContent[insertionIndex] != packagesToAdd[i] &&
          pubspecContent[insertionIndex].contains('flutter_lints')) {
        pubspecContent[insertionIndex] = packagesToAdd[i];
        continue;
      }

      if (pubspecContent[insertionIndex] == packagesToAdd[i]) {
        continue;
      }

      pubspecContent.insert(insertionIndex, packagesToAdd[i]);
    }

    await updated.writeAsString(pubspecContent.join('\n'));
  }

  bool _checkIfDirIsValidFlutterPackage({Directory? absDir}) {
    final currentDirectories =
        absDir?.listSync() ?? Directory.current.absolute.listSync();

    final containsLib = currentDirectories.any(
      (e) => e.absolute.path == Directory('lib').absolute.path,
    );
    final containsPubspec = currentDirectories.any(
      (e) => e.absolute.path == File('pubspec.yaml').absolute.path,
    );

    if (!containsLib && !containsPubspec) {
      return false;
    }

    return true;
  }
}
