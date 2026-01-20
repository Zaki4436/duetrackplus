import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/courses_provider.dart';
import '../models/assignment.dart';
import 'settings_page.dart';

const Color khaki = Color(0xFFF0E68C);

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context);

    final assignments = provider.getAllAssignments();
    final total = assignments.length;
    final done = assignments.where((a) => a.status == TaskStatus.done).length;
    final percent = total == 0 ? 0.0 : done / total;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final borderColor = khaki;
    final bgColor = isDark ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
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
                  color: khaki.withOpacity(isDark ? 0.10 : 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: khaki.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(Icons.account_circle, size: 64, color: khaki),
                ),
                const SizedBox(height: 18),
                Text(
                  'Progress Overview',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 20),
                CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 12.0,
                  animation: true,
                  percent: percent,
                  center: Text(
                    "${(percent * 100).toStringAsFixed(1)}%",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  progressColor: khaki,
                  backgroundColor: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(height: 20),
                Text(
                  'Completed: $done / $total tasks',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: subtitleColor),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: khaki,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
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