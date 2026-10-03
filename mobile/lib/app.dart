import 'package:flutter/material.dart';

import 'features/welcome/welcome_screen.dart';
import 'ui/basebound_ui.dart';

class BaseboundApp extends StatelessWidget {
  const BaseboundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Path',
      debugShowCheckedModeBanner: false,
      theme: BaseboundTheme.training(),
      home: const WelcomeScreen(),
    );
  }
}
