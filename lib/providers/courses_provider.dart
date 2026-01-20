import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/assignment.dart';
import '../database_helper.dart';

class CoursesProvider with ChangeNotifier {
  final List<Course> _courses = [];
  final List<Assignment> _assignments = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Course> get courses => [..._courses];
  List<Assignment> get assignments => [..._assignments];

  /// Load courses and assignments from the database
  Future<void> loadData() async {
    _courses.clear();
    _assignments.clear();
    _courses.addAll(await _dbHelper.getAllCourses());
    _assignments.addAll(await _dbHelper.getAllAssignments());
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    await _dbHelper.insertCourse(course);
    _courses.add(course);
    notifyListeners();
  }

  Future<void> addAssignment(Assignment assignment) async {
    await _dbHelper.insertAssignment(assignment);
    _assignments.add(assignment);
    notifyListeners();
  }

  List<Assignment> getAssignmentsForCourse(String courseId) {
    return _assignments.where((a) => a.courseId == courseId).toList();
  }

  Future<void> updateCourse(Course updatedCourse) async {
    await _dbHelper.updateCourse(updatedCourse);
    final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;
      notifyListeners();
    }
  }

  Future<void> removeCourse(String courseId) async {
    await _dbHelper.deleteCourse(courseId);
    await _dbHelper.deleteAssignmentsByCourse(courseId);
    _courses.removeWhere((c) => c.id == courseId);
    _assignments.removeWhere((a) => a.courseId == courseId);
    notifyListeners();
  }

  List<Assignment> getAllAssignments() {
    return [..._assignments];
  }

  Future<void> updateAssignment(Assignment updated) async {
    await _dbHelper.updateAssignment(updated);
    final index = _assignments.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _assignments[index] = updated;
      notifyListeners();
    }
  }

  Future<void> updateAssignmentByFields(
    String id, {
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
  }) async {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _assignments[index];
      final updated = Assignment(
        id: old.id,
        courseId: old.courseId,
        title: title ?? old.title,
        description: description ?? old.description,
        dueDate: dueDate ?? old.dueDate,
        priority: priority ?? old.priority,
        status: status ?? old.status,
      );
      await _dbHelper.updateAssignment(updated);
      _assignments[index] = updated;
      notifyListeners();
    }
  }
}
