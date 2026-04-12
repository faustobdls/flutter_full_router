import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

/// Demonstrates local navigation within a ModalBottomSheet.
///
/// This screen renders a button that opens a bottom sheet with its own
/// internal navigation stack using [FFRLocalNavigatorOutlet].
class LocalNavigatorDemoScreen extends StatelessWidget {
  const LocalNavigatorDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Navigator Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Local Navigation Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.layers),
              label: const Text('Open Bottom Sheet Navigator'),
              onPressed: () => _openBottomSheetNavigator(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.tab),
              label: const Text('Open Tab Navigator'),
              onPressed: () => FFRNavigator.I.pushNamed('/local-tabs'),
            ),
          ],
        ),
      ),
    );
  }

  void _openBottomSheetNavigator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return FFRLocalNavigatorOutlet(
          initialRoute: '/local-settings/main',
          navigatorType: FFRRouteType.bottomSheet,
          builder: (context, localNavigator, currentMatch) {
            return _BottomSheetScaffold(
              localNavigator: localNavigator,
              currentMatch: currentMatch,
            );
          },
        );
      },
    );
  }
}

class _BottomSheetScaffold extends StatelessWidget {
  final FFRLocalNavigator localNavigator;
  final FFRRouteMatch? currentMatch;

  const _BottomSheetScaffold({
    required this.localNavigator,
    required this.currentMatch,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleForRoute(currentMatch?.route.path)),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () {
              final shouldExit = localNavigator.pop(exitLocalNavigation: true);
              if (shouldExit) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (localNavigator.canPop)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () => localNavigator.pop(),
              ),
          ],
        ),
        body: _buildContent(context, currentMatch),
        bottomNavigationBar: _BottomSheetNavBar(
          localNavigator: localNavigator,
          currentPath: currentMatch?.route.path,
        ),
      ),
    );
  }

  String _titleForRoute(String? path) {
    switch (path) {
      case '/local-settings/main':
        return 'Settings';
      case '/local-settings/profile':
        return 'Profile Settings';
      case '/local-settings/privacy':
        return 'Privacy Settings';
      case '/local-settings/notifications':
        return 'Notification Settings';
      default:
        return 'Settings';
    }
  }

  Widget _buildContent(BuildContext context, FFRRouteMatch? match) {
    switch (match?.route.path) {
      case '/local-settings/main':
        return const _MainSettingsContent();
      case '/local-settings/profile':
        return const _ProfileSettingsContent();
      case '/local-settings/privacy':
        return const _PrivacySettingsContent();
      case '/local-settings/notifications':
        return const _NotificationSettingsContent();
      default:
        return const Center(child: Text('Unknown Settings Page'));
    }
  }
}

class _MainSettingsContent extends StatelessWidget {
  const _MainSettingsContent();

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return ListView(
      children: [
        _SettingsTile(
          icon: Icons.person,
          title: 'Profile',
          subtitle: 'Edit your profile information',
          onTap: () => localNavigator.pushNamed('/local-settings/profile'),
        ),
        _SettingsTile(
          icon: Icons.security,
          title: 'Privacy',
          subtitle: 'Manage your privacy settings',
          onTap: () => localNavigator.pushNamed('/local-settings/privacy'),
        ),
        _SettingsTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Configure notification preferences',
          onTap: () => localNavigator.pushNamed('/local-settings/notifications'),
        ),
      ],
    );
  }
}

class _ProfileSettingsContent extends StatelessWidget {
  const _ProfileSettingsContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Profile Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Save Profile'),
        ),
      ],
    );
  }
}

class _PrivacySettingsContent extends StatelessWidget {
  const _PrivacySettingsContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Privacy Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Private Profile'),
          subtitle: const Text('Only approved users can see your profile'),
          value: false,
          onChanged: (value) {},
        ),
        SwitchListTile(
          title: const Text('Show Online Status'),
          subtitle: const Text('Let others see when you\'re online'),
          value: true,
          onChanged: (value) {},
        ),
      ],
    );
  }
}

class _NotificationSettingsContent extends StatelessWidget {
  const _NotificationSettingsContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Notification Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive push notifications'),
          value: true,
          onChanged: (value) {},
        ),
        SwitchListTile(
          title: const Text('Email Notifications'),
          subtitle: const Text('Receive email updates'),
          value: false,
          onChanged: (value) {},
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _BottomSheetNavBar extends StatelessWidget {
  final FFRLocalNavigator localNavigator;
  final String? currentPath;

  const _BottomSheetNavBar({
    required this.localNavigator,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _indexForPath(currentPath),
      onTap: (index) {
        switch (index) {
          case 0:
            localNavigator.pushNamed('/local-settings/main');
          case 1:
            localNavigator.pushNamed('/local-settings/profile');
          case 2:
            localNavigator.pushNamed('/local-settings/privacy');
          case 3:
            localNavigator.pushNamed('/local-settings/notifications');
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Privacy'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Alerts',
        ),
      ],
    );
  }

  int _indexForPath(String? path) {
    switch (path) {
      case '/local-settings/profile':
        return 1;
      case '/local-settings/privacy':
        return 2;
      case '/local-settings/notifications':
        return 3;
      default:
        return 0;
    }
  }
}
