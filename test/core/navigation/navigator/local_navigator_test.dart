import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

void main() {
  group('FFRLocalNavigator Unit Tests', () {
    late FFRRouteParser parser;
    late List<FFRRouteDefinition> routes;

    setUp(() {
      FFRNavigator.clearInstanceForTest();
      routes = [
        FFRRouteDefinition(
          id: '01LGN',
          path: '/local/home',
          openFlow: FFROpenFlow.postLogin,
          builder: (context, p, q) => const SizedBox(),
        ),
        FFRRouteDefinition(
          id: '02LPR',
          path: '/local/profile',
          openFlow: FFROpenFlow.postLogin,
          builder: (context, p, q) => const SizedBox(),
        ),
        FFRRouteDefinition(
          id: '03LST',
          path: '/local/settings',
          openFlow: FFROpenFlow.postLogin,
          builder: (context, p, q) => const SizedBox(),
        ),
        FFRRouteDefinition(
          id: '04LAC',
          path: '/local/action',
          routeType: FFRRouteType.action,
          openFlow: FFROpenFlow.postLogin,
          action: (p, q) {},
        ),
      ];
      parser = FFRRouteParser(routes);
    });

    tearDown(() {
      FFRNavigator.clearInstanceForTest();
    });

    group('Constructor & Initialization', () {
      test('creates local navigator with bottomSheet type', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );

        expect(localNav.navigatorType, FFRRouteType.bottomSheet);
        expect(localNav.initialRoute, '/local/home');
        expect(localNav.parser, parser);
      });

      test('creates local navigator with tab type', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.tab,
          initialRoute: '/local/home',
        );

        expect(localNav.navigatorType, FFRRouteType.tab);
      });

      test('throws assertion error with invalid navigator type', () {
        expect(
          () => FFRLocalNavigator(
            parser: parser,
            navigatorType: FFRRouteType.fullPage,
            initialRoute: '/local/home',
          ),
          throwsAssertionError,
        );
      });

      test('pushes initial route to stack', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );

        expect(localNav.stack.length, 1);
        expect(localNav.stack.first.route.path, '/local/home');
      });

      test('does not push action routes to stack', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/action',
        );

        expect(localNav.stack.isEmpty, isTrue);
      });

      test('stack is empty when initial route is invalid', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/nonexistent',
        );

        expect(localNav.stack.isEmpty, isTrue);
      });

      test('stack returns unmodifiable list', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );

        expect(() => localNav.stack.add(localNav.stack.first), throwsA(isA<UnsupportedError>()));
      });
    });

    group('Getters', () {
      test('canPop returns true when stack has more than one route', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        localNav.pushNamed('/local/profile');

        expect(localNav.canPop, isTrue);
      });

      test('canPop returns false when stack has only one route', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );

        expect(localNav.canPop, isFalse);
      });

      test('current returns the last route match', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );

        expect(localNav.current, isNotNull);
        expect(localNav.current!.route.path, '/local/home');
      });

      test('current returns null when stack is empty', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/nonexistent',
        );

        expect(localNav.current, isNull);
      });
    });

    group('Navigation', () {
      test('pushNamed adds route to stack', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        localNav.pushNamed('/local/profile');

        expect(localNav.stack.length, 2);
        expect(localNav.stack.last.route.path, '/local/profile');
      });

      test('pushNamed with queryParams merges parameters', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        localNav.pushNamed('/local/profile', queryParams: {'tab': 'edit'});

        expect(localNav.stack.last.queryParams['tab'], 'edit');
      });

      test('pushNamed ignores action routes', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        final initialLength = localNav.stack.length;
        localNav.pushNamed('/local/action');

        expect(localNav.stack.length, initialLength);
      });

      test('pushNamed ignores invalid routes', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        final initialLength = localNav.stack.length;
        localNav.pushNamed('/nonexistent');

        expect(localNav.stack.length, initialLength);
      });

      test('pushNamed notifies listeners', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        var notified = false;
        localNav.addListener(() => notified = true);

        localNav.pushNamed('/local/profile');

        expect(notified, isTrue);
      });

      test('pushReplacementNamed clears stack and adds new route', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        localNav.pushNamed('/local/profile');
        expect(localNav.stack.length, 2);

        localNav.pushReplacementNamed('/local/settings');

        expect(localNav.stack.length, 1);
        expect(localNav.stack.first.route.path, '/local/settings');
      });

      test('pushReplacementNamed with queryParams merges parameters', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        localNav.pushReplacementNamed('/local/profile', queryParams: {'mode': 'admin'});

        expect(localNav.stack.first.queryParams['mode'], 'admin');
      });

      test('pushReplacementNamed ignores action routes', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        final initialLength = localNav.stack.length;
        localNav.pushReplacementNamed('/local/action');

        expect(localNav.stack.length, initialLength);
      });

      test('pushReplacementNamed ignores invalid routes', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        final initialLength = localNav.stack.length;
        localNav.pushReplacementNamed('/nonexistent');

        expect(localNav.stack.length, initialLength);
      });

      test('pushReplacementNamed notifies listeners', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        var notified = false;
        localNav.addListener(() => notified = true);

        localNav.pushReplacementNamed('/local/settings');

        expect(notified, isTrue);
      });
    });

    group('Pop', () {
      test('pop removes route from stack when length > 1', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        localNav.pushNamed('/local/profile');
        expect(localNav.stack.length, 2);

        localNav.pop();

        expect(localNav.stack.length, 1);
        expect(localNav.stack.first.route.path, '/local/home');
      });

      test('pop does nothing when stack has only one route', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        expect(localNav.stack.length, 1);

        localNav.pop();

        expect(localNav.stack.length, 1);
      });

      test('pop notifies listeners', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        localNav.pushNamed('/local/profile');
        var notified = false;
        localNav.addListener(() => notified = true);

        localNav.pop();

        expect(notified, isTrue);
      });

      test('pop with exitLocalNavigation returns true', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );

        final shouldExit = localNav.pop(exitLocalNavigation: true);

        expect(shouldExit, isTrue);
        expect(localNav.stack.length, 1);
      });

      test('pop without exitLocalNavigation returns false when stack has one route', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );

        final shouldExit = localNav.pop();

        expect(shouldExit, isFalse);
      });

      test('pop returns false when exitLocalNavigation is false', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        localNav.pushNamed('/local/profile');

        final shouldExit = localNav.pop(exitLocalNavigation: false);

        expect(shouldExit, isFalse);
        expect(localNav.stack.length, 1);
      });
    });

    group('Clear', () {
      test('clear removes all routes from stack', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        localNav.pushNamed('/local/profile');
        expect(localNav.stack.length, 2);

        localNav.clear();

        expect(localNav.stack.isEmpty, isTrue);
      });

      test('clear notifies listeners', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );
        var notified = false;
        localNav.addListener(() => notified = true);

        localNav.clear();

        expect(notified, isTrue);
      });
    });

    group('Dynamic Route Management', () {
      test('can navigate to dynamically added routes', () {
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );

        parser.addRoute(
          FFRRouteDefinition(
            id: '99DYN',
            path: '/local/dynamic',
            builder: (context, p, q) => const SizedBox(),
          ),
        );

        localNav.pushNamed('/local/dynamic');

        expect(localNav.stack.length, 2);
        expect(localNav.stack.last.route.id, '99DYN');
      });

      test('navigation fails after route is removed', () {
        parser.removeRoute('01LGN');
        
        final localNav = FFRLocalNavigator(
          parser: parser,
          navigatorType: FFRRouteType.bottomSheet,
          initialRoute: '/local/home',
        );

        // Stack should be empty because initial route no longer exists
        expect(localNav.stack.isEmpty, isTrue);
      });
    });
  });
}
