import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Assuming these are your actual import paths.
// Make sure they are correct in your project.
// import '../Widgets/AlertBox.dart';

final _firebase = FirebaseAuth.instance;

/// A responsive and animated authentication screen for login and sign-up.
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to make the UI responsive
    return Scaffold(
      body: Container(
        // Using the requested gold-to-black gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(252, 186, 3, 1), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Constrain the width of the form on wider screens (web/tablet)
                final formWidth =
                constraints.maxWidth > 500 ? 400.0 : double.infinity;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: formWidth),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // --- App Logo ---
                          Image.asset(
                            'images/logo.png',
                            height: 100,
                            // Add a semantic label for accessibility
                            semanticLabel: 'App Logo',
                          ),
                          const SizedBox(height: 24),
                          // --- Auth Form Card ---
                          const _AuthForm(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// A private widget containing the form fields and logic for authentication.
class _AuthForm extends StatefulWidget {
  const _AuthForm({Key? key}) : super(key: key);

  @override
  __AuthFormState createState() => __AuthFormState();
}

class __AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _isAuthenticating = false;

  String _email = '';
  String _password = '';
  String _username = '';

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    // Close the keyboard
    FocusScope.of(context).unfocus();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isAuthenticating = true);

    try {
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _email, password: _password);
      } else {
        await _firebase.createUserWithEmailAndPassword(
            email: _email, password: _password);
        // Note: You might want to store the username in Firestore or Realtime Database here.
      }
    } on FirebaseAuthException catch (error) {
      // Use a modern SnackBar for error feedback
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Title ---
              Text(
                _isLogin ? 'Welcome Back!' : 'Create Account',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // --- Username Field (with animation) ---
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child);
                },
                child: !_isLogin
                    ? TextFormField(
                  key: const ValueKey('username'),
                  decoration: _buildInputDecoration(
                      'Username', Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.trim().length < 4) {
                      return 'Please enter at least 4 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) => _username = value!,
                )
                    : const SizedBox.shrink(),
              ),
              if (!_isLogin) const SizedBox(height: 12),

              // --- Email Field ---
              TextFormField(
                key: const ValueKey('email'),
                decoration:
                _buildInputDecoration('Email Address', Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@')) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 12),

              // --- Password Field ---
              TextFormField(
                key: const ValueKey('password'),
                decoration:
                _buildInputDecoration('Password', Icons.lock_outline),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 24),

              // --- Submit Button ---
              if (_isAuthenticating)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color.fromRGBO(252, 186, 3, 1),
                      foregroundColor: Colors.black,
                    ),
                    child: Text(_isLogin ? 'LOGIN' : 'SIGN UP'),
                  ),
                ),
              const SizedBox(height: 12),

              // --- Switch between Login/Signup ---
              TextButton(
                onPressed: () {
                  setState(() => _isLogin = !_isLogin);
                },
                child: Text(
                  _isLogin
                      ? 'Create a new account'
                      : 'I already have an account',
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a consistent style for text fields
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
            color: Color.fromRGBO(252, 186, 3, 1), width: 2.0),
      ),
    );
  }
}

