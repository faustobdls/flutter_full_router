import 'package:flutter/material.dart';
import '../enums/route_type.dart';
import '../models/route_match.dart';
import '../navigator/custom_navigator.dart';
import '../parser/route_parser.dart';
import '../transitions/page_transitions.dart';
import 'local_navigator.dart';

/// Widget que fornece um contexto de navegação local (outlet).
///
/// [FFRLocalNavigatorOutlet] cria e expõe um [FFRLocalNavigator]
/// para a subtree via [InheritedWidget]. Isso permite navegação aninhada
/// dentro de containers como bottom sheets ou tab views.
///
/// O outlet renderiza o builder da rota atual e reconstrói quando a
/// navegação local muda, aplicando animações de transição configuradas.
///
/// Exemplo:
/// ```dart
/// FFRLocalNavigatorOutlet(
///   initialRoute: '/settings/main',
///   navigatorType: FFRRouteType.bottomSheet,
///   transitions: FFRPageTransitions.ios(),
///   onExitLocalNavigation: () => Navigator.of(context).pop(),
/// )
/// ```
class FFRLocalNavigatorOutlet extends StatefulWidget {
  final String initialRoute;
  final FFRRouteType navigatorType;
  final FFRRouteParser? parser;
  final FFRPageTransitions transitions;

  /// Callback chamado quando [pop(exitLocalNavigation: true)] é executado.
  final VoidCallback? onExitLocalNavigation;

  const FFRLocalNavigatorOutlet({
    super.key,
    this.initialRoute = '/',
    required this.navigatorType,
    this.parser,
    this.transitions = const FFRPageTransitions.ios(),
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

  /// Fecha o container de navegação local.
  static void close(BuildContext context) {
    final state = context.findAncestorStateOfType<
        _FFRLocalNavigatorOutletState>();
    state?._handleExit();
  }
}

class _FFRLocalNavigatorOutletState extends State<FFRLocalNavigatorOutlet>
    with TickerProviderStateMixin {
  late FFRLocalNavigator _navigator;
  final List<FFRRouteMatch> _previousStack = [];
  AnimationController? _animationController;
  bool _isTransitioning = false;
  bool _isForward = true;

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
    _previousStack.addAll(_navigator.stack);
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
      _previousStack.clear();

      final parser = widget.parser ?? FFRNavigator.I.parser;
      _navigator = FFRLocalNavigator(
        parser: parser,
        navigatorType: widget.navigatorType,
        initialRoute: widget.initialRoute,
      );
      _navigator.addListener(_onNavigatorChanged);
      _previousStack.addAll(_navigator.stack);
    }
  }

  @override
  void dispose() {
    _navigator.removeListener(_onNavigatorChanged);
    _navigator.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _onNavigatorChanged() {
    final currentStack = _navigator.stack;
    _isForward = currentStack.length > _previousStack.length;

    _previousStack.clear();
    _previousStack.addAll(currentStack);

    if (currentStack.isNotEmpty && mounted) {
      _isTransitioning = true;
      _animationController?.dispose();
      _animationController = AnimationController(
        vsync: this,
        duration: widget.transitions.duration,
      );

      _animationController!.forward().then((_) {
        if (mounted) {
          setState(() => _isTransitioning = false);
        }
      });

      setState(() {});
    }
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

    if (!_isTransitioning || _animationController == null) {
      return _InheritedLocalNavigator(
        navigator: _navigator,
        currentMatch: currentMatch,
        child: child,
      );
    }

    final animation = _animationController!.drive(
      CurveTween(curve: widget.transitions.curve),
    );

    final transitionChild = _buildTransition(
      context,
      child,
      animation,
      currentMatch,
    );

    return _InheritedLocalNavigator(
      navigator: _navigator,
      currentMatch: currentMatch,
      child: transitionChild,
    );
  }

  Widget _buildTransition(
    BuildContext context,
    Widget child,
    Animation<double> animation,
    FFRRouteMatch currentMatch,
  ) {
    final size = MediaQuery.of(context).size;

    switch (widget.transitions.type) {
      case FFRTransitionType.iosSlide:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final offset = _isForward
                ? Offset((1 - animation.value) * size.width, 0)
                : Offset(-animation.value * size.width, 0);
            return Transform.translate(offset: offset, child: child!);
          },
          child: child,
        );

      case FFRTransitionType.fade:
        return FadeTransition(opacity: animation, child: child);

      case FFRTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
          child: child,
        );

      case FFRTransitionType.slideUp:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - animation.value) * size.height),
              child: child!,
            );
          },
          child: child,
        );

      case FFRTransitionType.none:
        return child;

      case FFRTransitionType.custom:
        return widget.transitions.customBuilder!(animation, child);
    }
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
