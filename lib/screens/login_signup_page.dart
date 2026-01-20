import '../main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import '../models/user.dart';
import '../providers/courses_provider.dart';
import 'package:provider/provider.dart';

const Color khaki = Color(0xFFF0E68C);

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  bool isLogin = true;

  String username = '';
  String name = '';
  String password = '';
  String errorText = '';

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
      errorText = '';
    });
  }

  Future<void> _handleSubmit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    if (isLogin) {
      final user = await _dbHelper.loginUser(username, password);
      if (user != null) {
        await _saveLogin(user);
        _navigateToHome();
      } else {
        setState(() {
          errorText = "Invalid username or password";
        });
      }
    } else {
      final result = await _dbHelper.registerUser(User(
        username: username,
        name: name,
        password: password,
      ));

      if (result > 0) {
        final user = await _dbHelper.loginUser(username, password);
        if (user != null) {
          await _saveLogin(user);
          _navigateToHome();
        }
      } else {
        setState(() {
          errorText = "Username already exists";
        });
      }
    }
  }

  Future<void> _saveLogin(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);
    await prefs.setString('username', user.username);
    await prefs.setString('name', user.name);
  }

  void _navigateToHome() async {
    await Provider.of<CoursesProvider>(context, listen: false).loadData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final inputFill = khaki.withOpacity(isDark ? 0.18 : 0.12);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey[700];

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: khaki.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(color: khaki, width: 2),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: khaki.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 56,
                      height: 56,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isLogin ? 'Welcome Back!' : 'Create Your Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: khaki,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLogin
                        ? 'Login to DueTrack'
                        : 'Sign up to start tracking your assignments',
                    style: TextStyle(
                      fontSize: 15,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (!isLogin)
                    TextFormField(
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: textColor),
                        filled: true,
                        fillColor: inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: Icon(Icons.person, color: khaki),
                      ),
                      validator: (val) => val!.isEmpty ? 'Enter name' : null,
                      onSaved: (val) => name = val!,
                    ),
                  if (!isLogin) const SizedBox(height: 16),
                  TextFormField(
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: textColor),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      prefixIcon: Icon(Icons.account_circle, color: khaki),
                    ),
                    validator: (val) => val!.isEmpty ? 'Enter username' : null,
                    onSaved: (val) => username = val!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: textColor),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      prefixIcon: Icon(Icons.lock, color: khaki),
                    ),
                    validator: (val) => val!.isEmpty ? 'Enter password' : null,
                    onSaved: (val) => password = val!,
                  ),
                  const SizedBox(height: 20),
                  if (errorText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              errorText,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: khaki,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        elevation: 2,
                      ),
                      onPressed: _handleSubmit,
                      child: Text(isLogin ? 'Login' : 'Sign Up'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _toggleMode,
                    child: Text(
                      isLogin
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Login',
                      style: TextStyle(
                        color: khaki,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}