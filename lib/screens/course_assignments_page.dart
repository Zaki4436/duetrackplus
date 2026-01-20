import 'package:duetrack/screens/edit_course_page.dart' as edit_course;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/courses_provider.dart';
import '../screens/add_assignment_page.dart'; 

class CourseAssignmentsPage extends StatelessWidget {
  final Course course;
  
  const CourseAssignmentsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: GestureDetector(
    onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => edit_course.EditCoursePage(course: course),
        ),
      );
    },
    child: Text(
      course.name,
      style: const TextStyle(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
      ),
    ),
  ),
  backgroundColor: edit_course.khaki,
  foregroundColor: Colors.black87,
  elevation: 1,
),
      body: Consumer<CoursesProvider>(
        builder: (context, provider, child) {
          final assignments = provider.getAssignmentsForCourse(course.id);
          
          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return Card(
                child: ListTile(
                  title: Text(assignment.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignment.description),
                      Text('Due: ${assignment.dueDate.toLocal()}'.split(' ')[0]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAssignmentPage(),
              // Pass the course if you want to preselect it
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}