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

      nav.addRoute(FFRRouteDefinition(
        id: '99NEW',
        path: '/new-feature',
        builder: (context, p, q) => const SizedBox(),
      ));

      expect(notified, isTrue);
      nav.pushNamed('/new-feature');
      expect(nav.stack.length, 1);
      expect(nav.stack.last.route.id, '99NEW');
    });

    test('addRoute() replaces route with same id', () {
      nav.addRoute(FFRRouteDefinition(
        id: '11LOG',
        path: '/login-v2',
        openFlow: FFROpenFlow.preLogin,
        builder: (context, p, q) => const SizedBox(),
      ));

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

  group('FFRNavigator Action Registry Tests', () {
    late FFRNavigator nav;

    setUp(() {
      final parser = FFRRouteParser([
        FFRRouteDefinition(
          id: '11LOG',
          path: '/login',
          openFlow: FFROpenFlow.preLogin,
          builder: (context, p, q) => const SizedBox(),
        ),
      ]);
      nav = FFRNavigator(parser: parser);
    });

    test('registerAction() + hasAction() confirms registration', () {
      expect(nav.hasAction('logout'), isFalse);

      nav.registerAction('logout', (_) {});

      expect(nav.hasAction('logout'), isTrue);
    });

    test('executeAction() invokes the registered callback with params', () {
      Map<String, dynamic>? received;
      nav.registerAction('doSomething', (params) {
        received = params;
      });

      nav.executeAction('doSomething', params: {'key': 'value', 'count': 42});

      expect(received, isNotNull);
      expect(received!['key'], 'value');
      expect(received!['count'], 42);
    });

    test('executeAction() with no params passes empty map', () {
      Map<String, dynamic>? received;
      nav.registerAction('noParams', (params) {
        received = params;
      });

      nav.executeAction('noParams');

      expect(received, isNotNull);
      expect(received, isEmpty);
    });

    test('executeAction() does nothing if action is not registered', () {
      // Should not throw
      expect(() => nav.executeAction('ghost'), returnsNormally);
    });

    test('registerAction() replaces previous action with same name', () {
      int callCount = 0;
      nav.registerAction('action', (_) => callCount++);
      nav.registerAction('action', (_) => callCount += 10);

      nav.executeAction('action');

      expect(callCount, 10);
    });

    test('unregisterAction() removes an action by name', () {
      bool called = false;
      nav.registerAction('temp', (_) => called = true);
      expect(nav.hasAction('temp'), isTrue);

      nav.unregisterAction('temp');
      expect(nav.hasAction('temp'), isFalse);

      nav.executeAction('temp');
      expect(called, isFalse);
    });

    test('unregisterAction() does nothing if action does not exist', () {
      expect(() => nav.unregisterAction('nonexistent'), returnsNormally);
    });
  });
}
