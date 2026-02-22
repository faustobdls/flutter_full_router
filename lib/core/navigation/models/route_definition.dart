import 'package:flutter/widgets.dart';
import '../enums/open_flow.dart';
import '../enums/route_type.dart';

typedef FFRRouteWidgetBuilder = Widget Function(
  BuildContext context,
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
  final FFRRouteWidgetBuilder builder;

  const FFRRouteDefinition({
    required this.id,
    required this.path,
    required this.builder,
    this.routeType = FFRRouteType.fullPage,
    this.pathParams = const {},
    this.queryParams = const {},
    this.openFlow = FFROpenFlow.postLogin,
    this.title = '',
    this.description = '',
  });
}
