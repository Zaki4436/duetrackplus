import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/courses_provider.dart';
import '../models/assignment.dart';

const Color khaki = Color(0xFFF0E68C);

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context);
    final assignments = provider.getAllAssignments();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final bgColor = isDark ? Colors.grey[900] : Colors.white;

    final dueTomorrow = assignments.where((a) {
      final due = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
      return due == tomorrow && a.status != TaskStatus.done;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Notifications', textAlign: TextAlign.center,),
        centerTitle: true,
        backgroundColor: khaki,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: dueTomorrow.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 54, color: isDark ? Colors.grey[700] : Colors.grey[400]),
                  const SizedBox(height: 14),
                  Text(
                    'No assignments due tomorrow.',
                    style: TextStyle(fontSize: 17, color: subtitleColor),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: dueTomorrow.length,
              itemBuilder: (context, index) {
                final assignment = dueTomorrow[index];
                return Card(
                  color: cardColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: khaki, width: 2), // <-- khaki border
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: khaki,
                      child: const Icon(Icons.notifications_active, color: Colors.black87),
                    ),
                    title: Text(
                      assignment.title,
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                    ),
                    subtitle: Text(
                      'Due tomorrow',
                      style: TextStyle(color: subtitleColor),
                    ),
                  ),
                );
              },
            ),
    );
  }
}