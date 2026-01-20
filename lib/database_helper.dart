import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../models/assignment.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'duetack.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        name TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        color INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE assignments (
        id TEXT PRIMARY KEY,
        courseId TEXT,
        title TEXT,
        description TEXT,
        dueDate TEXT,
        priority TEXT,
        status TEXT,
        FOREIGN KEY(courseId) REFERENCES courses(id)
      )
    ''');
  }

  // ------------------ USERS ------------------

  Future<int> registerUser(User user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return -1; // Duplicate or error
    }
  }

  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  // ------------------ COURSES ------------------

  Future<void> insertCourse(Course course) async {
    final db = await database;
    await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Course>> getAllCourses() async {
    final db = await database;
    final result = await db.query('courses');
    return result.map((map) => Course.fromMap(map)).toList();
  }

  Future<void> updateCourse(Course course) async {
    final db = await database;
    await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }
//
  Future<void> deleteCourse(String id) async {
    final db = await database;
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
    await db.delete('assignments', where: 'courseId = ?', whereArgs: [id]); // Cascade delete
  }

  // ------------------ ASSIGNMENTS ------------------

  Future<void> insertAssignment(Assignment assignment) async {
    final db = await database;
    await db.insert(
      'assignments',
      assignment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Assignment>> getAllAssignments() async {
    final db = await database;
    final result = await db.query('assignments');
    return result.map((map) => Assignment.fromMap(map)).toList();
  }

  Future<List<Assignment>> getAssignmentsByCourse(String courseId) async {
    final db = await database;
    final result = await db.query(
      'assignments',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
    return result.map((map) => Assignment.fromMap(map)).toList();
  }

  Future<void> updateAssignment(Assignment assignment) async {
    final db = await database;
    await db.update(
      'assignments',
      assignment.toMap(),
      where: 'id = ?',
      whereArgs: [assignment.id],
    );
  }

  Future<void> deleteAssignment(String id) async {
    final db = await database;
    await db.delete('assignments', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAssignmentsByCourse(String courseId) async {
    final db = await database;
    await db.delete('assignments', where: 'courseId = ?', whereArgs: [courseId]);
  }
}
