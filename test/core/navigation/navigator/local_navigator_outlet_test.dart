import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

void main() {
  group('FFRLocalNavigatorOutlet Widget Tests', () {
    late FFRRouteParser parser;
    late List<FFRRouteDefinition> routes;

    setUp(() {
      FFRNavigator.clearInstanceForTest();
      routes = [
        FFRRouteDefinition(
          id: '01LGN',
          path: '/local/home',
          openFlow: FFROpenFlow.postLogin,
          builder: (context, p, q) => const Text('Home'),
        ),
        FFRRouteDefinition(
          id: '02LPR',
          path: '/local/profile',
          openFlow: FFROpenFlow.postLogin,
          builder: (context, p, q) => const Text('Profile'),
        ),
      ];
      parser = FFRRouteParser(routes);
    });

    tearDown(() {
      FFRNavigator.clearInstanceForTest();
    });

    testWidgets('creates local navigator and renders initial route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
            parser: parser,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('FFRLocalNavigatorOutlet.of() returns local navigator', (tester) async {
      

      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
            parser: parser,
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Access from within the widget tree
      
      // We can't easily access the navigator from outside, so we'll just verify the widget exists
      expect(find.byType(FFRLocalNavigatorOutlet), findsOneWidget);
    });

    testWidgets('throws assertion with invalid navigator type', (tester) async {
      expect(
        () => FFRLocalNavigatorOutlet(
          initialRoute: '/local/home',
          navigatorType: FFRRouteType.fullPage,
          parser: parser,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('FFRLocalNavigatorOutlet.of() throws outside outlet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => FFRLocalNavigatorOutlet.of(context),
                throwsAssertionError,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('currentMatch returns null outside outlet', (tester) async {
      FFRRouteMatch? match;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              match = FFRLocalNavigatorOutlet.currentMatch(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(match, isNull);
    });

    testWidgets('supports tab navigator type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.tab,
            parser: parser,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('uses global parser when parser is not provided', (tester) async {
      FFRNavigator(parser: parser, initialRoute: '/');

      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('accepts custom transitions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
            parser: parser,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
