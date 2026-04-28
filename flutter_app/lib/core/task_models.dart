import 'package:flutter/material.dart';

enum TaskPriority { none, low, medium, high }
enum TaskStatus { pending, completed }

class TaskItem {
  final String id;
  String title;
  String description;
  DateTime? dueDate;
  TaskPriority priority;
  TaskStatus status;
  String listName; // 'Inbox', 'Work', 'Personal'

  TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.none,
    this.status = TaskStatus.pending,
    this.listName = 'Inbox',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority.index,
    'status': status.index,
    'listName': listName,
  };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    priority: TaskPriority.values[json['priority'] ?? 0],
    status: TaskStatus.values[json['status'] ?? 0],
    listName: json['listName'] ?? 'Inbox',
  );
}
