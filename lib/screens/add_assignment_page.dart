import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/assignment.dart';
import '../providers/courses_provider.dart';

const Color khaki = Color(0xFFF0E68C);

class AddAssignmentPage extends StatefulWidget {
  const AddAssignmentPage({Key? key}) : super(key: key);

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  String? _selectedCourseId;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(
                  primary: khaki,
                  onPrimary: Colors.black,
                  surface: Colors.grey[900]!,
                  onSurface: Colors.white,
                )
              : ColorScheme.light(
                  primary: khaki,
                  onPrimary: Colors.black,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) {
      setState(() => _dueDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = Provider.of<CoursesProvider>(context).courses;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final inputFill = khaki.withOpacity(isDark ? 0.18 : 0.10);
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? Colors.grey[900] : Colors.white; // Match profile page

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Assignment', textAlign: TextAlign.center,),
        centerTitle: true,
        backgroundColor: khaki,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: bgColor, // Use the same background as profile page
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
                  DropdownButtonFormField<String>(
                    value: (courses.any((c) => c.id == _selectedCourseId))
                        ? _selectedCourseId
                        : null,
                    hint: Text('Select Course', style: TextStyle(color: textColor)),
                    dropdownColor: cardColor,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.school, color: khaki),
                    ),
                    items: courses.map((course) {
                      return DropdownMenuItem<String>(
                        value: course.id,
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
                            Text(course.name, style: TextStyle(color: textColor)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCourseId = value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a course' : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Assignment Title',
                      labelStyle: TextStyle(color: textColor),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.title, color: khaki),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _descController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: textColor),
                      filled: true,
                      fillColor: inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.description, color: khaki),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: khaki, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dueDate == null
                              ? 'No due date selected'
                              : 'Due: ${DateFormat('MMM dd, yyyy').format(_dueDate!)}',
                          style: TextStyle(
                            fontSize: 15,
                            color: _dueDate == null ? Colors.grey : textColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _selectDueDate(context),
                        child: const Text('Select Date'),
                        style: TextButton.styleFrom(
                          foregroundColor: khaki,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Assignment'),
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
                      onPressed: () {
                        if (_formKey.currentState!.validate() &&
                            _dueDate != null &&
                            _selectedCourseId != null) {
                          final assignment = Assignment(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            courseId: _selectedCourseId!,
                            title: _titleController.text,
                            description: _descController.text,
                            dueDate: _dueDate!,
                          );

                          Provider.of<CoursesProvider>(context, listen: false)
                              .addAssignment(assignment);

                          Navigator.pop(context);
                        } else if (_dueDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a due date'),
                            ),
                          );
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