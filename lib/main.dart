import 'package:flutter/material.dart';
import 'home.dart'; // Import home screen
import 'todo.dart'; // Import to-do list screen
import 'sensor.dart'; // Import sensor tracking screen
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Set HomeScreen as the initial route
      routes: {
        '/todo': (context) => const TodoScreen(), // Define route for ToDoScreen
        '/sensor': (context) => const SensorScreen(), // Define route for SensorScreen
      },
    );
  }
}
