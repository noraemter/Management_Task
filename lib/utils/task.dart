class Task {
  int? id; 
  String name;
  bool isCompleted;

  Task({this.id, required this.name, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted ? 1 : 0, 
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      isCompleted: map['isCompleted'] == 1, 
    );
  }

  Task copyWith({int? id, String? name, bool? isCompleted}) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
