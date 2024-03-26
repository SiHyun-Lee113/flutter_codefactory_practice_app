import 'package:flutter/material.dart';
import 'package:flutter_codefactory_practice_app/common/view/splash_screen.dart';

void main() {
  runApp(
    _App(),
  );
}

class _App extends StatelessWidget {
  const _App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: SplashScreen(),
    );
  }
}
