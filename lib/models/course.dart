import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Model for a course/subject
class Course {
  final String id;
  final String name;
  final Color color;
  final String description;

  Course({
    required this.id,
    required this.name,
    required this.color,
    this.description = '',
  });

  /// Factory constructor to create a course with a random ID
  factory Course.create({
    required String name,
    required Color color,
    String description = '',
  }) {
    return Course(
      id: const Uuid().v4(),
      name: name,
      description: description,
      color: color,
    );
  }

  /// Copy with new values
  Course copyWith({
    String? id,
    String? name,
    Color? color,
    String? description,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'color': color.value,
      };

  /// Create from map
  factory Course.fromMap(Map<String, dynamic> map) => Course(
        id: map['id'],
        name: map['name'],
        description: map['description'] ?? '',
        color: Color(map['color']),
      );

  /// Optional: Used for equality check or display
  @override
  String toString() => 'Course(name: $name, color: $color)';
}
