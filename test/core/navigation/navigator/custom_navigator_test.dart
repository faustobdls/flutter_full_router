import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

void main() {
  group('FFRNavigator Tests', () {
    late FFRRouteParser parser;
    late List<FFRRouteDefinition> routes;

    setUp(() {
      routes = [
        FFRRouteDefinition(
          id: '11LOG',
          path: '/login',
          openFlow: FFROpenFlow.preLogin,
          builder: (context, p, q) => const SizedBox(),
        ),
        FFRRouteDefinition(
          id: '12HOM',
          path: '/home',
          openFlow: FFROpenFlow.postLogin,
          builder: (context, p, q) => const SizedBox(),
        ),
        FFRRouteDefinition(
          id: '13ERR',
          path: '/404',
          openFlow: FFROpenFlow.preLogin,
          builder: (context, p, q) => const SizedBox(),
        ),
      ];
      parser = FFRRouteParser(routes);
    });

    test('Initial stack is empty', () {
      final nav = FFRNavigator(parser: parser, initialRoute: '/login');
      expect(nav.stack.length, 0);
    });

    test('Fallback to notFoundRoute if route doesn\'t exist', () {
      final nav = FFRNavigator(parser: parser);
      nav.pushNamed('/does_not_exist');
      expect(nav.stack.length, 1);
      expect(nav.stack.first.route.path, '/404');
    });

    test('pushNamed() adds to stack', () {
      final nav = FFRNavigator(parser: parser);
      nav.pushNamed('/home');
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.path, '/home');
    });

    test('pop() removes from stack if length > 1', () {
      final nav = FFRNavigator(parser: parser);
      nav.pushNamed('/home');
      nav.pushNamed('/login');
      expect(nav.stack.length, 2);
      
      nav.pop();
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.path, '/home');
      
      // Attempt pop with length 1 (should be ignored)
      nav.pop();
      expect(nav.stack.length, 1);
    });

    test('pushReplacementNamed() clears stack and adds new', () {
      final nav = FFRNavigator(parser: parser);
      nav.pushNamed('/home');
      nav.pushNamed('/login');
      expect(nav.stack.length, 2);
      
      nav.pushReplacementNamed('/home');
      expect(nav.stack.length, 1);
      expect(nav.stack.first.route.path, '/home');
    });

    test('pushReplacementNamed() with 404 does not clear stack', () {
      final nav = FFRNavigator(parser: parser);
      nav.pushNamed('/home');
      expect(nav.stack.length, 1);
      
      nav.pushReplacementNamed('/does_not_exist');
      expect(nav.stack.length, 2);
      expect(nav.stack.last.route.path, '/404');
    });

    test('pushNamed() navigates correctly', () {
      final nav = FFRNavigator(parser: parser);
      nav.pushNamed('/home');
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.id, '12HOM');
    });

    test('RouteGuard intercepts route and redirects', () {
      // Mock guard that forces login if trying to access home
      String? myGuard(FFRRouteMatch match) {
        if (match.route.path == '/home') return '/login';
        return null;
      }

      final nav = FFRNavigator(
        parser: parser, 
        guard: myGuard,
      );

      // Manual push to home
      nav.pushNamed('/home');
      
      // Should redirect to login 
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.id, '11LOG');
    });
    
    test('setNewRoutePath() clears and adds new path from external', () {
      final nav = FFRNavigator(parser: parser);
      nav.pushNamed('/404');
      
      nav.setNewRoutePath('/home');
      expect(nav.stack.length, 1);
      expect(nav.stack.first.route.id, '12HOM');
    });

    test('history getter returns the stack', () {
      final nav = FFRNavigator(parser: parser);
      nav.pushNamed('/login');
      expect(nav.history.length, 1);
      expect(nav.history.first.route.path, '/login');
    });

    test('pushNamed() with query parameters constructs full URL', () {
      final nav = FFRNavigator(parser: parser);
      // Even if route doesn't explicitly define them, they are kept in the match
      nav.pushNamed('/home', queryParams: {'user': 'john'});
      expect(nav.stack.length, 1);
      expect(nav.stack.first.queryParams['user'], 'john');
    });

    test('pushReplacementNamed() with query parameters constructs full URL', () {
      final nav = FFRNavigator(parser: parser);
      nav.pushReplacementNamed('/home', queryParams: {'user': 'alice'});
      expect(nav.stack.length, 1);
      expect(nav.stack.first.queryParams['user'], 'alice');
    });

    test('RouteGuard intercepts route and redirects on replaceAllFlow', () {
      String? myGuard(FFRRouteMatch match) {
        if (match.route.path == '/home') return '/login';
        return null;
      }

      final nav = FFRNavigator(
        parser: parser, 
        guard: myGuard,
      );

      // Manual push replacement to home
      nav.pushReplacementNamed('/home');
      
      // Should redirect to login utilizing _replaceAllPath
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.id, '11LOG');
    });
  });
}
