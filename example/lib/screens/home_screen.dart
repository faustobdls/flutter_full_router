import 'dart:developer';

import 'package:flutter/material.dart';
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
            icon: const Icon(Icons.people),
            tooltip: 'Authors',
            onPressed: () => globalNavigator.pushNamed('/authors'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authState.logout();
              globalNavigator.pushReplacementNamed('/login');
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
            onTap: () => globalNavigator.pushNamed('/post/$id'),
          );
        },
      ),
    );
  }
}
