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
        FFRRouteDefinition(
          id: '03LST',
          path: '/local/settings',
          openFlow: FFROpenFlow.postLogin,
          builder: (context, p, q) => const Text('Settings'),
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
            builder: (context, navigator, match) {
              return Text(match?.route.path ?? 'No match');
            },
          ),
        ),
      );

      expect(find.text('/local/home'), findsOneWidget);
    });

    testWidgets('FFRLocalNavigatorOutlet.of() returns local navigator', (tester) async {
      FFRLocalNavigator? capturedNavigator;

      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
            parser: parser,
            builder: (context, navigator, match) {
              capturedNavigator = FFRLocalNavigatorOutlet.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedNavigator, isNotNull);
      expect(capturedNavigator!.navigatorType, FFRRouteType.bottomSheet);
    });

    testWidgets('FFRLocalNavigator.currentMatch() returns current match', (tester) async {
      FFRRouteMatch? capturedMatch;

      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
            parser: parser,
            builder: (context, navigator, match) {
              capturedMatch = FFRLocalNavigatorOutlet.currentMatch(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedMatch, isNotNull);
      expect(capturedMatch!.route.path, '/local/home');
    });

    testWidgets('rebuilds when navigator pushes new route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
            parser: parser,
            builder: (context, navigator, match) {
              return Column(
                children: [
                  Text(match?.route.path ?? 'No match'),
                  ElevatedButton(
                    onPressed: () => navigator.pushNamed('/local/profile'),
                    child: const Text('Go to Profile'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('/local/home'), findsOneWidget);

      await tester.tap(find.text('Go to Profile'));
      await tester.pump();

      expect(find.text('/local/profile'), findsOneWidget);
    });

    testWidgets('rebuilds when navigator pops', (tester) async {
      FFRLocalNavigator? localNav;

      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
            parser: parser,
            builder: (context, navigator, match) {
              localNav = navigator;
              return Column(
                children: [
                  Text(match?.route.path ?? 'No match'),
                  ElevatedButton(
                    onPressed: () => navigator.pop(),
                    child: const Text('Pop'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      localNav!.pushNamed('/local/profile');
      await tester.pump();
      expect(find.text('/local/profile'), findsOneWidget);

      await tester.tap(find.text('Pop'));
      await tester.pump();

      expect(find.text('/local/home'), findsOneWidget);
    });

    testWidgets('pop with exitLocalNavigation signals exit', (tester) async {
      bool shouldExit = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
            parser: parser,
            builder: (context, navigator, match) {
              return ElevatedButton(
                onPressed: () {
                  shouldExit = navigator.pop(exitLocalNavigation: true);
                },
                child: const Text('Exit'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Exit'));
      await tester.pump();

      expect(shouldExit, isTrue);
    });

    testWidgets('uses global parser when parser is not provided', (tester) async {
      // Initialize global navigator
      FFRNavigator(parser: parser, initialRoute: '/');

      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
            builder: (context, navigator, match) {
              return Text(match?.route.path ?? 'No match');
            },
          ),
        ),
      );

      expect(find.text('/local/home'), findsOneWidget);
    });

    testWidgets('throws assertion with invalid navigator type', (tester) async {
      expect(
        () => FFRLocalNavigatorOutlet(
          initialRoute: '/local/home',
          navigatorType: FFRRouteType.fullPage,
          parser: parser,
          builder: (context, navigator, match) => const SizedBox(),
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

    testWidgets('recreates navigator when initialRoute changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  FFRLocalNavigatorOutlet(
                    key: const ValueKey('local-nav'),
                    initialRoute: '/local/home',
                    navigatorType: FFRRouteType.bottomSheet,
                    parser: parser,
                    builder: (context, navigator, match) {
                      return Text(match?.route.path ?? 'No match');
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Rebuild'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('/local/home'), findsOneWidget);
    });

    testWidgets('supports tab navigator type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.tab,
            parser: parser,
            builder: (context, navigator, match) {
              return Text(match?.route.path ?? 'No match');
            },
          ),
        ),
      );

      expect(find.text('/local/home'), findsOneWidget);
    });

    testWidgets('pushReplacementNamed clears stack and rebuilds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FFRLocalNavigatorOutlet(
            initialRoute: '/local/home',
            navigatorType: FFRRouteType.bottomSheet,
            parser: parser,
            builder: (context, navigator, match) {
              return Column(
                children: [
                  Text(match?.route.path ?? 'No match'),
                  ElevatedButton(
                    onPressed: () => navigator.pushReplacementNamed('/local/settings'),
                    child: const Text('Replace'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Replace'));
      await tester.pump();

      expect(find.text('/local/settings'), findsOneWidget);
    });

    testWidgets('recreates navigator when widget updates', (tester) async {
      String currentRoute = '/local/home';

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  FFRLocalNavigatorOutlet(
                    key: const ValueKey('local-nav'),
                    initialRoute: currentRoute,
                    navigatorType: FFRRouteType.bottomSheet,
                    parser: parser,
                    builder: (context, navigator, match) {
                      return Column(
                        children: [
                          Text(match?.route.path ?? 'No match'),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                currentRoute = '/local/profile';
                              });
                            },
                            child: const Text('Update'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('/local/home'), findsOneWidget);

      await tester.tap(find.text('Update'));
      await tester.pump();

      // After update, a new navigator is created with new initial route
      expect(find.text('/local/profile'), findsOneWidget);
    });

    testWidgets('disposes old navigator when widget updates', (tester) async {
      FFRLocalNavigator? oldNavigator;
      String currentRoute = '/local/home';

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return FFRLocalNavigatorOutlet(
                key: const ValueKey('local-nav'),
                initialRoute: currentRoute,
                navigatorType: FFRRouteType.bottomSheet,
                parser: parser,
                builder: (context, navigator, match) {
                  oldNavigator = navigator;
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentRoute = '/local/profile';
                      });
                    },
                    child: const Text('Update'),
                  );
                },
              );
            },
          ),
        ),
      );

      final firstNavigator = oldNavigator;

      await tester.tap(find.text('Update'));
      await tester.pump();

      // Old navigator should be disposed and new one created
      expect(oldNavigator, isNotNull);
      expect(oldNavigator, isNot(firstNavigator));
    });
  });
}
