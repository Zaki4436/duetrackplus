import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../providers/courses_provider.dart';

const Color khaki = Color(0xFFF0E68C);

class AssignmentDetailPage extends StatefulWidget {
  final Assignment assignment;
  const AssignmentDetailPage({super.key, required this.assignment});

  @override
  State<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _dueDate;
  late TaskStatus _status;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignment.title);
    _descController = TextEditingController(text: widget.assignment.description);
    _dueDate = widget.assignment.dueDate;
    _status = widget.assignment.status;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoursesProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final inputFill = khaki.withOpacity(isDark ? 0.18 : 0.10);
    final textColor = isDark ? Colors.white : Colors.black87;
     final bgColor = isDark ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Edit Assignment', textAlign: TextAlign.center,),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: textColor),
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.title, color: khaki),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
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
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Due Date', style: TextStyle(color: textColor)),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(_dueDate),
                    style: TextStyle(color: textColor),
                  ),
                  trailing: Icon(Icons.calendar_today, color: khaki),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
                    if (picked != null) {
                      setState(() => _dueDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<TaskStatus>(
                  value: _status,
                  dropdownColor: cardColor,
                  onChanged: (value) => setState(() => _status = value!),
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_statusText(status), style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(color: textColor),
                    filled: true,
                    fillColor: inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.flag, color: khaki),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
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
                      final updated = widget.assignment.copyWith(
                        title: _titleController.text,
                        description: _descController.text,
                        dueDate: _dueDate,
                        status: _status,
                      );
                      provider.updateAssignment(updated);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}