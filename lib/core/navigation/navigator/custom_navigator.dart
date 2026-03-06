import 'package:flutter/widgets.dart';
import '../actions/navigator_action.dart';
import '../models/route_definition.dart';
import '../models/route_match.dart';
import '../parser/route_parser.dart';
import '../guards/route_guard.dart';

class FFRNavigator extends ChangeNotifier {
  final FFRRouteParser parser;
  final FFRRouteGuard? guard;
  final String initialRoute;
  final String notFoundRoute;
  final List<NavigatorObserver> observers;

  final List<FFRRouteMatch> _stack = [];
  final Map<String, FFRNavigatorAction> _actions = {};

  List<FFRRouteMatch> get stack => List.unmodifiable(_stack);
  List<FFRRouteMatch> get history => stack;

  FFRNavigator({
    required this.parser,
    this.guard,
    this.initialRoute = '/',
    this.notFoundRoute = '/404',
    this.observers = const [],
  });

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  /// Internal: Pushes a new raw path route onto the stack.
  void _pushPath(String path) {
    FFRRouteMatch? match = parser.parse(path);
    _handleMatch(match, path, replaceAllFlow: false);
  }

  /// Pushes a named route (path string) onto the stack.
  /// The path variables are automatically translated based on the route setup.
  void pushNamed(String path, {Map<String, dynamic> queryParams = const {}}) {
    // If query parameters are provided, we append them to the path for parsing
    String pathWithQuery = path;
    if (queryParams.isNotEmpty) {
      final uri = Uri.parse(path);
      final mergedQuery = {...uri.queryParameters, ...queryParams};
      pathWithQuery = uri.replace(queryParameters: mergedQuery).toString();
    }

    FFRRouteMatch? match = parser.parse(pathWithQuery);
    final originalUrl = match?.originalUrl ?? pathWithQuery;
    _handleMatch(match, originalUrl, replaceAllFlow: false);
  }

  /// Internal: Replaces the entire stack with a new raw path route.
  void _replaceAllPath(String path) {
    FFRRouteMatch? match = parser.parse(path);
    _handleMatch(match, path, replaceAllFlow: true);
  }

  /// Replaces the entire stack with a new named route (path string).
  /// The path variables are automatically translated based on the route setup.
  void pushReplacementNamed(
    String path, {
    Map<String, dynamic> queryParams = const {},
  }) {
    String pathWithQuery = path;
    if (queryParams.isNotEmpty) {
      final uri = Uri.parse(path);
      final mergedQuery = {...uri.queryParameters, ...queryParams};
      pathWithQuery = uri.replace(queryParameters: mergedQuery).toString();
    }

    FFRRouteMatch? match = parser.parse(pathWithQuery);
    final originalUrl = match?.originalUrl ?? pathWithQuery;
    _handleMatch(match, originalUrl, replaceAllFlow: true);
  }

  void _handleMatch(
    FFRRouteMatch? match,
    String requestedPath, {
    required bool replaceAllFlow,
  }) {
    final isNotFound = match == null;
    match ??= _fallbackToNotFound();

    if (match != null) {
      // Check guard
      if (guard != null) {
        final redirectPath = guard!(match);
        if (redirectPath != null && redirectPath != requestedPath) {
          if (replaceAllFlow) {
            _replaceAllPath(redirectPath);
          } else {
            _pushPath(redirectPath);
          }
          return;
        }
      }

      if (replaceAllFlow && !isNotFound) {
        _stack.clear();
      }

      _stack.add(match);
      notifyListeners();
    }
  }

  /// Pops the top route from the stack if possible.
  void pop() {
    if (_stack.length > 1) {
      _stack.removeLast();
      notifyListeners();
    }
  }

  /// Internal: handles new external routes (like deep links or browser URL changes).
  /// This is used by the FFRRouterDelegate.
  void setNewRoutePath(String path) {
    _stack.clear();
    _pushPath(path);
  }

  FFRRouteMatch? _fallbackToNotFound() {
    return parser.parse(notFoundRoute);
  }

  // ---------------------------------------------------------------------------
  // Dynamic Route Management
  // ---------------------------------------------------------------------------

  /// Registers a new [route] at runtime.
  ///
  /// If a route with the same [FFRRouteDefinition.id] already exists in the
  /// parser, it will be replaced. Notifies listeners so the delegate can
  /// react to route table changes if needed.
  ///
  /// Example:
  /// ```dart
  /// navigator.addRoute(FFRRouteDefinition(
  ///   id: '99NEW',
  ///   path: '/new-feature',
  ///   builder: (ctx, p, q) => NewFeatureScreen(),
  /// ));
  /// ```
  void addRoute(FFRRouteDefinition route) {
    parser.addRoute(route);
    notifyListeners();
  }

  /// Registers multiple [routes] at runtime.
  ///
  /// Equivalent to calling [addRoute] for each item.
  void addRoutes(List<FFRRouteDefinition> routes) {
    parser.addRoutes(routes);
    notifyListeners();
  }

  /// Removes the route identified by [id] from the route table at runtime.
  ///
  /// Does nothing if no route with [id] exists. Notifies listeners.
  void removeRoute(String id) {
    parser.removeRoute(id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Action Registry
  // ---------------------------------------------------------------------------

  /// Registers a named [action] that can later be triggered via [executeAction].
  ///
  /// Actions are arbitrary side-effect callbacks identified by [name].
  /// Registering an action with an existing name replaces the previous one.
  ///
  /// Example:
  /// ```dart
  /// navigator.registerAction('logout', (_) async {
  ///   await authService.signOut();
  ///   navigator.pushReplacementNamed('/login');
  /// });
  /// ```
  void registerAction(String name, FFRNavigatorAction action) {
    _actions[name] = action;
  }

  /// Removes the action identified by [name] from the registry.
  ///
  /// Does nothing if no action with [name] is registered.
  void unregisterAction(String name) {
    _actions.remove(name);
  }

  /// Executes the action registered under [name], passing [params] to it.
  ///
  /// If no action is registered under [name], this method does nothing.
  ///
  /// Example:
  /// ```dart
  /// navigator.executeAction('logout', params: {'reason': 'session_expired'});
  /// ```
  void executeAction(String name, {Map<String, dynamic> params = const {}}) {
    _actions[name]?.call(params);
  }

  /// Returns `true` if an action with [name] is currently registered.
  bool hasAction(String name) => _actions.containsKey(name);
}
