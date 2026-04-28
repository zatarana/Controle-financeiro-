import 'package:flutter/material.dart';

enum TaskPriority { none, low, medium, high }
enum TaskStatus { pending, completed, postponed }

class Subtask {
  String id;
  String title;
  bool isCompleted;

  Subtask({required this.id, required this.title, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'] ?? false,
  );
}

class TaskItem {
  final String id;
  String title;
  String description;
  DateTime? dueDate;
  DateTime? time; // Hora específica
  TaskPriority priority;
  TaskStatus status;
  String listId; 
  List<String> tags;
  List<Subtask> subtasks;
  int? estimatedDurationMinutes; // Estimativa de duração
  DateTime? createdAt;

  TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.time,
    this.priority = TaskPriority.none,
    this.status = TaskStatus.pending,
    this.listId = 'inbox',
    this.tags = const [],
    this.subtasks = const [],
    this.estimatedDurationMinutes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate?.toIso8601String(),
    'time': time?.toIso8601String(),
    'priority': priority.index,
    'status': status.index,
    'listId': listId,
    'tags': tags,
    'subtasks': subtasks.map((e) => e.toJson()).toList(),
    'estimatedDurationMinutes': estimatedDurationMinutes,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    time: json['time'] != null ? DateTime.parse(json['time']) : null,
    priority: TaskPriority.values[json['priority'] ?? 0],
    status: TaskStatus.values[json['status'] ?? 0],
    listId: json['listId'] ?? 'inbox',
    tags: List<String>.from(json['tags'] ?? []),
    subtasks: (json['subtasks'] as List?)?.map((e) => Subtask.fromJson(e)).toList() ?? [],
    estimatedDurationMinutes: json['estimatedDurationMinutes'],
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
  );
}

class TaskList {
  final String id;
  String name;
  String colorHex;
  String? folderId;

  TaskList({required this.id, required this.name, this.colorHex = '#000000', this.folderId});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorHex': colorHex,
    'folderId': folderId,
  };

  factory TaskList.fromJson(Map<String, dynamic> json) => TaskList(
    id: json['id'],
    name: json['name'],
    colorHex: json['colorHex'] ?? '#000000',
    folderId: json['folderId'],
  );
}

