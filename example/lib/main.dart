import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/post_screen.dart';
import 'screens/authors_screen.dart';
import 'screens/author_screen.dart';
import 'screens/not_found_screen.dart';

// Dummy Authentication State
class AuthState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

// Global AuthState instance
final authState = AuthState();

late FFRNavigator globalNavigator;

void main() {
  final routes = <FFRRouteDefinition>[
    FFRRouteDefinition(
      id: '01SPL',
      path: '/',
      openFlow: FFROpenFlow.preLogin, // Open to all, logic inside builder
      builder: (context, pathParams, queryParams) => const SplashScreen(),
    ),
    FFRRouteDefinition(
      id: '02LOG',
      path: '/login',
      openFlow: FFROpenFlow.preLogin,
      builder: (context, pathParams, queryParams) => const LoginScreen(),
    ),
    FFRRouteDefinition(
      id: '03HOM',
      path: '/home',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) => const HomeScreen(),
    ),
    FFRRouteDefinition(
      id: '04POS',
      path: '/post/{id}',
      pathParams: {'id': r'[0-9]+'},
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) => PostScreen(id: pathParams['id']!),
    ),
    FFRRouteDefinition(
      id: '05ATS',
      path: '/authors',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) => const AuthorsScreen(),
    ),
    FFRRouteDefinition(
      id: '06AUT',
      path: '/author/{username}',
      pathParams: {'username': r'[a-zA-Z0-9_]+'}, // letters, numbers, underscore
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) => AuthorScreen(username: pathParams['username']!),
    ),
    FFRRouteDefinition(
      id: '07ERR',
      path: '/404',
      openFlow: FFROpenFlow.preLogin,
      builder: (context, pathParams, queryParams) => const NotFoundScreen(),
    ),
  ];

  String? authGuard(FFRRouteMatch match) {
    if (match.route.openFlow == FFROpenFlow.postLogin && !authState.isLoggedIn) {
      return '/login';
    }
    if (match.route.openFlow == FFROpenFlow.preLogin && authState.isLoggedIn) {
      // Don't redirect if it's splash, let splash decide what to do
      if (match.route.path != '/') {
        return '/home';
      }
    }
    return null;
  }

  final parser = FFRRouteParser(routes);
  
  globalNavigator = FFRNavigator(
    parser: parser,
    guard: authGuard,
    initialRoute: '/', 
    observers: [FFRRouteLogger()],
  );

  runApp(MyApp(navigator: globalNavigator));
}

class MyApp extends StatefulWidget {
  final FFRNavigator navigator;

  const MyApp({super.key, required this.navigator});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FFRRouterDelegate delegate;
  late final FFRRouteInformationParser infoParser;

  @override
  void initState() {
    super.initState();
    delegate = FFRRouterDelegate(widget.navigator);
    infoParser = const FFRRouteInformationParser();
  }

  @override
  void dispose() {
    delegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Custom Navigation Router',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerDelegate: delegate,
      routeInformationParser: infoParser,
    );
  }
}
