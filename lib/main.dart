import 'package:flutter/material.dart';
import 'features/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,

        // 🌿 Cor principal verde
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // verde forte
        ),

        scaffoldBackgroundColor: const Color(0xFFF1F8E9), // verde bem claro

        // 🟩 Botões com bordas quadradas
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // 🔲 borda totalmente quadrada
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 18,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // 📝 Fonte global
        textTheme: ThemeData.light().textTheme,
      ),
      home: const HomePage(),
    );
  }
}
