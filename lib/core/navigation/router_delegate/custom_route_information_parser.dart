import 'package:flutter/widgets.dart';

class FFRRouteInformationParser extends RouteInformationParser<String> {
  const FFRRouteInformationParser();

  @override
  Future<String> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return routeInformation.uri.toString();
  }

  @override
  RouteInformation? restoreRouteInformation(String configuration) {
    return RouteInformation(uri: Uri.parse(configuration));
  }
}
