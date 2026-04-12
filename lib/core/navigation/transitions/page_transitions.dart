import 'package:flutter/widgets.dart';

/// Signature for a custom page transition builder.
///
/// Receives the animation controller and the child widget to animate.
typedef FFRPageTransitionBuilder = Widget Function(
  Animation<double> animation,
  Widget child,
);

/// Built-in page transition types.
enum FFRTransitionType {
  /// iOS-style slide from right to left (push) / left to right (pop).
  iosSlide,

  /// Fade in/out transition.
  fade,

  /// Scale up/down transition.
  scale,

  /// Slide up from bottom (Material style).
  slideUp,

  /// No animation.
  none,

  /// Custom transition using a user-provided builder.
  custom,
}

/// Configuration for page transitions in [FFRLocalNavigatorOutlet].
///
/// Allows customization of the transition type, duration, and curve.
/// When using [FFRTransitionType.custom], a [customBuilder] must be provided.
class FFRPageTransitions {
  /// The type of transition to use.
  final FFRTransitionType type;

  /// Duration of the transition animation.
  final Duration duration;

  /// Curve of the transition animation.
  final Curve curve;

  /// Custom transition builder, required when [type] is [FFRTransitionType.custom].
  final FFRPageTransitionBuilder? customBuilder;

  const FFRPageTransitions({
    this.type = FFRTransitionType.iosSlide,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
    this.customBuilder,
  });

  /// iOS-style slide transition (right-to-left push).
  const FFRPageTransitions.ios({
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOutCubic,
  })  : type = FFRTransitionType.iosSlide,
        customBuilder = null;

  /// Fade transition.
  const FFRPageTransitions.fade({
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
  })  : type = FFRTransitionType.fade,
        customBuilder = null;

  /// Scale transition.
  const FFRPageTransitions.scale({
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
  })  : type = FFRTransitionType.scale,
        customBuilder = null;

  /// Slide up from bottom (Material style).
  const FFRPageTransitions.slideUp({
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
  })  : type = FFRTransitionType.slideUp,
        customBuilder = null;

  /// No animation.
  const FFRPageTransitions.none()
      : type = FFRTransitionType.none,
        duration = Duration.zero,
        curve = Curves.linear,
        customBuilder = null;

  /// Custom transition with user-provided builder.
  const FFRPageTransitions.custom({
    required this.customBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
  }) : type = FFRTransitionType.custom;

  /// Default transitions for iOS-style navigation.
  static const iosDefault = FFRPageTransitions.ios();

  /// Default transitions for Material-style navigation.
  static const materialDefault = FFRPageTransitions.slideUp();

  /// No transition.
  static const noneDefault = FFRPageTransitions.none();

  FFRPageTransitions copyWith({
    FFRTransitionType? type,
    Duration? duration,
    Curve? curve,
    FFRPageTransitionBuilder? customBuilder,
  }) {
    return FFRPageTransitions(
      type: type ?? this.type,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      customBuilder: customBuilder ?? this.customBuilder,
    );
  }

  /// Creates a [PageRoute] that wraps [child] with the configured transition.
  ///
  /// The [isBack] parameter determines the direction of the transition:
  /// - `false` (push): new page enters from right to left
  /// - `true` (pop): old page exits from left to right
  PageRoute<T> createRoute<T>({
    required Widget child,
    bool isBack = false,
    String? name,
  }) {
    switch (type) {
      case FFRTransitionType.iosSlide:
        return _FFRIosSlideRoute(
          child: child,
          transitionDuration: duration,
          curve: curve,
          isBack: isBack,
          
        );
      case FFRTransitionType.fade:
        return _FFRFadeRoute(
          child: child,
          transitionDuration: duration,
          curve: curve,
          isBack: isBack,
          
        );
      case FFRTransitionType.scale:
        return _FFRScaleRoute(
          child: child,
          transitionDuration: duration,
          curve: curve,
          isBack: isBack,
          
        );
      case FFRTransitionType.slideUp:
        return _FFRSlideUpRoute(
          child: child,
          transitionDuration: duration,
          curve: curve,
          isBack: isBack,
          
        );
      case FFRTransitionType.none:
        return _FFRNoAnimationRoute(
          child: child,
          
        );
      case FFRTransitionType.custom:
        return _FFRCustomTransitionRoute(
          child: child,
          builder: customBuilder!,
          transitionDuration: duration,
          curve: curve,
          isBack: isBack,
          
        );
    }
  }
}

