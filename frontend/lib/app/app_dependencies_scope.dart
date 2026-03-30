import 'package:flutter/widgets.dart';

import 'app_dependencies.dart';

class AppDependenciesScope extends InheritedWidget {
  const AppDependenciesScope({
    required this.dependencies,
    required super.child,
    super.key,
  });

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'AppDependenciesScope is not available in the tree.');
    return scope!.dependencies;
  }

  static AppDependenciesScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppDependenciesScope>();
  }

  @override
  bool updateShouldNotify(AppDependenciesScope oldWidget) {
    return dependencies != oldWidget.dependencies;
  }
}
