import 'dart:developer';

import 'package:flutter/material.dart';
import '../main.dart';

class PostScreen extends StatefulWidget {
  final String id;
  const PostScreen({super.key, required this.id});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  void initState() {
    super.initState();
    log('[Rendered initState $runtimeType] ${widget.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post ${widget.id}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Post ID: ${widget.id}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => globalNavigator.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
