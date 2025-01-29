class Task {
  int? id; // Optional, if you plan to store it in a database
  String name;
  bool isCompleted;

  Task({this.id, required this.name, this.isCompleted = false});

  // Convert a Task object into a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted ? 1 : 0, // Store 1 for true, 0 for false
    };
  }

  // Convert a map into a Task object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      isCompleted: map['isCompleted'] == 1, // Convert 1 back to true, 0 to false
    );
  }

  // Add the copyWith method
  Task copyWith({int? id, String? name, bool? isCompleted}) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
