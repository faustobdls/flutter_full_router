import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

void main() {
  group('FFRRouteParser Tests', () {
    final routes = [
      FFRRouteDefinition(
        id: '01HOM',
        path: '/',
        openFlow: FFROpenFlow.preLogin,
        builder: (context, path, query) => const SizedBox(),
      ),
      FFRRouteDefinition(
        id: '02POS',
        path: '/post/{id}',
        pathParams: {'id': r'[0-9]+'},
        builder: (context, path, query) => const SizedBox(),
      ),
      FFRRouteDefinition(
        id: '03USE',
        path: '/user/{username}',
        pathParams: {'username': r'[a-zA-Z]+'}, // Only letters
        builder: (context, path, query) => const SizedBox(),
      ),
    ];

    final parser = FFRRouteParser(routes);

    test('parse() matches standard route', () {
      final match = parser.parse('/');
      expect(match, isNotNull);
      expect(match!.route.id, '01HOM');
      expect(match.pathParams, isEmpty);
      expect(match.queryParams, isEmpty);
    });

    test('parse() matches route with params', () {
      final match = parser.parse('/post/123');
      expect(match, isNotNull);
      expect(match!.route.id, '02POS');
      expect(match.pathParams['id'], '123');
    });

    test('parse() ignores route with invalid regex param', () {
      final match = parser.parse('/post/abc');
      expect(match, isNull);
    });

    test('parse() handles query parameters', () {
      final match = parser.parse('/post/42?sort=asc&page=2');
      expect(match, isNotNull);
      expect(match!.route.id, '02POS');
      expect(match.pathParams['id'], '42');
      expect(match.queryParams['sort'], 'asc');
      expect(match.queryParams['page'], '2');
    });
  });

  group('FFRRouteParser Dynamic Route Tests', () {
    late FFRRouteParser parser;

    setUp(() {
      parser = FFRRouteParser([
        FFRRouteDefinition(
          id: '01HOM',
          path: '/home',
          builder: (context, p, q) => const SizedBox(),
        ),
      ]);
    });

    test('routes getter returns unmodifiable list of current routes', () {
      expect(parser.routes.length, 1);
      expect(parser.routes.first.id, '01HOM');
    });

    test('addRoute() registers a new route and it becomes parseable', () {
      parser.addRoute(
        FFRRouteDefinition(
          id: '02NEW',
          path: '/new',
          builder: (context, p, q) => const SizedBox(),
        ),
      );

      expect(parser.routes.length, 2);
      final match = parser.parse('/new');
      expect(match, isNotNull);
      expect(match!.route.id, '02NEW');
    });

    test('addRoute() replaces existing route with same id', () {
      parser.addRoute(
        FFRRouteDefinition(
          id: '01HOM',
          path: '/home-v2',
          builder: (context, p, q) => const SizedBox(),
        ),
      );

      expect(parser.routes.length, 1);
      expect(parser.routes.first.path, '/home-v2');
    });

    test('addRoutes() registers multiple routes at once', () {
      parser.addRoutes([
        FFRRouteDefinition(
          id: '03A',
          path: '/a',
          builder: (context, p, q) => const SizedBox(),
        ),
        FFRRouteDefinition(
          id: '04B',
          path: '/b',
          builder: (context, p, q) => const SizedBox(),
        ),
      ]);

      expect(parser.routes.length, 3);
      expect(parser.parse('/a'), isNotNull);
      expect(parser.parse('/b'), isNotNull);
    });

    test('removeRoute() removes an existing route by id', () {
      parser.removeRoute('01HOM');

      expect(parser.routes, isEmpty);
      expect(parser.parse('/home'), isNull);
    });

    test('removeRoute() does nothing when id does not exist', () {
      parser.removeRoute('NONEXISTENT');
      expect(parser.routes.length, 1);
    });
  });
}
