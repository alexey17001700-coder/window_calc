import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';

void main() {
  runApp(const AlmasApp());
}

class AlmasApp extends StatelessWidget {
  const AlmasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Замерщик окон Almas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          secondary: AppColors.bronze,
          surface: AppColors.card,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