// ============================================================================
// Route Implementations
// ============================================================================

/// Base class for FFR page routes with transition support.
abstract class _FFRTransitionRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration _transitionDuration;
  final Curve curve;
  final bool isBack;

  _FFRTransitionRoute({
    required this.child,
    required Duration transitionDuration,
    required this.curve,
    this.isBack = false,
    String? name,
  }) : _transitionDuration = transitionDuration,
       super(settings: RouteSettings(name: name));

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => true;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => _transitionDuration;
}

/// iOS-style slide route: pushes from right to left.
class _FFRIosSlideRoute<T> extends _FFRTransitionRoute<T> {
  _FFRIosSlideRoute({
    required super.child,
    required super.transitionDuration,
    required super.curve,
    super.isBack,
    
    
  });

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    if (isBack) {
      // Pop: current page exits from current position to right
      return AnimatedBuilder(
        animation: curvedAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              curvedAnimation.value * screenWidth,
              0,
            ),
            child: child,
          );
        },
        child: child,
      );
    } else {
      // Push: new page enters from right to current position
      return AnimatedBuilder(
        animation: curvedAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              (1 - curvedAnimation.value) * screenWidth,
              0,
            ),
            child: child,
          );
        },
        child: child,
      );
    }
  }
}

/// Fade route: fades in/out.
class _FFRFadeRoute<T> extends _FFRTransitionRoute<T> {
  _FFRFadeRoute({
    required super.child,
    required super.transitionDuration,
    required super.curve,
    super.isBack,
    
    
  });

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return FadeTransition(
      opacity: curvedAnimation,
      child: child,
    );
  }
}

/// Scale route: scales up (push) / down (pop).
class _FFRScaleRoute<T> extends _FFRTransitionRoute<T> {
  _FFRScaleRoute({
    required super.child,
    required super.transitionDuration,
    required super.curve,
    super.isBack,
    
    
  });

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return ScaleTransition(
      scale: curvedAnimation,
      child: child,
    );
  }
}

/// Slide up route: slides from bottom to top.
class _FFRSlideUpRoute<T> extends _FFRTransitionRoute<T> {
  _FFRSlideUpRoute({
    required super.child,
    required super.transitionDuration,
    required super.curve,
    super.isBack,
    
    
  });

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    if (isBack) {
      return AnimatedBuilder(
        animation: curvedAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              curvedAnimation.value * screenHeight,
            ),
            child: child,
          );
        },
        child: child,
      );
    } else {
      return AnimatedBuilder(
        animation: curvedAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              (1 - curvedAnimation.value) * screenHeight,
            ),
            child: child,
          );
        },
        child: child,
      );
    }
  }
}

/// No animation route.
class _FFRNoAnimationRoute<T> extends _FFRTransitionRoute<T> {
  _FFRNoAnimationRoute({
    required super.child,
    
    
  }) : super(
         transitionDuration: Duration.zero,
         curve: Curves.linear,
       );

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }

  @override
  Duration get transitionDuration => Duration.zero;
}

/// Custom transition route.
class _FFRCustomTransitionRoute<T> extends _FFRTransitionRoute<T> {
  final FFRPageTransitionBuilder builder;

  _FFRCustomTransitionRoute({
    required super.child,
    required this.builder,
    required super.transitionDuration,
    required super.curve,
    super.isBack,
    
    
  });

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(animation, child);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return builder(animation, child);
  }
}
