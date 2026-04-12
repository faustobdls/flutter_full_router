import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';
import '../custom_pages.dart';

/// Demonstrates local navigation within a ModalBottomSheet.
///
/// Shows both default and custom styled bottom sheets with internal navigation.
class BottomSheetNavigatorDemoScreen extends StatelessWidget {
  const BottomSheetNavigatorDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bottom Sheet Navigator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Default BottomSheet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.layers),
            label: const Text('Open Default BottomSheet'),
            onPressed: () => _openDefaultBottomSheet(context),
          ),
          const SizedBox(height: 32),
          const Text(
            'Custom BottomSheet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.palette),
            label: const Text('Open Custom BottomSheet'),
            onPressed: () => _openCustomBottomSheet(context),
          ),
        ],
      ),
    );
  }

  void _openDefaultBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return FFRLocalNavigatorOutlet(
          initialRoute: '/local-settings/main',
          navigatorType: FFRRouteType.bottomSheet,
          builder: (context, localNavigator, currentMatch) {
            return _DefaultBottomSheetContent(
              localNavigator: localNavigator,
              currentMatch: currentMatch,
            );
          },
        );
      },
    );
  }

  void _openCustomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: CustomDesignSystem.darkTheme.bottomSheetBackgroundColor,
      shape: CustomDesignSystem.darkTheme.bottomSheetShape,
      barrierColor: CustomDesignSystem.darkTheme.bottomSheetBarrierColor,
      builder: (sheetContext) {
        return FFRLocalNavigatorOutlet(
          initialRoute: '/local-settings/main',
          navigatorType: FFRRouteType.bottomSheet,
          builder: (context, localNavigator, currentMatch) {
            return _CustomBottomSheetContent(
              localNavigator: localNavigator,
              currentMatch: currentMatch,
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// Default BottomSheet Content
// ============================================================================

class _DefaultBottomSheetScaffold extends StatelessWidget {
  final FFRLocalNavigator localNavigator;
  final FFRRouteMatch? currentMatch;

  const _DefaultBottomSheetScaffold({
    required this.localNavigator,
    required this.currentMatch,
  });

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
          isCustom: false,
        ),
      ),
    );
  }
}

class _DefaultBottomSheetContent extends StatelessWidget {
  final FFRLocalNavigator localNavigator;
  final FFRRouteMatch? currentMatch;

  const _DefaultBottomSheetContent({
    required this.localNavigator,
    required this.currentMatch,
  });

  @override
  Widget build(BuildContext context) {
    return _DefaultBottomSheetScaffold(
      localNavigator: localNavigator,
      currentMatch: currentMatch,
    );
  }
}

// ============================================================================
// Custom BottomSheet Content
// ============================================================================

class _CustomBottomSheetScaffold extends StatelessWidget {
  final FFRLocalNavigator localNavigator;
  final FFRRouteMatch? currentMatch;

  const _CustomBottomSheetScaffold({
    required this.localNavigator,
    required this.currentMatch,
  });

  String _titleForRoute(String? path) {
    switch (path) {
      case '/local-settings/main':
        return '⚙️ Settings';
      case '/local-settings/profile':
        return '👤 Profile';
      case '/local-settings/privacy':
        return '🔒 Privacy';
      case '/local-settings/notifications':
        return '🔔 Notifications';
      default:
        return '⚙️ Settings';
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
        return const Center(
          child: Text(
            'Unknown Settings Page',
            style: TextStyle(color: Color(0xFFA6ADC8)),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Scaffold(
        backgroundColor: CustomDesignSystem.darkTheme.bottomSheetBackgroundColor,
        appBar: AppBar(
          backgroundColor: CustomDesignSystem.darkTheme.bottomSheetBackgroundColor,
          title: Text(
            _titleForRoute(currentMatch?.route.path),
            style: const TextStyle(color: Color(0xFFCDD6F4)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFF38BA8)),
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
                icon: const Icon(Icons.arrow_back, color: Color(0xFF89B4FA)),
                tooltip: 'Back',
                onPressed: () => localNavigator.pop(),
              ),
          ],
        ),
        body: _buildContent(context, currentMatch),
        bottomNavigationBar: _BottomSheetNavBar(
          localNavigator: localNavigator,
          currentPath: currentMatch?.route.path,
          isCustom: true,
        ),
      ),
    );
  }
}

class _CustomBottomSheetContent extends StatelessWidget {
  final FFRLocalNavigator localNavigator;
  final FFRRouteMatch? currentMatch;

  const _CustomBottomSheetContent({
    required this.localNavigator,
    required this.currentMatch,
  });

  @override
  Widget build(BuildContext context) {
    return _CustomBottomSheetScaffold(
      localNavigator: localNavigator,
      currentMatch: currentMatch,
    );
  }
}

// ============================================================================
// Settings Content (Shared)
// ============================================================================

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

// ============================================================================
// Shared Widgets
// ============================================================================

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
  final bool isCustom;

  const _BottomSheetNavBar({
    required this.localNavigator,
    required this.currentPath,
    this.isCustom = false,
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
