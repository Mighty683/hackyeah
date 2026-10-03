import 'package:flutter/material.dart';

import 'features/welcome/welcome_screen.dart';

class BaseboundApp extends StatelessWidget {
  const BaseboundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basebound',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2B7560),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFBF9F1),
      ),
      home: const WelcomeScreen(),
    );
  }
}
