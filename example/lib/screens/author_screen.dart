import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';


class AuthorScreen extends StatefulWidget {
  final String username;
  const AuthorScreen({super.key, required this.username});

  @override
  State<AuthorScreen> createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  @override
  void initState() {
    super.initState();
    log('[Rendered initState $runtimeType] ${widget.username}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('@${widget.username}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Author: ${widget.username}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Welcome to this author\'s profile!'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Authors'),
              onPressed: () => FFRNavigator.I.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
