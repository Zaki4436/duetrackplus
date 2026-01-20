import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duetrack/providers/courses_provider.dart';
import 'package:duetrack/providers/theme_provider.dart';
import 'package:duetrack/screens/assignments_due_page.dart';
import 'package:duetrack/screens/courses_page.dart';
import 'package:duetrack/screens/calendar_page.dart';
import 'package:duetrack/screens/notifications_page.dart';
import 'package:duetrack/screens/profile_page.dart';
import 'package:duetrack/screens/login_signup_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // ✅ Initialize and preload CoursesProvider with data from SQLite
  final coursesProvider = CoursesProvider();
  await coursesProvider.loadData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: coursesProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'DueTrack',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.currentTheme,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(), // <-- Set SplashScreen as initial home
        );
      },
    );
  }
}

// --- SplashScreen Widget ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.containsKey('userId');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => loggedIn ? const MainNavigationPage() : const LoginSignupPage(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your logo asset if available
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0E68C).withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(24),
              child: Image.asset(
                'assets/logo.jpg',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'DueTrack',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF0E68C),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 18),
            const CircularProgressIndicator(
              color: Color(0xFFF0E68C),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AssignmentsDuePage(),
    const CoursesPage(),
    const CalendarPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}