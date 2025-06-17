import 'dart:io';

abstract class ModuleCreator {
  Future<bool> createModule();

  Directory get domain;
  Directory get domainModels;
  Directory get domainRepositories;
  Directory get domainStores;
  Directory get domainUsecases;
  Directory get domainServices;

  Directory get external;
  Directory get externalDatasources;

  Directory get infra;
  Directory get infraDatasources;
  Directory get infraRepositories;
  Directory get infraServices;

  Directory get presenter;
  Directory get presenterPages;
  Directory get presenterWidgets;
}

typedef PackageVersion = String;

abstract class RepositoryPatternModuleCreator {
  Future<bool> createModule();

  Directory get application;

  Directory get data;

  Directory get domain;

  Directory get presentation;
  Directory get presentationControllers;
  Directory get presentationLayouts;
  Directory get presentationScreens;
  Directory get presentationWidgets;

  Directory get route;

  PackageVersion get flutterLints => '^3.5.0';
  PackageVersion get customLint => '^0.7.5';
  PackageVersion get riverpodLint => '^2.3.9';
  PackageVersion get autoExporter => '^3.0.2';
  PackageVersion get buildRunner => '^2.4.8';
  PackageVersion get jsonSerializable => '^6.7.1';
  PackageVersion get freezed => '^2.4.7';
  PackageVersion get injectableGenerator => '^2.4.1';
  PackageVersion get riverpodGenerator => '^2.3.11';
  PackageVersion get enviedGenerator => '^0.5.3';
  PackageVersion get autoRouteGenerator => '^10.2.3';
}
