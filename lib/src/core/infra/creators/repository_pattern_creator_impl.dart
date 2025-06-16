import 'dart:io';

import 'package:clean_arc/src/core/creators/module_creator.dart';
import 'package:clean_arc/src/core/creators/repository_pattern_creator.dart';

class RepositoryPatternCreatorImpl implements RepositoryPatternCreator {
  final RepositoryPatternModuleCreator creator;

  RepositoryPatternCreatorImpl({required this.creator});

  @override
  Future<void> create() async {
    final res = await creator.createModule();

    if (!res) {
      stderr.writeln('Failed to init module');
    } else {
      print('Done! Module initialization is completed!');
    }
  }
}
