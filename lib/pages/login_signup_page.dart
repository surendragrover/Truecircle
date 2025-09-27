
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State
  bool _isLoginMode = true;
  bool _isLoading = false;
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  // Toggles between Login and Signup modes
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = '';
    });
  }

  // Handles the form submission
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isLoginMode) {
        await _authService.signIn(email: _email, password: _password);
      } else {
        await _authService.signUp(email: _email, password: _password);
      }
      // If successful, the auth stream will navigate the user away.
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Title
                Text(
                  'TrueCircle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Apne rishton ko pehchanein',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 48),

                // Email Field
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an email' : null,
                  onSaved: (value) => _email = value!,
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  validator: (value) => value!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                // Submit Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isLoginMode ? 'Login' : 'Sign Up',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 16),

                // Toggle Button
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLoginMode
                        ? 'Naya account banayein'
                        : 'Pehle se account hai? Login karein',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
