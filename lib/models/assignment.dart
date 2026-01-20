import 'package:intl/intl.dart';

/// Priority levels for tasks
enum TaskPriority { high, medium, low }

/// Current status of a task
enum TaskStatus { notStarted, inProgress, done }

/// Assignment model
class Assignment {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.notStarted,
  });

  /// Formatted due date string for display
  String get formattedDueDate => DateFormat('MMM dd, yyyy').format(dueDate);

  /// Convert to map for saving to database or storage
  Map<String, dynamic> toMap() => {
        'id': id,
        'courseId': courseId,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.name, // enum saved as string
        'status': status.name,
      };

  /// Factory method to create Assignment from map
  factory Assignment.fromMap(Map<String, dynamic> map) => Assignment(
        id: map['id'],
        courseId: map['courseId'],
        title: map['title'],
        description: map['description'],
        dueDate: DateTime.parse(map['dueDate']),
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == map['priority'],
          orElse: () => TaskPriority.medium,
        ),
        status: TaskStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => TaskStatus.notStarted,
        ),
      );

  /// ✅ Used for updating specific fields (like status) easily
  Assignment copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
  }) {
    return Assignment(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }
}
