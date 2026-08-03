import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/auth/role_selection_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const DressCodeApp());
}

class DressCodeApp extends StatelessWidget {
  const DressCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF0F2042);
    const Color accentBlue = Color(0xFF1E50A2);
    const Color scaffoldBg = Color(0xFFF4F6F9);

    return MaterialApp(
      title: 'DressCode Garment ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: scaffoldBg,
        primaryColor: primaryNavy,
        colorScheme: const ColorScheme.light(
          primary: primaryNavy,
          secondary: accentBlue,
          surface: Colors.white,
          background: scaffoldBg,
          onPrimary: Colors.white,
          onSurface: Color(0xFF1E293B),
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1.5,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentBlue, width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF64748B)),
          prefixIconColor: accentBlue,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryNavy,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}
