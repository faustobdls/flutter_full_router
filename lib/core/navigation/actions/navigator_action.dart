/// Defines the signature for an action that can be registered and
/// executed through [FFRNavigator].
///
/// Actions allow decoupled, named side effects to be triggered via the
/// navigator without requiring direct dependencies between components.
///
/// Example:
/// ```dart
/// navigator.registerAction('showBanner', (params) {
///   final message = params['message'] as String;
///   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
/// });
///
/// // Later, from anywhere:
/// navigator.executeAction('showBanner', params: {'message': 'Welcome!'});
/// ```
typedef FFRNavigatorAction = void Function(Map<String, dynamic> params);
