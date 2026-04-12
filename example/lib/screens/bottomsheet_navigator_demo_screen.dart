import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';
import '../custom_pages.dart';

/// Demonstrates local navigation within a ModalBottomSheet.
///
/// The bottom sheet is opened via [FFRNavigator.I.pushNamed] to a route
/// with [FFRRouteType.bottomSheet]. The FFR router automatically
/// renders it as a modal bottom sheet.
///
/// Shows both default and custom styled bottom sheets with 4 levels
/// of internal navigation depth.
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
          const Text(
            'Opens via pushNamed to a bottomSheet route type. '
            'Contains 4 levels of navigation depth with iOS-style content.',
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.layers),
            label: const Text('Open Default BottomSheet'),
            onPressed: () => FFRNavigator.I.pushNamed('/bottomsheet-default'),
          ),
          const SizedBox(height: 32),
          const Text(
            'Custom BottomSheet (Dark Theme)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Opens via pushNamed with custom styling applied to the '
            'bottom sheet container.',
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.palette),
            label: const Text('Open Custom BottomSheet'),
            onPressed: () => FFRNavigator.I.pushNamed('/bottomsheet-custom'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Default BottomSheet Route Content
// ============================================================================

class DefaultBottomSheetContent extends StatelessWidget {
  const DefaultBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FFRLocalNavigatorOutlet(
      initialRoute: '/local-settings/main',
      navigatorType: FFRRouteType.bottomSheet,
      onExitLocalNavigation: () {
        // The FFR Navigator will handle popping the bottomSheet route
        FFRNavigator.I.pop();
      },
    );
  }
}

// ============================================================================
// Custom BottomSheet Route Content
// ============================================================================

class CustomBottomSheetContent extends StatelessWidget {
  const CustomBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FFRLocalNavigatorOutlet(
      initialRoute: '/local-settings/main',
      navigatorType: FFRRouteType.bottomSheet,
      onExitLocalNavigation: () {
        FFRNavigator.I.pop();
      },
    );
  }
}

// ============================================================================
// Settings Main (Level 1)
// ============================================================================

class SettingsMainScreen extends StatelessWidget {
  const SettingsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return _SettingsScaffold(
      title: 'Settings',
      depth: 1,
      body: ListView(
        children: [
          _SettingsTile(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Level 2: Edit your profile',
            onTap: () => localNavigator.pushNamed('/local-settings/profile'),
          ),
          _SettingsTile(
            icon: Icons.security,
            title: 'Privacy',
            subtitle: 'Level 2: Manage privacy settings',
            onTap: () => localNavigator.pushNamed('/local-settings/privacy'),
          ),
          _SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Level 2: Notification preferences',
            onTap: () => localNavigator.pushNamed('/local-settings/notifications'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Profile (Level 2)
// ============================================================================

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return _SettingsScaffold(
      title: 'Profile',
      depth: 2,
      body: ListView(
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
            onPressed: () => localNavigator.pushNamed('/local-settings/profile/avatar'),
            child: const Text('Edit Avatar (Level 3)'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => localNavigator.pop(),
            child: const Text('Back to Settings'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Avatar (Level 3)
// ============================================================================

class AvatarSettingsScreen extends StatelessWidget {
  const AvatarSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return _SettingsScaffold(
      title: 'Avatar',
      depth: 3,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Avatar Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.person, size: 64, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => localNavigator.pushNamed('/local-settings/profile/avatar/crop'),
            icon: const Icon(Icons.crop),
            label: const Text('Crop Image (Level 4)'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => localNavigator.pushNamed('/local-settings/profile/avatar/filters'),
            icon: const Icon(Icons.filter_vintage),
            label: const Text('Apply Filters (Level 4)'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => localNavigator.pop(),
            child: const Text('Back to Profile'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Crop (Level 4)
// ============================================================================

class AvatarCropScreen extends StatelessWidget {
  const AvatarCropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return _SettingsScaffold(
      title: 'Crop Avatar',
      depth: 4,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Crop Avatar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.crop_rotate, size: 64, color: Colors.blue),
                  SizedBox(height: 8),
                  Text('Crop Area', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Level 4: Deepest navigation level. Tap back to return.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => localNavigator.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Avatar'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Filters (Level 4)
// ============================================================================

class AvatarFiltersScreen extends StatelessWidget {
  const AvatarFiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return _SettingsScaffold(
      title: 'Avatar Filters',
      depth: 4,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Avatar Filters',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.filter_vintage, size: 64, color: Colors.purple),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Level 4: Deepest navigation level.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => localNavigator.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Avatar'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Privacy (Level 2)
// ============================================================================

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return _SettingsScaffold(
      title: 'Privacy',
      depth: 2,
      body: ListView(
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => localNavigator.pushNamed('/local-settings/privacy/blocked'),
            icon: const Icon(Icons.block),
            label: const Text('Blocked Users (Level 3)'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => localNavigator.pop(),
            child: const Text('Back to Settings'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Blocked Users (Level 3)
// ============================================================================

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return _SettingsScaffold(
      title: 'Blocked Users',
      depth: 3,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Blocked Users',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red[100],
                child: Text('${index + 1}'),
              ),
              title: Text('User ${index + 1}'),
              trailing: OutlinedButton(
                onPressed: () {},
                child: const Text('Unblock'),
              ),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => localNavigator.pop(),
            child: const Text('Back to Privacy'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Notifications (Level 2)
// ============================================================================

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return _SettingsScaffold(
      title: 'Notifications',
      depth: 2,
      body: ListView(
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => localNavigator.pushNamed('/local-settings/notifications/channels'),
            icon: const Icon(Icons.view_list),
            label: const Text('Channels (Level 3)'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => localNavigator.pop(),
            child: const Text('Back to Notifications'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Channels (Level 3)
// ============================================================================

class NotificationChannelsScreen extends StatelessWidget {
  const NotificationChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return _SettingsScaffold(
      title: 'Channels',
      depth: 3,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notification Channels',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...List.generate(6, (index) {
            final channels = [
              'Messages',
              'Updates',
              'Promotions',
              'Reminders',
              'Alerts',
              'News',
            ];
            return SwitchListTile(
              title: Text(channels[index]),
              value: index < 3,
              onChanged: (value) {},
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => localNavigator.pop(),
            child: const Text('Back to Notifications'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Shared Scaffold
// ============================================================================

class _SettingsScaffold extends StatelessWidget {
  final String title;
  final int depth;
  final Widget body;

  const _SettingsScaffold({
    required this.title,
    required this.depth,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Scaffold(
        backgroundColor: isDark ? CustomDesignSystem.darkTheme.bottomSheetBackgroundColor : null,
        appBar: AppBar(
          backgroundColor: isDark ? CustomDesignSystem.darkTheme.bottomSheetBackgroundColor : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                'Depth: $depth',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () {
              FFRLocalNavigatorOutlet.close(context);
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
        body: body,
      ),
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
