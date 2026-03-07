import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';

class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  @override
  void initState() {
    super.initState();
    log('[Rendered initState $runtimeType]');
  }

  @override
  Widget build(BuildContext context) {
    final authors = ['john_doe', 'alice_2024', 'developer_guy', 'flutter_dev'];

    return Scaffold(
      appBar: AppBar(title: const Text('Authors')),
      body: ListView.separated(
        itemCount: authors.length,
        separatorBuilder: (context, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final username = authors[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text('@$username'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => FFRNavigator.I.pushNamed('/author/$username'),
          );
        },
      ),
    );
  }
}
