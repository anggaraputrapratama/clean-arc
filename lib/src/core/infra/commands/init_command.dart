import 'dart:async';

import 'package:clean_arc/src/core/domain/commands/command.dart';
import 'package:clean_arc/src/core/infra/commands/repository_pattern_module_creator_impl.dart';
import 'package:clean_arc/src/core/infra/creators/repository_pattern_creator_impl.dart';

class InitCommand implements Command {
  final String module;

  InitCommand(this.module);

  @override
  Future<void> execute() async {
    final moduleCreator = RepositoryPatternModuleCreatorImpl(basePath: module);
    final creator = RepositoryPatternCreatorImpl(creator: moduleCreator);

    return creator.create();
  }
}
