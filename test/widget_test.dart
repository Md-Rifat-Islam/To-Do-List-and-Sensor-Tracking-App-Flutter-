import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/home.dart';  // Import your home screen

void main() {
  testWidgets('Home screen has two buttons and navigates correctly', (WidgetTester tester) async {
    // Build the HomeScreen and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Verify that both buttons (To-Do List and Sensor Tracking) are present.
    expect(find.text('To-Do List'), findsOneWidget);
    expect(find.text('Sensor Tracking'), findsOneWidget);

    // Tap on the 'To-Do List' button and trigger a frame.
    await tester.tap(find.text('To-Do List'));
    await tester.pumpAndSettle(); // Wait for navigation and animations

    // Verify that after tapping, the 'Daily To-Do App' text is shown.
    expect(find.text('Daily To-Do App'), findsOneWidget);

    // Go back to HomeScreen by simulating back button or Navigator.pop().
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    // Tap on the 'Sensor Tracking' button and trigger a frame.
    await tester.tap(find.text('Sensor Tracking'));
    await tester.pumpAndSettle(); // Wait for navigation

    // Verify that after tapping, the 'Sensor Tracking Feature' text is shown.
    expect(find.text('Sensor Tracking Feature'), findsOneWidget);
  });
}
