import 'package:flutter/widgets.dart';
import '../enums/route_type.dart';
import '../models/route_match.dart';
import '../parser/route_parser.dart';

/// Local navigation manager for isolated navigation contexts.
///
/// [FFRLocalNavigator] provides a scoped navigation stack that operates
/// independently from the global [FFRNavigator]. It is designed for use
/// within confined UI containers such as bottom sheets or tab views.
///
/// Inspired by Angular's `RouterOutlet`, this class manages a local stack
/// of routes that share the global [FFRRouteParser] for route resolution
/// but maintain their own navigation history.
///
/// Example usage with [FFRLocalNavigatorOutlet]:
/// ```dart
/// FFRLocalNavigatorOutlet(
///   initialRoute: '/settings/profile',
///   navigatorType: FFRRouteType.bottomSheet,
///   child: LocalNavigationBuilder(),
/// )
/// ```
///
/// Access the local navigator within children:
/// ```dart
/// FFRLocalNavigator.of(context).pushNamed('/settings/privacy');
/// ```
class FFRLocalNavigator extends ChangeNotifier {
  final FFRRouteParser _parser;
  final FFRRouteType navigatorType;
  final String initialRoute;

  final List<FFRRouteMatch> _stack = [];

  /// Creates a local navigator that shares the global route parser.
  ///
  /// The [navigatorType] must be either [FFRRouteType.bottomSheet] or
  /// [FFRRouteType.tab]. The [initialRoute] is pushed onto the stack
  /// immediately upon creation.
  FFRLocalNavigator({
    required FFRRouteParser parser,
    required this.navigatorType,
    this.initialRoute = '/',
  }) : _parser = parser {
    assert(
      navigatorType == FFRRouteType.bottomSheet ||
          navigatorType == FFRRouteType.tab,
      'FFRLocalNavigator only supports bottomSheet and tab types.',
    );
    _pushInitialRoute();
  }

  /// Returns an unmodifiable view of the current local stack.
  List<FFRRouteMatch> get stack => List.unmodifiable(_stack);

  /// The route parser shared from the global [FFRNavigator].
  FFRRouteParser get parser => _parser;

  /// Whether the local stack has more than one route.
  bool get canPop => _stack.length > 1;

  /// Returns the current active route match, or null if the stack is empty.
  FFRRouteMatch? get current => _stack.isEmpty ? null : _stack.last;

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _pushInitialRoute() {
    final match = _parser.parse(initialRoute);
    if (match != null && match.route.routeType != FFRRouteType.action) {
      _stack.add(match);
    }
  }

  /// Pushes a named route onto the local stack.
  ///
  /// The [path] is resolved against the shared global route parser. Query
  /// parameters can be provided separately and will be merged into the match.
  void pushNamed(String path, {Map<String, dynamic> queryParams = const {}}) {
    String pathWithQuery = path;
    if (queryParams.isNotEmpty) {
      final uri = Uri.parse(path);
      final mergedQuery = {...uri.queryParameters, ...queryParams};
      pathWithQuery = uri.replace(queryParameters: mergedQuery).toString();
    }

    final match = _parser.parse(pathWithQuery);
    if (match != null && match.route.routeType != FFRRouteType.action) {
      _stack.add(match);
      notifyListeners();
    }
  }

  /// Replaces the entire local stack with a new route.
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

    final match = _parser.parse(pathWithQuery);
    if (match != null && match.route.routeType != FFRRouteType.action) {
      _stack.clear();
      _stack.add(match);
      notifyListeners();
    }
  }

  /// Pops the top route from the local stack.
  ///
  /// If [exitLocalNavigation] is true, this will not pop the stack but
  /// instead signal that the local navigation container should close
  /// (e.g., dismiss the bottom sheet). Returns true if the local navigation
  /// container should exit.
  ///
  /// If [exitLocalNavigation] is false or the stack has only one route,
  /// the pop is ignored and returns false.
  bool pop({bool exitLocalNavigation = false}) {
    if (exitLocalNavigation) {
      return true;
    }

    if (_stack.length > 1) {
      _stack.removeLast();
      notifyListeners();
      return false;
    }

    return false;
  }

  /// Clears all routes from the local stack.
  void clear() {
    _stack.clear();
    notifyListeners();
  }
}
