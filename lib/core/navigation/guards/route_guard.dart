import '../models/route_match.dart';

/// Intercepts a route match. Return a new path string to redirect,
/// or null to allow the route to proceed.
typedef FFRRouteGuard = String? Function(FFRRouteMatch match);
