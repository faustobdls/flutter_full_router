import 'package:flutter/widgets.dart';
import '../enums/open_flow.dart';
import '../enums/route_type.dart';

typedef FFRRouteWidgetBuilder =
    Widget Function(
      BuildContext context,
      Map<String, String> pathParams,
      Map<String, dynamic> queryParams,
    );

/// Signature for a route-level action callback.
///
/// When a [FFRRouteDefinition] has [routeType] == [FFRRouteType.action],
/// this function is invoked instead of [builder].
typedef FFRRouteAction =
    void Function(
      Map<String, String> pathParams,
      Map<String, dynamic> queryParams,
    );

class FFRRouteDefinition {
  final String id;
  final String path;
  final FFRRouteType routeType;

  /// Key: param name (e.g., 'uid'), Value: Regex pattern string (e.g., r'[0-9]+')
  final Map<String, String> pathParams;
  final Map<String, dynamic> queryParams;
  final FFROpenFlow openFlow;
  final String title;
  final String description;

  /// The widget builder used for page/dialog/bottomSheet routes.
  /// Required when [routeType] is NOT [FFRRouteType.action].
  final FFRRouteWidgetBuilder? builder;

  /// The action callback used when [routeType] is [FFRRouteType.action].
  /// When navigated to, the action is executed and the route is
  /// NOT pushed onto the navigation stack.
  final FFRRouteAction? action;

  const FFRRouteDefinition({
    required this.id,
    required this.path,
    this.builder,
    this.action,
    this.routeType = FFRRouteType.fullPage,
    this.pathParams = const {},
    this.queryParams = const {},
    this.openFlow = FFROpenFlow.postLogin,
    this.title = '',
    this.description = '',
  }) : assert(
         (routeType == FFRRouteType.action && action != null) ||
             (routeType != FFRRouteType.action && builder != null),
         'Action routes must provide an "action" callback. '
         'All other routes must provide a "builder".',
       );
}
