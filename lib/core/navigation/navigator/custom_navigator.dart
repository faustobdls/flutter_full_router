import 'package:flutter/widgets.dart';
import '../enums/route_type.dart';
import '../models/route_definition.dart';
import '../models/route_match.dart';
import '../parser/route_parser.dart';
import '../guards/route_guard.dart';

class FFRNavigator extends ChangeNotifier {
  static FFRNavigator? _instance;

  @visibleForTesting
  static void clearInstanceForTest() {
    _instance = null;
  }

  /// Global instance accessor.
  ///
  /// Use `FFRNavigator.I` to access the navigator from anywhere without
  /// needing to pass the instance as a parameter.
  ///
  /// Example:
  /// ```dart
  /// FFRNavigator.I.pushNamed('/home');
  /// ```
  static FFRNavigator get I {
    assert(
      _instance != null,
      'FFRNavigator has not been initialized. '
      'Create an FFRNavigator instance before accessing FFRNavigator.I.',
    );
    return _instance!;
  }

  final FFRRouteParser parser;
  final FFRRouteGuard? guard;
  final String initialRoute;
  final String notFoundRoute;
  final List<NavigatorObserver> observers;

  final List<FFRRouteMatch> _stack = [];

  List<FFRRouteMatch> get stack => List.unmodifiable(_stack);
  List<FFRRouteMatch> get history => stack;

  FFRNavigator({
    required this.parser,
    this.guard,
    this.initialRoute = '/',
    this.notFoundRoute = '/404',
    this.observers = const [],
  }) {
    _instance = this;
  }

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

      // Action routes: execute the callback and do NOT push to stack.
      if (match.route.routeType == FFRRouteType.action) {
        match.route.action?.call(match.pathParams, match.queryParams);
        return;
      }

      if (replaceAllFlow && !isNotFound) {
        _stack.clear();
      }

      _stack.add(match);
      notifyListeners();
    }
    _ensureNotEmpty();
  }

  void _ensureNotEmpty() {
    if (_stack.isEmpty) {
      final fallback = parser.parse(initialRoute);
      if (fallback != null && fallback.route.routeType != FFRRouteType.action) {
        _stack.add(fallback);
        notifyListeners();
      }
    }
  }

  /// Pops the top route from the stack if possible.
  void pop() {
    if (_stack.length > 1) {
      _stack.removeLast();
      notifyListeners();
    }
  }

  /// Removes all routes from the stack.
  void popAll() {
    _stack.clear();
    notifyListeners();
  }

  /// Internal: handles new external routes (like deep links or browser URL changes).
  /// This is used by the FFRRouterDelegate.
  void setNewRoutePath([String? path]) {
    _stack.clear();
    if (path != null) {
      _pushPath(path);
    } else {
      notifyListeners();
    }
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
}
