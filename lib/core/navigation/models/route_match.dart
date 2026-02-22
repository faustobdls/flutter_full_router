import 'route_definition.dart';

class FFRRouteMatch {
  final String originalUrl;
  final FFRRouteDefinition route;
  final Map<String, String> pathParams;
  final Map<String, dynamic> queryParams;

  const FFRRouteMatch({
    required this.originalUrl,
    required this.route,
    this.pathParams = const {},
    this.queryParams = const {},
  });
}
