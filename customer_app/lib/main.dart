import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DressCode Customer',
      theme: ThemeData(
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4AF37)),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: IconThemeData(color: Color(0xFF0F2042)),
          titleTextStyle: TextStyle(color: Color(0xFF0F2042), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        fontFamily: 'Inter', // Fallback to default if not installed, but keeping design consistent
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
