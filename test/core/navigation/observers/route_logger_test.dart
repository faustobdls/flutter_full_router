import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

// Since log cannot be directly tested via standard test matchers without overriding the zone,
// we instead ensure that the Logger method completes execution without throwing exceptions
// and gracefully handles null settings names.
void main() {
  group('FFRRouteLogger Tests', () {
    late FFRRouteLogger logger;
    late Route<dynamic> routeWithname;
    late Route<dynamic> routeWithoutname;
    late Route<dynamic> previousRoute;

    setUp(() {
      logger = FFRRouteLogger(logPrefix: 'TestLogger');

      routeWithname = MaterialPageRoute(
        settings: const RouteSettings(name: '/home'),
        builder: (_) => const SizedBox(),
      );

      routeWithoutname = MaterialPageRoute(builder: (_) => const SizedBox());

      previousRoute = MaterialPageRoute(
        settings: const RouteSettings(name: '/login'),
        builder: (_) => const SizedBox(),
      );
    });

    test('didPush executes without throwing errors', () {
      expect(
        () => logger.didPush(routeWithname, previousRoute),
        returnsNormally,
      );
      expect(
        () => logger.didPush(routeWithoutname, previousRoute),
        returnsNormally,
      );
    });

    test('didPop executes without throwing errors', () {
      expect(
        () => logger.didPop(routeWithname, previousRoute),
        returnsNormally,
      );
      expect(
        () => logger.didPop(routeWithoutname, previousRoute),
        returnsNormally,
      );
    });

    test('didRemove executes without throwing errors', () {
      expect(
        () => logger.didRemove(routeWithname, previousRoute),
        returnsNormally,
      );
      expect(
        () => logger.didRemove(routeWithoutname, previousRoute),
        returnsNormally,
      );
    });

    test('didReplace executes without throwing errors', () {
      expect(
        () =>
            logger.didReplace(newRoute: routeWithname, oldRoute: previousRoute),
        returnsNormally,
      );
      expect(
        () => logger.didReplace(
          newRoute: routeWithoutname,
          oldRoute: previousRoute,
        ),
        returnsNormally,
      );
      // Testing null newRoute (technically shouldn't happen natively, but good for coverage/robustness)
      expect(
        () => logger.didReplace(newRoute: null, oldRoute: previousRoute),
        returnsNormally,
      );
    });
  });
}
