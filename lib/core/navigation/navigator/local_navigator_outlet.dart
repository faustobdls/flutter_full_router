import 'package:flutter/widgets.dart';
import '../enums/route_type.dart';
import '../models/route_match.dart';
import '../navigator/custom_navigator.dart';
import '../parser/route_parser.dart';
import 'local_navigator.dart';

/// Widget that provides a local navigation context (outlet).
///
/// [FFRLocalNavigatorOutlet] creates and exposes an [FFRLocalNavigator]
/// to its subtree via [InheritedWidget]. This enables nested routing
/// within confined UI containers like bottom sheets or tab views.
///
/// The widget listens to changes in the local navigator stack and
/// rebuilds accordingly, allowing child widgets to access the current
/// route and render its content.
///
/// Example usage in a bottom sheet route builder:
/// ```dart
/// FFRRouteDefinition(
///   id: '01BS',
///   path: '/settings',
///   routeType: FFRRouteType.bottomSheet,
///   builder: (context, p, q) => FFRLocalNavigatorOutlet(
///     initialRoute: '/settings/main',
///     navigatorType: FFRRouteType.bottomSheet,
///     builder: (context, localNavigator) {
///       return LocalSettingsLayout(
///         navigator: localNavigator,
///         currentMatch: localNavigator.current,
///       );
///     },
///   ),
/// )
/// ```
///
/// Access the local navigator from child widgets:
/// ```dart
/// final localNav = FFRLocalNavigator.of(context);
/// localNav.pushNamed('/settings/privacy');
/// ```
class FFRLocalNavigatorOutlet extends StatefulWidget {
  /// The initial route path for this local navigation context.
  final String initialRoute;

  /// The type of local navigation (bottomSheet or tab).
  final FFRRouteType navigatorType;

  /// Optional shared route parser. If not provided, uses the global
  /// [FFRNavigator.I.parser].
  final FFRRouteParser? parser;

  /// Builder that receives the local navigator and current match.
  final Widget Function(
    BuildContext context,
    FFRLocalNavigator navigator,
    FFRRouteMatch? currentMatch,
  ) builder;

  /// Creates a local navigation outlet widget.
  ///
  /// The [builder] is called with the local navigator instance and the
  /// current route match, allowing children to render based on the
  /// local navigation state.
  const FFRLocalNavigatorOutlet({
    super.key,
    this.initialRoute = '/',
    required this.navigatorType,
    this.parser,
    required this.builder,
  }) : assert(
         navigatorType == FFRRouteType.bottomSheet ||
             navigatorType == FFRRouteType.tab,
         'FFRLocalNavigatorOutlet only supports bottomSheet and tab types.',
       );

  @override
  State<FFRLocalNavigatorOutlet> createState() =>
      _FFRLocalNavigatorOutletState();

  /// Retrieves the nearest [FFRLocalNavigator] from the widget tree.
  ///
  /// Throws an assertion error if called outside a
  /// [FFRLocalNavigatorOutlet] subtree.
  static FFRLocalNavigator of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<
        _InheritedLocalNavigator>();
    assert(
      inherited != null,
      'FFRLocalNavigator.of() called outside a FFRLocalNavigatorOutlet subtree.',
    );
    return inherited!.navigator;
  }

  /// Retrieves the nearest [FFRRouteMatch] from the widget tree.
  ///
  /// Returns null if called outside a [FFRLocalNavigatorOutlet] subtree
  /// or if the local stack is empty.
  static FFRRouteMatch? currentMatch(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<
        _InheritedLocalNavigator>();
    return inherited?.currentMatch;
  }
}

class _FFRLocalNavigatorOutletState extends State<FFRLocalNavigatorOutlet> {
  late FFRLocalNavigator _navigator;

  @override
  void initState() {
    super.initState();
    final parser = widget.parser ?? _globalParser;
    _navigator = FFRLocalNavigator(
      parser: parser,
      navigatorType: widget.navigatorType,
      initialRoute: widget.initialRoute,
    );
    _navigator.addListener(_onNavigatorChanged);
  }

  @override
  void didUpdateWidget(covariant FFRLocalNavigatorOutlet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.parser != widget.parser ||
        oldWidget.initialRoute != widget.initialRoute ||
        oldWidget.navigatorType != widget.navigatorType) {
      _navigator.removeListener(_onNavigatorChanged);
      _navigator.dispose();

      final parser = widget.parser ?? _globalParser;
      _navigator = FFRLocalNavigator(
        parser: parser,
        navigatorType: widget.navigatorType,
        initialRoute: widget.initialRoute,
      );
      _navigator.addListener(_onNavigatorChanged);
    }
  }

  @override
  void dispose() {
    _navigator.removeListener(_onNavigatorChanged);
    _navigator.dispose();
    super.dispose();
  }

  void _onNavigatorChanged() {
    setState(() {});
  }

  FFRRouteParser get _globalParser {
    return FFRNavigator.I.parser;
  }

  @override
  Widget build(BuildContext context) {
    final currentMatch = _navigator.current;
    return _InheritedLocalNavigator(
      navigator: _navigator,
      currentMatch: currentMatch,
      child: Builder(
        builder: (innerContext) => widget.builder(innerContext, _navigator, currentMatch),
      ),
    );
  }
}

class _InheritedLocalNavigator extends InheritedWidget {
  final FFRLocalNavigator navigator;
  final FFRRouteMatch? currentMatch;

  const _InheritedLocalNavigator({
    required this.navigator,
    required this.currentMatch,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedLocalNavigator oldWidget) {
    return navigator != oldWidget.navigator ||
        currentMatch != oldWidget.currentMatch;
  }
}
