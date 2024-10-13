class TodoItem {
  String heading;
  String details;
  bool isCompleted;
  DateTime dueDate;
  List<TodoItem> subtasks; // List of subtasks
  int id; // Task ID

  TodoItem({
    required this.heading,
    required this.details,
    required this.dueDate,
    this.isCompleted = false,
    this.subtasks = const [], // Initialize subtasks as an empty list
    required this.id, // ID for tasks
  });

  // Add toJson method if you want to serialize this object for persistence
  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'details': details,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
      'id': id,
    };
  }

  // Add fromJson method if you want to deserialize JSON to a TodoItem object
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      heading: json['heading'],
      details: json['details'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: DateTime.parse(json['dueDate']),
      subtasks: (json['subtasks'] as List<dynamic>?)
          ?.map((subtaskJson) => TodoItem.fromJson(subtaskJson))
          .toList() ??
          [],
      id: json['id'], // Add this for the ID field
    );
  }
}
