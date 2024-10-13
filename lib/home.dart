import 'package:flutter/material.dart';
import 'todo.dart'; // Import the ToDo screen
import 'sensor.dart'; // Import the Sensor Tracking screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int completedTasks = 0;
  int incompleteTasks = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display completed and incomplete task counts
            // Text(
            //   '# Completed: $completedTasks, Incomplete: $incompleteTasks',
            //   style: const TextStyle(
            //     fontFamily: 'Inter',
            //     fontSize: 18.0,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            const SizedBox(height: 30),

            // Button to navigate to the To-Do List screen
            Container(
              width: 280,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(_createRouteToDo());
                  if (result != null) {
                    setState(() {
                      completedTasks = result['completedTasks'];
                      incompleteTasks = result['incompleteTasks'];
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'A To-Do List',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 32.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Button to navigate to the Sensor Tracking screen
            Container(
              width: 280,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SensorScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Sensor Tracking',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 32.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom transition animation for navigating to the To-Do List screen
  Route _createRouteToDo() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const TodoScreen(), // Navigate to TodoScreen
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0); // Start from below the screen
        const end = Offset.zero; // End at the center of the screen
        const curve = Curves.easeInOut; // Animation curve

        // Define the animation tween
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        // Create the slide transition
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation, // Fade in
            child: child,
          ),
        );
      },
    );
  }
}
