import 'package:_2048/GameScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 2048 Game Color Palette
const Color backgroundColor = Color(0xFFFAF8EF); // Light beige background
const Color boardBackground = Color(0xFFBBADA0); // Darker beige for board
const Color emptyTileColor = Color(0xFFCDC1B4); // Empty tile color
const Color textColor = Color(0xFF776E65); // Dark grey text
const Color scoreBoxColor = Color(0xFFBBADA0); // Score box background

void main() {
  runApp(const ProviderScope(child: My2048App()));
}

class My2048App extends StatelessWidget {
  const My2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: textColor,
          secondary: scoreBoxColor,
          background: backgroundColor,
          surface: boardBackground,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: textColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const GameScreen(),
    );
  }
}
