import 'package:flutter/widgets.dart';
import '../enums/route_type.dart';
import '../models/route_match.dart';
import '../navigator/custom_navigator.dart';
import '../parser/route_parser.dart';
import 'local_navigator.dart';

/// Widget que fornece um contexto de navegação local (outlet).
///
/// [FFRLocalNavigatorOutlet] cria e expõe um [FFRLocalNavigator]
/// para a subtree via [InheritedWidget]. Isso permite navegação aninhada
/// dentro de containers como bottom sheets ou tab views.
///
/// O outlet renderiza o builder da rota atual e reconstrói quando a
/// navegação local muda.
///
/// Exemplo de uso dentro de uma rota bottomSheet:
/// ```dart
/// FFRLocalNavigatorOutlet(
///   initialRoute: '/settings/main',
///   navigatorType: FFRRouteType.bottomSheet,
///   transitions: FFRPageTransitions.ios(),
/// )
/// ```
///
/// Acesso do child:
/// ```dart
/// FFRLocalNavigatorOutlet.of(context).pushNamed('/settings/privacy');
/// ```
class FFRLocalNavigatorOutlet extends StatefulWidget {
  final String initialRoute;
  final FFRRouteType navigatorType;
  final FFRRouteParser? parser;

  /// Callback invoked when [pop(exitLocalNavigation: true)] is called.
  ///
  /// Use this to close the parent container (e.g., dismiss a bottom sheet).
  final VoidCallback? onExitLocalNavigation;

  const FFRLocalNavigatorOutlet({
    super.key,
    this.initialRoute = '/',
    required this.navigatorType,
    this.parser,
    this.onExitLocalNavigation,
  }) : assert(
         navigatorType == FFRRouteType.bottomSheet ||
             navigatorType == FFRRouteType.tab,
         'FFRLocalNavigatorOutlet only supports bottomSheet and tab types.',
       );

  @override
  State<FFRLocalNavigatorOutlet> createState() =>
      _FFRLocalNavigatorOutletState();

  static FFRLocalNavigator of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<
        _InheritedLocalNavigator>();
    assert(
      inherited != null,
      'FFRLocalNavigatorOutlet.of() called outside a FFRLocalNavigatorOutlet subtree.',
    );
    return inherited!.navigator;
  }

  static FFRRouteMatch? currentMatch(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<
        _InheritedLocalNavigator>();
    return inherited?.currentMatch;
  }

  /// Closes the local navigation container.
  ///
  /// Calls the [onExitLocalNavigation] callback if provided.
  /// Use this from child widgets to dismiss the parent container
  /// (e.g., dismiss a bottom sheet).
  static void close(BuildContext context) {
    final state = context.findAncestorStateOfType<
        _FFRLocalNavigatorOutletState>();
    state?._handleExit();
  }
}

class _FFRLocalNavigatorOutletState extends State<FFRLocalNavigatorOutlet>
    with TickerProviderStateMixin {
  late FFRLocalNavigator _navigator;

  @override
  void initState() {
    super.initState();
    final parser = widget.parser ?? FFRNavigator.I.parser;
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

    final needsRebuild = oldWidget.parser != widget.parser ||
        oldWidget.initialRoute != widget.initialRoute ||
        oldWidget.navigatorType != widget.navigatorType;

    if (needsRebuild) {
      _navigator.removeListener(_onNavigatorChanged);
      _navigator.dispose();

      final parser = widget.parser ?? FFRNavigator.I.parser;
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
    if (mounted) setState(() {});
  }

  void _handleExit() {
    widget.onExitLocalNavigation?.call();
  }

  @override
  Widget build(BuildContext context) {
    final currentMatch = _navigator.current;

    if (currentMatch == null) {
      return const SizedBox.shrink();
    }

    final child = currentMatch.route.builder!(
      context,
      currentMatch.pathParams,
      currentMatch.queryParams,
    );

    return _InheritedLocalNavigator(
      navigator: _navigator,
      currentMatch: currentMatch,
      child: child,
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
