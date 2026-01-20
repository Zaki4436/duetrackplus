import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/courses_provider.dart';
import '../database_helper.dart';

const Color khaki = Color(0xFFF0E68C);

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({Key? key}) : super(key: key);

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  Color _selectedColor = Colors.blue;

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final inputFill = khaki.withOpacity(isDark ? 0.18 : 0.10);
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? Colors.grey[900] : Colors.white; // Match profile page

    return Scaffold(
      backgroundColor: bgColor, // Use the same background as profile page
      appBar: AppBar(
        title: const Text('Add New Course', textAlign: TextAlign.center,),
        centerTitle: true,
        backgroundColor: khaki,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: khaki.withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: khaki, width: 1.5),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Course Name',
                      labelStyle: TextStyle(color: textColor),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.book, color: khaki),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      labelStyle: TextStyle(color: textColor),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.description, color: khaki),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Color:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: _colorOptions.map((color) {
                      return ChoiceChip(
                        label: const Text(""),
                        selected: _selectedColor == color,
                        onSelected: (_) => setState(() => _selectedColor = color),
                        selectedColor: color,
                        backgroundColor: color.withOpacity(0.5),
                        avatar: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Course'),
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final newCourse = Course.create(
                            name: _nameController.text,
                            description: _descController.text,
                            color: _selectedColor,
                          );

                          // Save to SQLite
                          await DatabaseHelper().insertCourse(newCourse);

                          // Update in Provider
                          Provider.of<CoursesProvider>(context, listen: false)
                              .addCourse(newCourse);

                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}