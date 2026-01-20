import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/assignment.dart';
import '../models/course.dart';
import '../providers/courses_provider.dart';
import 'package:intl/intl.dart';

const Color khaki = Color(0xFFF0E68C);

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context);
    final assignments = provider.getAllAssignments();
    final courses = provider.courses;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300] : Colors.black87;
    final bgColor = isDark ? Colors.grey[900] : Colors.white;

    // Group assignments by due date
    Map<DateTime, List<Assignment>> assignmentMap = {};
    for (var a in assignments) {
      final date = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
      assignmentMap.putIfAbsent(date, () => []).add(a);
    }

    List<Assignment> _getAssignmentsForDay(DateTime day) {
      final key = DateTime(day.year, day.month, day.day);
      return assignmentMap[key] ?? [];
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Calendar', textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: khaki,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: khaki.withOpacity(isDark ? 0.18 : 0.13),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: khaki, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: khaki.withOpacity(isDark ? 0.05 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getAssignmentsForDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: isDark ? Colors.brown[100] : Colors.brown[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: isDark ? Colors.brown[100] : Colors.brown[700]),
                  rightChevronIcon: Icon(Icons.chevron_right, color: isDark ? Colors.brown[100] : Colors.brown[700]),
                  decoration: BoxDecoration(
                    color: khaki.withOpacity(isDark ? 0.35 : 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: khaki,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.deepOrange,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: true,
                  defaultTextStyle: TextStyle(color: textColor),
                  weekendTextStyle: TextStyle(color: isDark ? Colors.orange[200] : Colors.orange[900]),
                  disabledTextStyle: TextStyle(color: isDark ? Colors.grey[700] : Colors.grey[400]),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox.shrink();

                    final dots = events.take(3).map((e) {
                      final assignment = e as Assignment;
                      final course = courses.firstWhere(
                        (c) => c.id == assignment.courseId,
                        orElse: () => Course(id: '', name: 'Unknown', description: '', color: Colors.grey),
                      );

                      final isCompleted = assignment.status == TaskStatus.done;

                      return Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.grey : course.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      );
                    }).toList();

                    return Row(mainAxisAlignment: MainAxisAlignment.center, children: dots);
                  },
                ),
              ),
            ),
          ),
          if (_selectedDay != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Builder(builder: (_) {
                  final selectedAssignments = _getAssignmentsForDay(_selectedDay!);
                  if (selectedAssignments.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 54, color: isDark ? Colors.grey[700] : Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          "No assignments due.",
                          style: TextStyle(fontSize: 17, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    itemCount: selectedAssignments.length,
                    itemBuilder: (context, index) {
                      final a = selectedAssignments[index];
                      final course = courses.firstWhere(
                        (c) => c.id == a.courseId,
                        orElse: () => Course(id: '', name: 'Unknown', description: '', color: Colors.grey),
                      );

                      final isCompleted = a.status == TaskStatus.done;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        color: isCompleted
                            ? (isDark ? Colors.green.withOpacity(0.13) : Colors.green.withOpacity(0.07))
                            : (isDark ? course.color.withOpacity(0.18) : course.color.withOpacity(0.09)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: course.color,
                            radius: 8,
                            child: isCompleted
                                ? const Icon(Icons.check, size: 12, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            a.title,
                            style: TextStyle(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? Colors.grey : textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Due: ${DateFormat('MMM dd, yyyy').format(a.dueDate)}',
                            style: TextStyle(
                              color: isCompleted ? Colors.grey : subtitleColor,
                            ),
                          ),
                          trailing: isCompleted
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}