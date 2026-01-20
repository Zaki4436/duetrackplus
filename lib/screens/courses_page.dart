import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/courses_provider.dart';
import 'add_course_page.dart';
import 'edit_course_page.dart';

const Color khaki = Color(0xFFF0E68C);

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.grey;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: khaki,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Course',
            color: Colors.black87,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCoursePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CoursesProvider>(
        builder: (context, provider, child) {
          final courses = provider.courses;

          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  const SizedBox(height: 18),
                  Text(
                    'No courses added yet.\nTap + to add your first course!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final course = courses[index];

              return Card(
                elevation: 2,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                color: isDark ? khaki.withOpacity(0.08) : khaki.withOpacity(0.13),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: course.color,
                    child: const Icon(Icons.book, color: Colors.white, size: 18),
                  ),
                  title: Text(
                    course.name,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: textColor),
                  ),
                  subtitle: Text(
                    course.description.isNotEmpty
                        ? course.description
                        : 'No description',
                    style: TextStyle(color: subtitleColor, fontSize: 13),
                  ),
                  trailing: Icon(Icons.chevron_right, color: isDark ? Colors.grey[400] : Colors.black54),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCoursePage(course: course),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}