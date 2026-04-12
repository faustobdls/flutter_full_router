import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

/// Demonstrates local navigation within a Tab-based interface.
///
/// Each tab has its own independent navigation stack using [FFRLocalNavigatorOutlet].
class TabNavigatorDemoScreen extends StatefulWidget {
  const TabNavigatorDemoScreen({super.key});

  @override
  State<TabNavigatorDemoScreen> createState() => _TabNavigatorDemoScreenState();
}

class _TabNavigatorDemoScreenState extends State<TabNavigatorDemoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tab Navigator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.explore), text: 'Explore'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TabWithProvider(
            initialRoute: '/local-tab/home',
            accentColor: Colors.blue,
          ),
          _TabWithProvider(
            initialRoute: '/local-tab/explore',
            accentColor: Colors.green,
          ),
          _TabWithProvider(
            initialRoute: '/local-tab/profile',
            accentColor: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class _TabWithProvider extends StatelessWidget {
  final String initialRoute;
  final Color accentColor;

  const _TabWithProvider({
    required this.initialRoute,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return _AccentColorProvider(
      color: accentColor,
      child: FFRLocalNavigatorOutlet(
        key: ValueKey(initialRoute),
        initialRoute: initialRoute,
        navigatorType: FFRRouteType.tab,
      ),
    );
  }
}

class _AccentColorProvider extends InheritedWidget {
  final Color color;

  const _AccentColorProvider({
    required this.color,
    required super.child,
  });

  static Color of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_AccentColorProvider>();
    return provider?.color ?? Colors.blue;
  }

  @override
  bool updateShouldNotify(_AccentColorProvider oldWidget) {
    return color != oldWidget.color;
  }
}

// ============================================================================
// Home Tab
// ============================================================================

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);
    final accentColor = _AccentColorProvider.of(context);

    return ListView(
      children: [
        Container(
          height: 150,
          color: accentColor.withValues(alpha: 0.2),
          child: Center(
            child: Icon(Icons.home, size: 64, color: accentColor),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Home Feed',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        ...List.generate(10, (index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: accentColor,
              child: Text('${index + 1}'),
            ),
            title: Text('Item ${index + 1}'),
            subtitle: const Text('Tap to view details'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => localNavigator.pushNamed('/local-tab/home/item'),
          );
        }),
      ],
    );
  }
}

class HomeItemDetailScreen extends StatelessWidget {
  const HomeItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);
    final accentColor = _AccentColorProvider.of(context);

    return ListView(
      children: [
        Container(
          height: 200,
          color: accentColor.withValues(alpha: 0.3),
          child: Center(
            child: Icon(Icons.image, size: 80, color: accentColor),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Item Detail',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'This is a detailed view of an item. '
            'Each tab maintains its own navigation stack.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => localNavigator.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Explore Tab
// ============================================================================

class ExploreTabScreen extends StatelessWidget {
  const ExploreTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);
    final accentColor = _AccentColorProvider.of(context);

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      padding: const EdgeInsets.all(8),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(8, (index) {
        return Card(
          child: InkWell(
            onTap: () => localNavigator.pushNamed('/local-tab/explore/category'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category, size: 48, color: accentColor),
                const SizedBox(height: 8),
                Text('Category ${index + 1}'),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class ExploreCategoryScreen extends StatelessWidget {
  const ExploreCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);
    final accentColor = _AccentColorProvider.of(context);

    return ListView(
      children: [
        Container(
          height: 120,
          color: accentColor.withValues(alpha: 0.2),
          child: Center(
            child: Icon(Icons.category, size: 64, color: accentColor),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Category Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        ...List.generate(10, (index) {
          return ListTile(
            leading: Icon(Icons.article, color: accentColor),
            title: Text('Item ${index + 1}'),
            subtitle: const Text('Category content'),
          );
        }),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => localNavigator.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Explore'),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Profile Tab
// ============================================================================

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);
    final accentColor = _AccentColorProvider.of(context);

    return ListView(
      children: [
        Container(
          height: 150,
          color: accentColor.withValues(alpha: 0.2),
          child: Center(
            child: Icon(Icons.person, size: 64, color: accentColor),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'John Doe',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'john.doe@example.com',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.settings, color: accentColor),
          title: const Text('Settings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.help, color: accentColor),
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => localNavigator.pushNamed('/local-tab/profile/edit'),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
        ),
      ],
    );
  }
}

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);
    final accentColor = _AccentColorProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Full Name',
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
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Bio',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.info),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => localNavigator.pop(),
          icon: const Icon(Icons.save),
          label: const Text('Save Changes'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => localNavigator.pop(),
          icon: const Icon(Icons.cancel),
          label: const Text('Cancel'),
        ),
      ],
    );
  }
}
