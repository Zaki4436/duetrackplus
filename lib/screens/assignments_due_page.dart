import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../models/course.dart';
import '../providers/courses_provider.dart';
import 'add_assignment_page.dart';
import 'assignment_detail_page.dart';

const Color khaki = Color(0xFFF0E68C);

class AssignmentsDuePage extends StatefulWidget {
  const AssignmentsDuePage({Key? key}) : super(key: key);

  @override
  State<AssignmentsDuePage> createState() => _AssignmentsDuePageState();
}

class _AssignmentsDuePageState extends State<AssignmentsDuePage> {
  TaskStatus? _selectedStatus;

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter by Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              RadioListTile<TaskStatus?>(
                title: const Text('All'),
                value: null,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<TaskStatus>(
                title: const Text('Not Started'),
                value: TaskStatus.notStarted,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<TaskStatus>(
                title: const Text('In Progress'),
                value: TaskStatus.inProgress,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<TaskStatus>(
                title: const Text('Completed'),
                value: TaskStatus.done,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return Colors.red;
      case TaskStatus.inProgress:
        return Colors.amber;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  String _statusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return 'Not Started';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.black87;
    final bgColor = isDark ? Colors.grey[900] : Colors.grey[100];

    final Map<Course, List<Assignment>> activeAssignments = {};
    final List<Assignment> completedAssignments = [];

    for (final course in provider.courses) {
      final assignments = provider.getAssignmentsForCourse(course.id);

      final filtered = assignments
          .where((a) => _selectedStatus == null || a.status == _selectedStatus)
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

      final active = filtered.where((a) => a.status != TaskStatus.done).toList();
      final completed = filtered.where((a) => a.status == TaskStatus.done).toList();

      if (active.isNotEmpty) activeAssignments[course] = active;
      completedAssignments.addAll(completed);
    }

    Future<void> _refresh() async {
      setState(() {});
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: const Text('Due Assignments'),
        backgroundColor: khaki,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Assignment',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAssignmentPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: bgColor,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            children: [
              if (activeAssignments.isEmpty && completedAssignments.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No assignments yet!',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ...activeAssignments.entries.map((entry) {
                final course = entry.key;
                final assignments = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: course.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            course.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...assignments.map((assignment) {
                      final bgColorCard = _getStatusColor(assignment.status).withOpacity(isDark ? 0.18 : 0.08);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: bgColorCard,
                        child: ListTile(
                          leading: Icon(Icons.assignment, color: _getStatusColor(assignment.status)),
                          title: Text(
                            assignment.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
                                style: TextStyle(fontSize: 13, color: subtitleColor),
                              ),
                              if (assignment.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    assignment.description,
                                    style: TextStyle(fontSize: 13, color: subtitleColor),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(assignment.status).withOpacity(isDark ? 0.22 : 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _statusText(assignment.status),
                              style: TextStyle(
                                color: _getStatusColor(assignment.status),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AssignmentDetailPage(assignment: assignment),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ],
                );
              }),

              if (completedAssignments.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 32, 8, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Completed Assignments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ...completedAssignments.map((assignment) {
                  final course = provider.courses.firstWhere(
                    (c) => c.id == assignment.courseId,
                    orElse: () => Course(id: '', name: 'Unknown', color: Colors.grey),
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                    elevation: 1,
                    color: isDark ? Colors.green.withOpacity(0.13) : Colors.green.withOpacity(0.07),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: course.color, radius: 8),
                      title: Text(
                        assignment.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}'
                        '${assignment.description.isNotEmpty ? '\n${assignment.description}' : ''}',
                        style: TextStyle(fontSize: 13, color: subtitleColor),
                      ),
                      trailing: const Icon(Icons.check, color: Colors.green),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssignmentDetailPage(assignment: assignment),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterBottomSheet,
        child: const Icon(Icons.filter_alt),
        tooltip: 'Filter Assignments',
        backgroundColor: khaki,
        foregroundColor: Colors.black87,
      ),
    );
  }
}