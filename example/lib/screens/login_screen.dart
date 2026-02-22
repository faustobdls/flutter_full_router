import 'dart:developer';

import 'package:flutter/material.dart';
import '../main.dart'; // To access globalNavigator and authState

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
                globalNavigator.pushReplacementNamed('/home');
              },
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Simulate router error'),
              onPressed: () {
                globalNavigator.pushReplacementNamed('/about');
              },
            ),
          ],
        ),
      ),
    );
  }
}
