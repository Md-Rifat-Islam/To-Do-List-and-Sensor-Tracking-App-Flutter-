import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import for JSON encoding/decoding
import 'detailedtodo.dart'; // Import the Detailed Todo page

class SubTaskScreen extends StatefulWidget {
  final String listTitle;
  final String mainTask;

  const SubTaskScreen({Key? key, required this.listTitle, required this.mainTask}) : super(key: key);

  @override
  _SubTaskScreenState createState() => _SubTaskScreenState();
}

class _SubTaskScreenState extends State<SubTaskScreen> {
  final List<Map<String, dynamic>> subTaskLists = [];
  final TextEditingController _subTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubTasks();
  }

  Future<void> _loadSubTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedSubTasks = prefs.getStringList(widget.mainTask);
    if (storedSubTasks != null) {
      for (String task in storedSubTasks) {
        Map<String, dynamic> subTaskData = Map<String, dynamic>.from(json.decode(task));
        subTaskLists.add({
          'title': subTaskData['title'],
          'isCompleted': subTaskData['isCompleted'],
          'dueDate': subTaskData['dueDate'],
          'note': subTaskData['note'] ?? '',
        });
      }
    }
    setState(() {});
  }

  Future<void> _saveSubTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskStrings = subTaskLists.map((task) => json.encode(task)).toList();
    prefs.setStringList(widget.mainTask, taskStrings);
  }

  void _addSubTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add SubTask"),
          content: TextField(
            controller: _subTaskController,
            decoration: const InputDecoration(
              hintText: "Enter subtask title",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_subTaskController.text.isNotEmpty) {
                    subTaskLists.add({
                      'title': _subTaskController.text,
                      'isCompleted': false,
                      'dueDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
                      'note': '',
                    });
                    _saveSubTasks();
                  }
                  _subTaskController.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSubTask(int index) {
    setState(() {
      subTaskLists.removeAt(index);
      _saveSubTasks(); // Save changes after deletion
    });
  }

  void _navigateToDetail(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return DetailedTodoScreen(
            subTaskTitle: subTaskLists[index]['title'],
            dueDate: DateTime.parse(subTaskLists[index]['dueDate']),
            isCompleted: subTaskLists[index]['isCompleted'],
            note: subTaskLists[index]['note'],
            onDelete: () => _deleteSubTask(index),
            onUpdate: (updatedTask) {
              setState(() {
                subTaskLists[index]['note'] = updatedTask['note'];
                subTaskLists[index]['dueDate'] = updatedTask['dueDate'];
                subTaskLists[index]['isCompleted'] = updatedTask['isCompleted'];
                _saveSubTasks(); // Save changes after update
              });
            },
          );
        },
      ),
    ).then((result) {
      // Handle result if needed (like refreshing the list or showing a message)
      if (result != null && result['delete'] == true) {
        _deleteSubTask(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSubTask, // Add sub-task button
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: subTaskLists.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Row(
                children: [
                  const Text("Sub-Task: "), // Fixed text
                  Text(subTaskLists[index]['title']), // Dynamic text
                ],
              ),
              subtitle: Text("Due: ${DateTime.parse(subTaskLists[index]['dueDate']).toLocal().toString().split(' ')[0]}"),
              trailing: subTaskLists[index]['isCompleted']
                  ? const Icon(Icons.check_circle, color: Colors.green) // Blue tick for completed tasks
                  : const Icon(Icons.cancel, color: Colors.red), // Red cross for incomplete tasks
              onTap: () => _navigateToDetail(index), // Navigate to detailed view
              onLongPress: () {
                // Add a long press to delete the subtask
                _deleteSubTask(index);
              },
            ),
          );
        },
      ),
    );
  }
}
