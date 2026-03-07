import 'dart:developer';
import 'package:flutter/widgets.dart';

/// A built-in observer that logs navigation events (pushes, pops, replacements)
/// to the console when plugged into `FFRNavigator`.
class FFRRouteLogger extends NavigatorObserver {
  final String logPrefix;

  FFRRouteLogger({this.logPrefix = 'FFRRouteLogger'});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      log('Pushed: ${route.settings.name}', name: logPrefix);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      log('Popped: ${route.settings.name}', name: logPrefix);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      log('Removed: ${route.settings.name}', name: logPrefix);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != null) {
      log(
        'Replaced ${oldRoute?.settings.name} with ${newRoute!.settings.name}',
        name: logPrefix,
      );
    }
  }
}
