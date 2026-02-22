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
}
