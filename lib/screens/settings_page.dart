import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import 'login_signup_page.dart';

const Color khaki = Color(0xFFF0E68C);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginSignupPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final bgColor = isDark ? Colors.grey[900] : Colors.white;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey[700];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Settings', textAlign: TextAlign.center,),
        centerTitle: true,
        backgroundColor: khaki,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: khaki.withOpacity(isDark ? 0.08 : 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(color: khaki, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.dark_mode, color: isDark ? Colors.white : Colors.black87),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  trailing: Switch(
                    value: themeProvider.isDark,
                    onChanged: (val) => themeProvider.toggleTheme(),
                    activeColor: khaki,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: khaki.withOpacity(isDark ? 0.04 : 0.08),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      elevation: 2,
                    ),
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