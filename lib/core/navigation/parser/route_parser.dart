import '../models/route_definition.dart';
import '../models/route_match.dart';

class FFRRouteParser {
  final List<FFRRouteDefinition> routes;

  const FFRRouteParser(this.routes);

  /// Parses a given URI string into a [FFRRouteMatch]
  /// Returns null if no route matches.
  FFRRouteMatch? parse(String urlString) {
    final uri = Uri.parse(urlString);
    final path = uri.path;
    final queryParams = uri.queryParameters;

    for (final route in routes) {
      final match = _matchRoute(route, path);
      if (match != null) {
        return FFRRouteMatch(
          originalUrl: urlString,
          route: route,
          pathParams: match,
          queryParams: {
            ...route.queryParams,
            ...queryParams,
          },
        );
      }
    }

    return null;
  }



  /// Attempts to match a [FFRRouteDefinition] against a [path].
  /// Returns a map of extracted path parameters if it matches, or null otherwise.
  Map<String, String>? _matchRoute(FFRRouteDefinition route, String path) {
    if (route.path == path) {
      return {};
    }

    // Identify parameters in the route path like {uid}
    final paramNames = <String>[];
    String patternStr = route.path;

    // We replace each {param} with a regex capture group.
    // If the RouteDefinition provides a specific regex in pathParams, we use it.
    // Otherwise, we use a default: ([^/]+)
    final regex = RegExp(r'\{([a-zA-Z0-9_]+)\}');
    patternStr = patternStr.replaceAllMapped(regex, (match) {
      final paramName = match.group(1)!;
      paramNames.add(paramName);

      final customPattern = route.pathParams[paramName];
      if (customPattern != null) {
        return '($customPattern)';
      }
      return r'([^/]+)';
    });

    // We want to match the whole path exactly.
    final finalRegex = RegExp('^$patternStr\$');
    final finalMatch = finalRegex.firstMatch(path);

    if (finalMatch != null) {
      final extractedParams = <String, String>{};
      for (var i = 0; i < paramNames.length; i++) {
        // match groups are 1-indexed
        extractedParams[paramNames[i]] = finalMatch.group(i + 1)!;
      }
      return extractedParams;
    }

    return null;
  }
}
