# Flutter Full Router (FFR)

A powerful, dependency-free navigation engine built from the ground up for Flutter using the native `Router` API. Forget complex third-party routing libraries—FFR gives you total control over your navigation stack, URL parameter extraction, authentication guarding, dynamic named routing, custom modal/bottom sheet overlays, **runtime route registration**, and **action routes**.

## Why FFR?

Flutter's Navigator 2.0 (Router API) is notoriously verbose. FFR wraps this complexity into a clean, reactive state engine (`FFRNavigator`) that mimics the simplicity of URL-based navigation while supercharging it with advanced app-centric features.

**Key Features:**

- **Zero Dependencies:** Written entirely in Dart/Flutter. Connect it straight into `MaterialApp.router`.
- **Global Singleton Access:** Use `FFRNavigator.I` anywhere in your app to push/pop routes without passing instances around!
- **Dynamic URL Extraction:** Built-in `FFRRouteParser` transforms `/{id}` or `/{username}` directly into Maps for your widget builders.
- **Route Types:** Effortlessly push full pages, `Dialog`s, `ModalBottomSheet`s, or `Action`s directly via URL. FFR native Pages (`FFRDialogPage`, `FFRBottomSheetPage`) handle the back-button and OS history correctly.
- **Action Routes:** Define business logic as a route (`FFRRouteType.action`). When navigated to, it executes a function instead of pushing a page to the stack. Perfect for API calls, logouts, or state machine triggers.
- **Guard Interceptors:** Centralized `FFRRouteGuard` lets you intercept and redirect flows (e.g., kicking unauthenticated users back to `/login`) before the UI even begins to build.
- **State-driven Navigation:** Listen to stack changes seamlessly with `ChangeNotifier` and access your entire navigation history (`FFRNavigator.I.history`) at any time.
- **Observers:** First-class support for `NavigatorObserver`, including a built-in `FFRRouteLogger` for clean debugging.
- **Dynamic Route Registration:** Add or remove routes at runtime without rebuilding the navigator — perfect for feature flags, plugin architectures, or lazy-loaded modules.

## Architecture & How it Works

The architecture is divided into clear responsibilities:

1. **Definitions (`FFRRouteDefinition`)**:
   You define a list of these. Each definition asserts its path (e.g. `/home`), its type (`fullPage`, `dialog`, `bottomSheet`, or `action`), its flow restrictions (`FFROpenFlow.postLogin`), and either a `builder` (to return a Widget) or an `action` callback (for side-effects).

2. **The Parser (`FFRRouteParser`)**:
   Converts literal strings like `/post/123?ref=social` against your definitions. It extracts `id=123` into `pathParams` and `ref=social` into `queryParams`, returning an `FFRRouteMatch`. Routes can also be added or removed from the parser at runtime.

3. **The Engine (`FFRNavigator`)**:
   The heart of the system. Calling `FFRNavigator.I.pushNamed('/route')` signals the parser. If matched, it passes through the configured **Guard**. If allowed, it modifies the internal `stack` list and notifies listeners (unless it's an action route, which just executes and returns).
   - **History Getter**: You can read `FFRNavigator.I.history` safely anywhere. Because FFR models navigation as a stack, this getter simply reflects the current stack hierarchy!
   - **Dynamic Routes**: Call `addRoute`, `addRoutes`, or `removeRoute` to mutate the route table live.

4. **The Delegates (`FFRRouterDelegate` & `FFRRouteInformationParser`)**:
   These bridge FFR into Flutter's `MaterialApp.router`. The Information Parser extracts the URL from the browser (or initial OS intent), and the Delegate maps the internal stack into a declarative list of Flutter `Page` objects.

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
  // Action route: executes a function instead of rendering a page.
  FFRRouteDefinition(
    id: '03LGO',
    path: '/logout',
    routeType: FFRRouteType.action,
    openFlow: FFROpenFlow.postLogin,
    action: (pathParams, queryParams) {
      AuthService.logout();
      FFRNavigator.I.pushReplacementNamed('/login');
    },
  ),
];
```

### 2. Configure the Navigator

Create exactly one instance. Doing so automatically sets up the `FFRNavigator.I` singleton!

```dart
final parser = FFRRouteParser(routes);

FFRNavigator(
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
    // Pass the global instance to the delegate
    delegate = FFRRouterDelegate(FFRNavigator.I);
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
FFRNavigator.I.pushNamed('/settings');

// Or replace the whole stack
FFRNavigator.I.pushReplacementNamed('/login');

// Push using templates and variables
FFRNavigator.I.pushNamed(
  '/user/{username}',
  pathParams: {'username': 'johndoe'},
  queryParams: {'sort': 'asc'}
);

// Trigger an Action Route as a service
FFRNavigator.I.pushNamed('/logout');
```

---

## Dynamic Route Registration

Routes can be registered or removed from the navigator at any time — without recreating it. This enables feature flags, plugin/module architectures, and lazy-loaded route trees.

### Adding a single route

```dart
FFRNavigator.I.addRoute(FFRRouteDefinition(
  id: '99NEW',
  path: '/new-feature',
  openFlow: FFROpenFlow.postLogin,
  builder: (context, p, q) => const NewFeatureScreen(),
));

// Now navigable immediately:
FFRNavigator.I.pushNamed('/new-feature');
```

### Adding multiple routes at once

```dart
FFRNavigator.I.addRoutes([
  FFRRouteDefinition(
    id: '10PRF',
    path: '/profile',
    builder: (context, p, q) => const ProfileScreen(),
  ),
  FFRRouteDefinition(
    id: '11SET',
    path: '/settings',
    builder: (context, p, q) => const SettingsScreen(),
  ),
]);
```

### Removing a route

```dart
// Unregister by route id — the path is no longer reachable
FFRNavigator.I.removeRoute('99NEW');
```

> **Note:** `addRoute` replaces an existing route if the same `id` is provided. Listeners are notified on every mutation, so your `FFRRouterDelegate` will always reflect the current route table.

---

Check out the `example/` folder within the package for a comprehensive working demonstration including modals, authentication flows, and parameterized routing.
