import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/post_screen.dart';
import 'screens/authors_screen.dart';
import 'screens/author_screen.dart';
import 'screens/github_repos_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/stack_clear_demo_screen.dart';
import 'screens/bottomsheet_navigator_demo_screen.dart';
import 'screens/tab_navigator_demo_screen.dart';
import 'screens/dialog_navigator_demo_screen.dart';
export 'screens/bottomsheet_navigator_demo_screen.dart'
    show
        DefaultBottomSheetContent,
        CustomBottomSheetContent,
        SettingsMainScreen,
        ProfileSettingsScreen,
        PrivacySettingsScreen,
        NotificationSettingsScreen,
        AvatarSettingsScreen,
        BlockedUsersScreen,
        NotificationChannelsScreen,
        AvatarCropScreen,
        AvatarFiltersScreen;
export 'screens/tab_navigator_demo_screen.dart'
    show
        HomeTabScreen,
        HomeItemDetailScreen,
        ExploreTabScreen,
        ExploreCategoryScreen,
        ProfileTabScreen,
        ProfileEditScreen;

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

// GitHub Repos State — populated by the /github/fetch/{username} action route
class GitHubReposState extends ChangeNotifier {
  List<Map<String, dynamic>> repos = [];
  bool loading = false;
  String? error;

  Future<void> fetchRepos(String username) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final client = HttpClient();
      final String api =
          'https://api.github.com/users/$username/repos?sort=updated&per_page=30';
      final request = await client.getUrl(Uri.parse(api));
      request.headers.set('Accept', 'application/vnd.github.v3+json');
      request.headers.set('User-Agent', 'flutter_full_router_example');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(body);
        repos = data.cast<Map<String, dynamic>>();
        loading = false;
      } else {
        error = 'GitHub API returned ${response.statusCode}';
        loading = false;
      }

      client.close();
    } catch (e) {
      error = e.toString();
      loading = false;
    }

    notifyListeners();
  }
}

final gitHubReposState = GitHubReposState();

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
      builder: (context, pathParams, queryParams) =>
          PostScreen(id: pathParams['id']!),
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
      pathParams: {
        'username': r'[a-zA-Z0-9_]+',
      }, // letters, numbers, underscore
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          AuthorScreen(username: pathParams['username']!),
    ),
    FFRRouteDefinition(
      id: '07GIT',
      path: '/github/repos',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) => const GitHubReposScreen(),
    ),
    // Action route: calls GitHub API as a service (no page rendered).
    FFRRouteDefinition(
      id: '07GFA',
      path: '/github/fetch/{username}',
      pathParams: {'username': r'[a-zA-Z0-9_-]+'},
      routeType: FFRRouteType.action,
      openFlow: FFROpenFlow.postLogin,
      action: (pathParams, queryParams) {
        gitHubReposState.fetchRepos(pathParams['username'] ?? 'faustobdls');
      },
    ),
    // Action route: executes logout logic (no page rendered).
    FFRRouteDefinition(
      id: '08LGO',
      path: '/logout',
      routeType: FFRRouteType.action,
      openFlow: FFROpenFlow.postLogin,
      action: (pathParams, queryParams) {
        authState.logout();
        FFRNavigator.I.pushReplacementNamed('/login');
      },
    ),
    FFRRouteDefinition(
      id: '09DEM',
      path: '/stack-clear-demo',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const StackClearDemoScreen(),
    ),
    // Local Navigator Demos
    // BottomSheet routes - opened via pushNamed
    FFRRouteDefinition(
      id: '10BSD',
      path: '/bottomsheet-default',
      routeType: FFRRouteType.bottomSheet,
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const DefaultBottomSheetContent(),
    ),
    FFRRouteDefinition(
      id: '11BSC',
      path: '/bottomsheet-custom',
      routeType: FFRRouteType.bottomSheet,
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const CustomBottomSheetContent(),
    ),
    // BottomSheet demo screen entry point
    FFRRouteDefinition(
      id: '12DEM',
      path: '/bottomsheet-demo',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const BottomSheetNavigatorDemoScreen(),
    ),
    FFRRouteDefinition(
      id: '11TAB',
      path: '/tab-demo',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const TabNavigatorDemoScreen(),
    ),
    FFRRouteDefinition(
      id: '12DLG',
      path: '/dialog-demo',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const DialogNavigatorDemoScreen(),
    ),
    // BottomSheet local routes - Level 1
    FFRRouteDefinition(
      id: '13LBS',
      path: '/local-settings/main',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) => const SettingsMainScreen(),
    ),
    // Level 2
    FFRRouteDefinition(
      id: '14LBP',
      path: '/local-settings/profile',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const ProfileSettingsScreen(),
    ),
    FFRRouteDefinition(
      id: '15LPR',
      path: '/local-settings/privacy',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const PrivacySettingsScreen(),
    ),
    FFRRouteDefinition(
      id: '16LNT',
      path: '/local-settings/notifications',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const NotificationSettingsScreen(),
    ),
    // Level 3
    FFRRouteDefinition(
      id: '17LAV',
      path: '/local-settings/profile/avatar',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const AvatarSettingsScreen(),
    ),
    FFRRouteDefinition(
      id: '18LBL',
      path: '/local-settings/privacy/blocked',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const BlockedUsersScreen(),
    ),
    FFRRouteDefinition(
      id: '19LCH',
      path: '/local-settings/notifications/channels',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const NotificationChannelsScreen(),
    ),
    // Level 4
    FFRRouteDefinition(
      id: '20LCR',
      path: '/local-settings/profile/avatar/crop',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) => const AvatarCropScreen(),
    ),
    FFRRouteDefinition(
      id: '21LFL',
      path: '/local-settings/profile/avatar/filters',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const AvatarFiltersScreen(),
    ),
    // Tab local routes
    FFRRouteDefinition(
      id: '22LTH',
      path: '/local-tab/home',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) => const HomeTabScreen(),
    ),
    FFRRouteDefinition(
      id: '23LTI',
      path: '/local-tab/home/item',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const HomeItemDetailScreen(),
    ),
    FFRRouteDefinition(
      id: '24LTE',
      path: '/local-tab/explore',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) => const ExploreTabScreen(),
    ),
    FFRRouteDefinition(
      id: '25LTC',
      path: '/local-tab/explore/category',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const ExploreCategoryScreen(),
    ),
    FFRRouteDefinition(
      id: '26LTP',
      path: '/local-tab/profile',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) => const ProfileTabScreen(),
    ),
    FFRRouteDefinition(
      id: '27LPE',
      path: '/local-tab/profile/edit',
      openFlow: FFROpenFlow.postLogin,
      builder: (context, pathParams, queryParams) =>
          const ProfileEditScreen(),
    ),
    FFRRouteDefinition(
      id: '23ERR',
      path: '/404',
      openFlow: FFROpenFlow.preLogin,
      builder: (context, pathParams, queryParams) => const NotFoundScreen(),
    ),
  ];

  String? authGuard(FFRRouteMatch match) {
    if (match.route.openFlow == FFROpenFlow.postLogin &&
        !authState.isLoggedIn) {
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

  // Creating the instance automatically sets FFRNavigator.I
  FFRNavigator(
    parser: parser,
    guard: authGuard,
    initialRoute: '/',
    observers: [FFRRouteLogger()],
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FFRRouterDelegate delegate;
  late final FFRRouteInformationParser infoParser;

  @override
  void initState() {
    super.initState();
    delegate = FFRRouterDelegate(FFRNavigator.I);
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
