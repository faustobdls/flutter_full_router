import 'package:flutter/material.dart';
import '../enums/route_type.dart';
import '../navigator/custom_navigator.dart';

class FFRRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final FFRNavigator navigator;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  FFRRouterDelegate(this.navigator, {GlobalKey<NavigatorState>? navigatorKey})
    : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {
    navigator.addListener(notifyListeners);
  }

  @override
  void dispose() {
    navigator.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  String? get currentConfiguration {
    if (navigator.stack.isEmpty) return null;
    return navigator.stack.last.originalUrl;
  }

  @override
  Widget build(BuildContext context) {
    if (navigator.stack.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Navigator(
      key: navigatorKey,
      observers: navigator.observers,
      pages: navigator.stack.map((match) {
        final key = ValueKey(match.hashCode);
        final name = match.originalUrl;
        final child = match.route.builder(
          context,
          match.pathParams,
          match.queryParams,
        );

        switch (match.route.routeType) {
          case FFRRouteType.dialog:
            return FFRDialogPage(key: key, name: name, child: child);
          case FFRRouteType.bottomSheet:
            return FFRBottomSheetPage(key: key, name: name, child: child);
          default:
            return MaterialPage(key: key, name: name, child: child);
        }
      }).toList(),
      onDidRemovePage: (page) {
        navigator.pop();
      },
    );
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    navigator.setNewRoutePath(configuration);
  }
}

class FFRDialogPage<T> extends Page<T> {
  final Widget child;

  const FFRDialogPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      settings: this,
      builder: (context) => child,
    );
  }
}

class FFRBottomSheetPage<T> extends Page<T> {
  final Widget child;

  const FFRBottomSheetPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      builder: (context) => child,
      isScrollControlled: true,
      useSafeArea: true,
    );
  }
}
