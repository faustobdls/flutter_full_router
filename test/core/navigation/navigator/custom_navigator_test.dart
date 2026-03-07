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

      final nav = FFRNavigator(parser: parser, guard: myGuard);

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

    test(
      'pushReplacementNamed() with query parameters constructs full URL',
      () {
        final nav = FFRNavigator(parser: parser);
        nav.pushReplacementNamed('/home', queryParams: {'user': 'alice'});
        expect(nav.stack.length, 1);
        expect(nav.stack.first.queryParams['user'], 'alice');
      },
    );

    test('RouteGuard intercepts route and redirects on replaceAllFlow', () {
      String? myGuard(FFRRouteMatch match) {
        if (match.route.path == '/home') return '/login';
        return null;
      }

      final nav = FFRNavigator(parser: parser, guard: myGuard);

      // Manual push replacement to home
      nav.pushReplacementNamed('/home');

      // Should redirect to login utilizing _replaceAllPath
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.id, '11LOG');
    });
  });

  group('FFRNavigator Dynamic Route Tests', () {
    late FFRRouteParser parser;
    late FFRNavigator nav;

    setUp(() {
      parser = FFRRouteParser([
        FFRRouteDefinition(
          id: '11LOG',
          path: '/login',
          openFlow: FFROpenFlow.preLogin,
          builder: (context, p, q) => const SizedBox(),
        ),
        FFRRouteDefinition(
          id: '13ERR',
          path: '/404',
          openFlow: FFROpenFlow.preLogin,
          builder: (context, p, q) => const SizedBox(),
        ),
      ]);
      nav = FFRNavigator(parser: parser);
    });

    test('addRoute() makes a new route navigable and notifies listeners', () {
      bool notified = false;
      nav.addListener(() => notified = true);

      nav.addRoute(
        FFRRouteDefinition(
          id: '99NEW',
          path: '/new-feature',
          builder: (context, p, q) => const SizedBox(),
        ),
      );

      expect(notified, isTrue);
      nav.pushNamed('/new-feature');
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.id, '99NEW');
    });

    test('addRoute() replaces route with same id', () {
      nav.addRoute(
        FFRRouteDefinition(
          id: '11LOG',
          path: '/login-v2',
          openFlow: FFROpenFlow.preLogin,
          builder: (context, p, q) => const SizedBox(),
        ),
      );

      nav.pushNamed('/login-v2');
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.id, '11LOG');
      expect(nav.stack.last.route.path, '/login-v2');
    });

    test('addRoutes() registers multiple routes at once and notifies', () {
      bool notified = false;
      nav.addListener(() => notified = true);

      nav.addRoutes([
        FFRRouteDefinition(
          id: '20A',
          path: '/alpha',
          builder: (context, p, q) => const SizedBox(),
        ),
        FFRRouteDefinition(
          id: '21B',
          path: '/beta',
          builder: (context, p, q) => const SizedBox(),
        ),
      ]);

      expect(notified, isTrue);
      nav.pushNamed('/alpha');
      nav.pushNamed('/beta');
      expect(nav.stack.length, 2);
    });

    test('removeRoute() makes a route no longer navigable and notifies', () {
      bool notified = false;
      nav.addListener(() => notified = true);

      nav.removeRoute('11LOG');

      expect(notified, isTrue);
      nav.pushNamed('/login');
      // Falls back to /404
      expect(nav.stack.first.route.path, '/404');
    });

    test('removeRoute() does nothing if id does not exist', () {
      bool notified = false;
      nav.addListener(() => notified = true);

      nav.removeRoute('NONEXISTENT');

      expect(notified, isTrue);
      expect(parser.routes.length, 2);
    });
  });

  group('FFRNavigator Action Route Tests', () {
    late FFRNavigator nav;

    setUp(() {
      final parser = FFRRouteParser([
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
      ]);
      nav = FFRNavigator(parser: parser);
    });

    test('action route executes callback and does NOT push to stack', () {
      bool actionCalled = false;
      nav.parser.addRoute(
        FFRRouteDefinition(
          id: '20ACT',
          path: '/do-something',
          routeType: FFRRouteType.action,
          action: (pathParams, queryParams) {
            actionCalled = true;
          },
        ),
      );

      // Navigate to initial route first
      nav.pushNamed('/login');
      expect(nav.stack.length, 1);

      // Navigate to the action route
      nav.pushNamed('/do-something');

      // Action was called
      expect(actionCalled, isTrue);
      // Stack did NOT grow — action routes are not pushed
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.id, '11LOG');
    });

    test('action route receives pathParams correctly', () {
      Map<String, String>? receivedPath;
      nav.parser.addRoute(
        FFRRouteDefinition(
          id: '21ACT',
          path: '/action/{id}',
          pathParams: {'id': r'[0-9]+'},
          routeType: FFRRouteType.action,
          action: (pathParams, queryParams) {
            receivedPath = pathParams;
          },
        ),
      );

      nav.pushNamed('/login');
      nav.pushNamed('/action/42');

      expect(receivedPath, isNotNull);
      expect(receivedPath!['id'], '42');
      // Stack unchanged
      expect(nav.stack.length, 1);
    });

    test('action route receives queryParams correctly', () {
      Map<String, dynamic>? receivedQuery;
      nav.parser.addRoute(
        FFRRouteDefinition(
          id: '22ACT',
          path: '/action-query',
          routeType: FFRRouteType.action,
          action: (pathParams, queryParams) {
            receivedQuery = queryParams;
          },
        ),
      );

      nav.pushNamed('/login');
      nav.pushNamed('/action-query', queryParams: {'key': 'value'});

      expect(receivedQuery, isNotNull);
      expect(receivedQuery!['key'], 'value');
      expect(nav.stack.length, 1);
    });

    test('pushReplacementNamed with action route does not clear stack', () {
      nav.pushNamed('/login');
      expect(nav.stack.length, 1);

      bool actionCalled = false;
      nav.parser.addRoute(
        FFRRouteDefinition(
          id: '23ACT',
          path: '/replace-action',
          routeType: FFRRouteType.action,
          action: (pathParams, queryParams) {
            actionCalled = true;
          },
        ),
      );

      nav.pushReplacementNamed('/replace-action');

      expect(actionCalled, isTrue);
      // Stack should still have the original route since action doesn't touch it
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.id, '11LOG');
    });
  });
}
