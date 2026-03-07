import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';
import '../main.dart'; // To access FFRNavigator.I and authState

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    log('[Rendered initState $runtimeType]');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Simulate Login'),
              onPressed: () {
                authState.login();
                FFRNavigator.I.pushReplacementNamed('/home');
              },
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Simulate router error'),
              onPressed: () {
                FFRNavigator.I.pushReplacementNamed('/about');
              },
            ),
          ],
        ),
      ),
    );
  }
}
