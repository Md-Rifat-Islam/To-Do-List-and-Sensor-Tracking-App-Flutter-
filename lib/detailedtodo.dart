import 'package:flutter/material.dart';
import 'dart:convert'; // Required for JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';

class DetailedTodoScreen extends StatefulWidget {
  final String subTaskTitle;
  final DateTime dueDate; // Accept due date
  final bool isCompleted; // Accept completion status
  final String note;
  final Function onDelete; // Accept delete function callback
  final Function(Map<String, dynamic>) onUpdate; // Accept update function callback

  const DetailedTodoScreen({
    Key? key,
    required this.subTaskTitle,
    required this.dueDate,
    required this.isCompleted,
    required this.note,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _DetailedTodoScreenState createState() => _DetailedTodoScreenState();
}

class _DetailedTodoScreenState extends State<DetailedTodoScreen> {
  late TextEditingController _noteController; // Initialize the note controller
  DateTime? _dueDate; // Declare due date variable
  bool _isCompleted = false; // Track completion status

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _loadTaskData(); // Load saved data when initializing the screen
  }

  // Function to load task data from SharedPreferences
  Future<void> _loadTaskData() async {
    final prefs = await SharedPreferences.getInstance();
    String? taskDataJson = prefs.getString(widget.subTaskTitle);

    if (taskDataJson != null) {
      Map<String, dynamic> taskData = json.decode(taskDataJson);
      setState(() {
        _noteController.text = taskData['note'] ?? '';
        _dueDate = taskData['dueDate'] != null ? DateTime.parse(taskData['dueDate']) : widget.dueDate;
        _isCompleted = taskData['isCompleted'] ?? widget.isCompleted;
      });
    } else {
      _noteController.text = ""; // No saved data, start with empty note
      _dueDate = widget.dueDate;
      _isCompleted = widget.isCompleted;
    }
  }

  // Function to save task data to SharedPreferences
  Future<void> _saveTaskData() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> taskData = {
      'note': _noteController.text,
      'dueDate': _dueDate?.toIso8601String(),
      'isCompleted': _isCompleted,
    };
    prefs.setString(widget.subTaskTitle, json.encode(taskData));
  }

  // Function to confirm deletion of the task
  void _confirmDeleteTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Do not delete
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete(); // Call the delete function passed from the parent
                Navigator.of(context).pop(true); // Close the dialog
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // Function to select a due date
  Future<void> _selectDueDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate; // Update the due date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveTaskData(); // Save the task data before popping
        return true; // Allow the pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.subTaskTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                final updatedTask = {
                  'note': _noteController.text,
                  'dueDate': _dueDate?.toIso8601String(),
                  'isCompleted': _isCompleted,
                };

                widget.onUpdate(updatedTask); // Call the onUpdate function with the updated task data

                _saveTaskData(); // Save the task data to SharedPreferences
                Navigator.of(context).pop({'delete': false}); // No deletion, just save
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: "Note",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Due Date: ${_dueDate?.toLocal().toString().split(' ')[0] ?? 'Not Set'}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDueDate(context), // Open date picker
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Completed", style: TextStyle(fontSize: 18)),
                  Switch(
                    value: _isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _isCompleted = value;
                      });
                    },
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _confirmDeleteTask, // Confirm task deletion
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Set button color to red
                ),
                child: const Text("Delete Task", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
