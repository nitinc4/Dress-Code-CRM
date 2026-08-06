import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import '../common/customer_nav_wrapper.dart';

enum AuthStep { phone, login, setupPassword, signup }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  AuthStep _currentStep = AuthStep.phone;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;
  String _customerName = '';

  Future<void> _checkPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _errorMessage = 'Enter a valid 10-digit phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.checkPhone(phone);
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      final data = result['data'];
      final userExists = data['userExists'] ?? false;
      final customerExists = data['customerExists'] ?? false;
      final name = data['name'] ?? '';

      setState(() {
        if (userExists) {
          _currentStep = AuthStep.login;
        } else if (customerExists) {
          _customerName = name;
          _currentStep = AuthStep.setupPassword;
        } else {
          _currentStep = AuthStep.signup;
        }
      });
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  Future<void> _handleAction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    Map<String, dynamic> result;

    if (_currentStep == AuthStep.login) {
      result = await AuthService.login(_phoneController.text.trim(), _passwordController.text);
    } else if (_currentStep == AuthStep.setupPassword) {
      result = await AuthService.registerCustomer(_customerName, _phoneController.text.trim(), _passwordController.text);
    } else {
      // signup
      result = await AuthService.registerCustomer(_nameController.text.trim(), _phoneController.text.trim(), _passwordController.text);
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const CustomerNavWrapper()));
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  Future<void> _continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', true);
    await prefs.setString('user_name', 'Guest');
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const CustomerNavWrapper()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentStep != AuthStep.phone)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  onPressed: () => setState(() {
                    _currentStep = AuthStep.phone;
                    _errorMessage = null;
                  }),
                ),
              SizedBox(height: _currentStep != AuthStep.phone ? 24 : 48),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Image.asset('assets/images/Logo.jpg', height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, color: Color(0xFFD4AF37))),
                  ),
                  const SizedBox(width: 16),
                  const Text('DressCode.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                _currentStep == AuthStep.phone ? 'Client\nPortal.' :
                _currentStep == AuthStep.login ? 'Welcome\nBack.' :
                _currentStep == AuthStep.setupPassword ? 'Activate\nAccount.' : 'Create\nAccount.',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1.1, color: Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 12),
              Text(
                _currentStep == AuthStep.phone ? 'Sign in or create your bespoke tailoring account' :
                _currentStep == AuthStep.login ? 'Enter your password to continue' :
                _currentStep == AuthStep.setupPassword ? 'Welcome back, $_customerName! Set a password to activate your online account.' :
                'Enter your details to create a new account',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 60),
              
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), border: Border.all(color: Colors.redAccent.withOpacity(0.3)), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent))),
                    ],
                  ),
                ),

              if (_currentStep == AuthStep.phone) ...[
                _buildPhoneInput(),
                const SizedBox(height: 40),
                _buildPrimaryButton('CONTINUE', _checkPhone),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _continueAsGuest,
                    child: const Text('Continue as Guest', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                )
              ] else if (_currentStep == AuthStep.login) ...[
                _buildPasswordInput('Password'),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w600)))),
                const SizedBox(height: 40),
                _buildPrimaryButton('SIGN IN', _handleAction),
              ] else if (_currentStep == AuthStep.setupPassword) ...[
                _buildPasswordInput('Create a Password'),
                const SizedBox(height: 40),
                _buildPrimaryButton('ACTIVATE & LOGIN', _handleAction),
              ] else if (_currentStep == AuthStep.signup) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 20),
                _buildPasswordInput('Create a Password'),
                const SizedBox(height: 40),
                _buildPrimaryButton('SIGN UP', _handleAction),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return TextField(
      controller: _phoneController,
      decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined), counterText: ''),
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildPasswordInput(String label) {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFFD4AF37)),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      obscureText: !_isPasswordVisible,
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
