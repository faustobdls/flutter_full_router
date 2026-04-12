import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

/// Demonstrates local navigation within a Tab-based interface.
///
/// This screen uses [FFRLocalNavigatorOutlet] to provide independent
/// navigation stacks for each tab.
class LocalTabNavigatorScreen extends StatefulWidget {
  const LocalTabNavigatorScreen({super.key});

  @override
  State<LocalTabNavigatorScreen> createState() =>
      _LocalTabNavigatorScreenState();
}

class _LocalTabNavigatorScreenState extends State<LocalTabNavigatorScreen>
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
        title: const Text('Tab Navigator Example'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.search), text: 'Explore'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TabNavigatorContent(
            initialRoute: '/local-tab/home',
            icon: Icons.home,
            color: Colors.blue,
          ),
          _TabNavigatorContent(
            initialRoute: '/local-tab/explore',
            icon: Icons.explore,
            color: Colors.green,
          ),
          _TabNavigatorContent(
            initialRoute: '/local-tab/profile',
            icon: Icons.person,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class _TabNavigatorContent extends StatelessWidget {
  final String initialRoute;
  final IconData icon;
  final Color color;

  const _TabNavigatorContent({
    required this.initialRoute,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FFRLocalNavigatorOutlet(
      key: ValueKey(initialRoute),
      initialRoute: initialRoute,
      navigatorType: FFRRouteType.tab,
      builder: (context, localNavigator, currentMatch) {
        return _TabLocalNavigator(
          localNavigator: localNavigator,
          currentMatch: currentMatch,
          accentColor: color,
        );
      },
    );
  }
}

class _TabLocalNavigator extends StatelessWidget {
  final FFRLocalNavigator localNavigator;
  final FFRRouteMatch? currentMatch;
  final Color accentColor;

  const _TabLocalNavigator({
    required this.localNavigator,
    required this.currentMatch,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(context, currentMatch),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildContent(BuildContext context, FFRRouteMatch? match) {
    final path = match?.route.path;

    if (path == null) {
      return const Center(child: Text('No route matched'));
    }

    switch (path) {
      case '/local-tab/home':
        return _HomeTabContent(accentColor: accentColor);
      case '/local-tab/home/item':
        return _HomeItemDetailContent(accentColor: accentColor);
      case '/local-tab/explore':
        return _ExploreTabContent(accentColor: accentColor);
      case '/local-tab/explore/category':
        return _ExploreCategoryContent(accentColor: accentColor);
      case '/local-tab/profile':
        return _ProfileTabContent(accentColor: accentColor);
      case '/local-tab/profile/edit':
        return _ProfileEditContent(accentColor: accentColor);
      default:
        return Center(child: Text('Unknown: $path'));
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    final path = currentMatch?.route.path;

    // Determine which nav items to show based on the tab
    bool showExtraNav = false;
    int currentIndex = 0;
    List<BottomNavigationBarItem> items = const [];

    if (path?.startsWith('/local-tab/home') == true) {
      showExtraNav = true;
      currentIndex = path == '/local-tab/home/item' ? 1 : 0;
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Item Detail',
        ),
      ];
    } else if (path?.startsWith('/local-tab/explore') == true) {
      showExtraNav = true;
      currentIndex = path == '/local-tab/explore/category' ? 1 : 0;
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Category',
        ),
      ];
    } else if (path?.startsWith('/local-tab/profile') == true) {
      showExtraNav = true;
      currentIndex = path == '/local-tab/profile/edit' ? 1 : 0;
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Edit'),
      ];
    }

    if (!showExtraNav) {
      return const SizedBox.shrink();
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (path?.startsWith('/local-tab/home') == true) {
          if (index == 0) {
            localNavigator.pushNamed('/local-tab/home');
          } else {
            localNavigator.pushNamed('/local-tab/home/item');
          }
        } else if (path?.startsWith('/local-tab/explore') == true) {
          if (index == 0) {
            localNavigator.pushNamed('/local-tab/explore');
          } else {
            localNavigator.pushNamed('/local-tab/explore/category');
          }
        } else if (path?.startsWith('/local-tab/profile') == true) {
          if (index == 0) {
            localNavigator.pushNamed('/local-tab/profile');
          } else {
            localNavigator.pushNamed('/local-tab/profile/edit');
          }
        }
      },
      items: items,
    );
  }
}

// ---------------------------------------------------------------------------
// Home Tab Content
// ---------------------------------------------------------------------------

class _HomeTabContent extends StatelessWidget {
  final Color accentColor;

  const _HomeTabContent({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

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

class _HomeItemDetailContent extends StatelessWidget {
  final Color accentColor;

  const _HomeItemDetailContent({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

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
            'This is a detailed view of an item. You can navigate back '
            'using the bottom navigation or the back button.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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

// ---------------------------------------------------------------------------
// Explore Tab Content
// ---------------------------------------------------------------------------

class _ExploreTabContent extends StatelessWidget {
  final Color accentColor;

  const _ExploreTabContent({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(8, (index) {
        return Card(
          child: InkWell(
            onTap: () => localNavigator.pushNamed(
              '/local-tab/explore/category',
            ),
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

class _ExploreCategoryContent extends StatelessWidget {
  final Color accentColor;

  const _ExploreCategoryContent({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

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

// ---------------------------------------------------------------------------
// Profile Tab Content
// ---------------------------------------------------------------------------

class _ProfileTabContent extends StatelessWidget {
  final Color accentColor;

  const _ProfileTabContent({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

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

class _ProfileEditContent extends StatelessWidget {
  final Color accentColor;

  const _ProfileEditContent({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final localNavigator = FFRLocalNavigatorOutlet.of(context);

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
