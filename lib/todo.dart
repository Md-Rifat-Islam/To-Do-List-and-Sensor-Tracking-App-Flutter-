import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for JSON encoding/decoding
import 'subtodo.dart'; // Import the SubTaskScreen

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedTasks = prefs.getStringList('tasks');
    if (storedTasks != null) {
      for (String task in storedTasks) {
        Map<String, dynamic> taskData = Map<String, dynamic>.from(json.decode(task));
        tasks.add(taskData);
      }
    }
    setState(() {});
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskStrings = tasks.map((task) => json.encode(task)).toList();
    prefs.setStringList('tasks', taskStrings);
  }

  // Add a new task
  void _addTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Task"),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              hintText: "Enter main task title",
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
                  if (_taskController.text.isNotEmpty) {
                    tasks.add({
                      'title': _taskController.text,
                      'subTasks': [],
                    });
                    _saveTasks(); // Save tasks after adding
                  }
                  _taskController.clear();
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

  // Navigate to the SubTaskScreen
  void _navigateToSubTasks(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return SubTaskScreen(
            listTitle: tasks[index]['title'],
            mainTask: tasks[index]['title'],
          );
        },
      ),
    ).then((result) {
      if (result != null) {
        // Handle the result if needed (e.g., refresh the task list)
        _loadTasks(); // Refresh the task list after returning from the sub-task screen
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTask, // Add task button
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
            ),
              child: ListTile(
                title:
                Row(
                  children: [
                    const
                    Text( "Task: ",
                      style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                      ),// Fixed text
                    Text(tasks[index]['title'],
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20.0,
                          color: Colors.black),),
                  ],
                ),
                onTap: () => _navigateToSubTasks(index), // Navigate to sub-tasks
              ),
          );
        },
      ),
    );
  }
}
