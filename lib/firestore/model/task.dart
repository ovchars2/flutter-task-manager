import 'dart:convert';

abstract class Task {
  final DateTime createdAt;
  final String name;
  final bool isCompleted;
  final DateTime? completedAt;

  const Task({
    required this.createdAt,
    required this.name,
    required this.isCompleted,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt.millisecondsSinceEpoch,
      'name': name,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory Task.fromJson(String src) {
    return Task.fromMap(jsonDecode(src));
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    if (map['isCompleted'] as bool) {
      return FinishedTask(
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
        name: map['name'].toString(),
        completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt']),
      );
    } else {
      return UnfinishedTask(
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
        name: map['name'].toString(),
      );
    }
  }
}

class UnfinishedTask extends Task {
  const UnfinishedTask({
    required super.createdAt,
    required super.name,
    super.completedAt = null,
    super.isCompleted = false,
  });
}

class FinishedTask extends Task {
  const FinishedTask({
    required super.createdAt,
    required super.name,
    required super.completedAt,
    super.isCompleted = true,
  });
}
