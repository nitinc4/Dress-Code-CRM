import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/admin/admin_nav_wrapper.dart';
import 'features/common/employee_nav_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const DressCodeApp());
}

class DressCodeApp extends StatelessWidget {
  const DressCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color goldAccent = Color(0xFFD4AF37); // Gold accent
    const Color whiteBackground = Colors.white; // White background
    const Color darkText = Color(0xFF121212); // Black text

    return MaterialApp(
      title: 'DressCode ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: whiteBackground,
        primaryColor: goldAccent,
        colorScheme: const ColorScheme.light(
          primary: goldAccent,
          secondary: goldAccent,
          surface: whiteBackground,
          onPrimary: Colors.black,
          onSurface: darkText,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: whiteBackground,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: goldAccent, width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          prefixIconColor: goldAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: goldAccent,
            foregroundColor: darkText,
            elevation: 1,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
      ),
      home: const AuthSessionWrapper(),
    );
  }
}

class AuthSessionWrapper extends StatefulWidget {
  const AuthSessionWrapper({super.key});

  @override
  State<AuthSessionWrapper> createState() => _AuthSessionWrapperState();
}

class _AuthSessionWrapperState extends State<AuthSessionWrapper> {
  bool _isLoading = true;
  String? _savedRole;
  String? _savedToken;

  @override
  void initState() {
    super.initState();
    _checkSavedSession();
  }

  Future<void> _checkSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final role = prefs.getString('user_role');

    if (mounted) {
      setState(() {
        _savedToken = token;
        _savedRole = role;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    // Auto-login: If token exists, direct to user's saved role dashboard
    if (_savedToken != null && _savedRole != null) {
      if (_savedRole == 'admin') {
        return const AdminNavWrapper();
      } else {
        return EmployeeNavWrapper(role: _savedRole!);
      }
    }

    // Default: Show Role Selection & Login Screen
    return const RoleSelectionScreen();
  }
}
