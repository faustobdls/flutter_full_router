import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';
import '../main.dart'; // To access FFRNavigator.I and authState

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    log('[Rendered initState $runtimeType]');
    Future.delayed(const Duration(seconds: 2), () {
      if (authState.isLoggedIn) {
        FFRNavigator.I.pushReplacementNamed('/home');
      } else {
        FFRNavigator.I.pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
