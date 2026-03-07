import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    log('[Rendered initState $runtimeType]');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home / Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'GitHub Repos',
            onPressed: () => FFRNavigator.I.pushNamed('/github/repos'),
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Authors',
            onPressed: () => FFRNavigator.I.pushNamed('/authors'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authState.logout();
              FFRNavigator.I.pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          final id = index + 1;
          return ListTile(
            leading: CircleAvatar(child: Text('$id')),
            title: Text('Post Title #$id'),
            subtitle: const Text('Tap to read more...'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => FFRNavigator.I.pushNamed('/post/$id'),
          );
        },
      ),
    );
  }
}
