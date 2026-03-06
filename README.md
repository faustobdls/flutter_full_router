# Flutter Full Router (FFR)

A powerful, dependency-free navigation engine built from the ground up for Flutter using the native `Router` API. Forget complex third-party routing libraries—FFR gives you total control over your navigation stack, URL parameter extraction, authentication guarding, dynamic named routing, custom modal/bottom sheet overlays, **runtime route registration**, and **named action execution**.

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
- **Dynamic Route Registration:** Add or remove routes at runtime without rebuilding the navigator — perfect for feature flags, plugin architectures, or lazy-loaded modules.
- **Named Action Execution:** Register arbitrary named callbacks (`FFRNavigatorAction`) on the navigator and invoke them from anywhere in your app, keeping navigation and side-effects decoupled.

## Architecture & How it Works

The architecture is divided into clear responsibilities:

1. **Definitions (`FFRRouteDefinition`)**:
   You define a list of these. Each definition asserts its path (e.g. `/home`), its type (`fullPage`, `dialog`, `bottomSheet`), its flow restrictions (`FFROpenFlow.postLogin`), and a `builder` that receives parsed Path and Query parameters to return a Widget.

2. **The Parser (`FFRRouteParser`)**:
   Converts literal strings like `/post/123?ref=social` against your definitions. It extracts `id=123` into `pathParams` and `ref=social` into `queryParams`, returning an `FFRRouteMatch`. Routes can also be added or removed from the parser at runtime.

3. **The Engine (`FFRNavigator`)**:
   The heart of the system. Calling `pushNamed('/route')` signals the parser. If matched, it passes through the configured **Guard**. If allowed, it modifies the internal `stack` list and notifies listeners.
   - **History Getter**: You can read `navigator.history` safely anywhere. Because FFR models navigation as a stack, this getter simply reflects the current stack hierarchy!
   - **Dynamic Routes**: Call `addRoute`, `addRoutes`, or `removeRoute` to mutate the route table live.
   - **Action Registry**: Register named side-effect callbacks with `registerAction` and trigger them anywhere via `executeAction`.

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

---

## Dynamic Route Registration

Routes can be registered or removed from the navigator at any time — without recreating it. This enables feature flags, plugin/module architectures, and lazy-loaded route trees.

### Adding a single route

```dart
globalNavigator.addRoute(FFRRouteDefinition(
  id: '99NEW',
  path: '/new-feature',
  openFlow: FFROpenFlow.postLogin,
  builder: (context, p, q) => const NewFeatureScreen(),
));

// Now navigable immediately:
globalNavigator.pushNamed('/new-feature');
```

### Adding multiple routes at once

```dart
globalNavigator.addRoutes([
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
globalNavigator.removeRoute('99NEW');
```

> **Note:** `addRoute` replaces an existing route if the same `id` is provided. Listeners are notified on every mutation, so your `FFRRouterDelegate` will always reflect the current route table.

---

## Named Action Execution

Actions are named side-effect callbacks registered on the navigator. They allow any part of your app to trigger behaviour (analytics, banners, logouts, etc.) through the same central navigator reference — without creating tight dependencies.

### Registering actions

```dart
// Typically done in initState or a service initializer
globalNavigator.registerAction('logout', (params) async {
  await AuthService.signOut();
  globalNavigator.pushReplacementNamed('/login');
});

globalNavigator.registerAction('showBanner', (params) {
  final message = params['message'] as String;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
});
```

### Executing actions

```dart
// From anywhere that has access to the navigator
globalNavigator.executeAction('logout');

globalNavigator.executeAction('showBanner', params: {
  'message': 'Welcome back!',
});
```

### Checking and unregistering

```dart
if (globalNavigator.hasAction('logout')) {
  globalNavigator.unregisterAction('logout');
}
```

> **Tip:** Actions receive a `Map<String, dynamic> params` and can be async internally. Registering an action with the same name replaces the previous one.

---

Check out the `example/` folder within the package for a comprehensive working demonstration including modals, authentication flows, and parameterized routing.
