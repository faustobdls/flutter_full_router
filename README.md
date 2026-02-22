# Flutter Full Router (FFR)

A powerful, dependency-free navigation engine built from the ground up for Flutter using the native `Router` API. Forget complex third-party routing libraries—FFR gives you total control over your navigation stack, URL parameter extraction, authentication guarding, dynamic named routing, and custom modal/bottom sheet overlays.

## Why FFR?

Flutter's Navigator 2.0 (Router API) is notoriously verbose. FFR wraps this complexity into a clean, reactive state engine (`FFRNavigator`) that mimics the simplicity of URL-based navigation while supercharging it with advanced app-centric features.

**Key Features:**

- **Zero Dependencies:** Written entirely in Dart/Flutter. Connect it straight into `MaterialApp.router`.
- **Dynamic URL Extraction:** Built-in `FFRRouteParser` transforms `/{id}` or `/{username}` directly into Maps for your widget builders.
- **Route Types:** Effortlessly push full pages, `Dialog`s, or `ModalBottomSheet`s directly via URL. FFR native Pages (`FFRDialogPage`, `FFRBottomSheetPage`) handle the back-button and OS history correctly.
- **Guard Interceptors:** Centralized `FFRRouteGuard` lets you intercept and redirect flows (e.g., kicking unauthenticated users back to `/login`) before the UI even begins to build.
- **State-driven Navigation:** Listen to stack changes seamlessly with `ChangeNotifier` and access your entire navigation history (`FFRNavigator.history`) at any time.
- **Observers:** First-class support for `NavigatorObserver`, including a built-in `FFRRouteLogger` for clean debugging.
- **Named Routes via Templates:** Supports strongly-typed identifiers and can programmatically push named templates like `globalNavigator.pushNamed('/user/{username}', pathParams: {'username': 'fausto'})`.

## Architecture & How it Works

The architecture is divided into clear responsibilities:

1. **Definitions (`FFRRouteDefinition`)**:
   You define a list of these. Each definition asserts its path (e.g. `/home`), its type (`fullPage`, `dialog`, `bottomSheet`), its flow restrictions (`FFROpenFlow.postLogin`), and a `builder` that receives parsed Path and Query parameters to return a Widget.

2. **The Parser (`FFRRouteParser`)**:
   Converts literal strings like `/post/123?ref=social` against your definitions. It extracts `id=123` into `pathParams` and `ref=social` into `queryParams`, returning an `FFRRouteMatch`.

3. **The Engine (`FFRNavigator`)**:
   The heart of the system. Calling `pushNamed('/route')` signals the parser. If matched, it passes through the configured **Guard**. If allowed, it modifies the internal `stack` list and notifies listeners.
   - **History Getter**: You can read `navigator.history` safely anywhere. Because FFR models navigation as a stack, this getter simply reflects the current stack hierarchy!

4. **The Delegates (`FFRRouterDelegate` & `FFRRouteInformationParser`)**:
   These bridge FFR into Flutter's `MaterialApp.router`. The Information Parser extracts the URL from the browser (or initial OS intent), and the Delegate maps the internal `FFRNavigator.stack` into a declarative list of Flutter `Page` objects.

## Quick Start

### 1. Define your routes

```dart
import 'package:flutter_full_router/flutter_full_router.dart';

final routes = <FFRRouteDefinition>[
  FFRRouteDefinition(
    id: '01SPL',
    path: '/',
    openFlow: FFROpenFlow.preLogin,
    builder: (context, pathParams, queryParams) => const SplashScreen(),
  ),
  FFRRouteDefinition(
    id: '02POS',
    path: '/post/{id}',
    pathParams: {'id': r'[0-9]+'}, // Regex constraint
    openFlow: FFROpenFlow.postLogin,
    builder: (context, pathParams, queryParams) => PostScreen(id: pathParams['id']!),
  ),
];
```

### 2. Configure the Navigator

```dart
final parser = FFRRouteParser(routes);

final globalNavigator = FFRNavigator(
  parser: parser,
  initialRoute: '/',
  notFoundRoute: '/404',
  observers: [FFRRouteLogger()],
  guard: (match) {
    if (match.route.openFlow == FFROpenFlow.postLogin && !isLoggedIn) {
      return '/login'; // Intercept!
    }
    return null;
  },
);
```

### 3. Hook into MaterialApp

Create the delegates and feed them into `MaterialApp.router`.

```dart
class _MyAppState extends State<MyApp> {
  late final FFRRouterDelegate delegate;
  late final FFRRouteInformationParser infoParser;

  @override
  void initState() {
    super.initState();
    delegate = FFRRouterDelegate(globalNavigator);
    infoParser = const FFRRouteInformationParser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: delegate,
      routeInformationParser: infoParser,
      title: 'My FFR App',
    );
  }
}
```

### 4. Navigate!

```dart
// Push a simple URL
globalNavigator.pushNamed('/settings');

// Or replace the whole stack
globalNavigator.pushReplacementNamed('/login');

// Push using templates and variables
globalNavigator.pushNamed(
  '/user/{username}',
  pathParams: {'username': 'johndoe'},
  queryParams: {'sort': 'asc'}
);
```

Check out the `example/` folder within the package for a comprehensive working demonstration including modals, authentication flows, and parameterized routing.
