import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_models.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskItem> _tasks = [];
  List<TaskList> _taskLists = [];

  List<TaskItem> get tasks => _tasks;
  List<TaskList> get taskLists => _taskLists;

  List<TaskItem> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((t) {
      if (t.status == TaskStatus.completed) return false;
      if (t.dueDate == null) return false;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return due.isBefore(today.add(const Duration(days: 1))); // Overdue or today
    }).toList();
  }

  List<TaskItem> get next7DaysTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));
    return _tasks.where((t) {
      if (t.status == TaskStatus.completed) return false;
      if (t.dueDate == null) return false;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return due.isAfter(today) && due.isBefore(nextWeek); 
    }).toList();
  }

  List<TaskItem> get inboxTasks {
    return _tasks.where((t) => t.listId == 'inbox' && t.status == TaskStatus.pending).toList();
  }
  
  List<TaskItem> get completedTasks {
    return _tasks.where((t) => t.status == TaskStatus.completed).toList();
  }

  List<TaskItem> tasksByList(String listId) {
    return _tasks.where((t) => t.listId == listId && t.status != TaskStatus.completed).toList();
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final tlStr = prefs.getString('taskLists');
      if (tlStr != null) {
        Iterable l = json.decode(tlStr);
        _taskLists = List<TaskList>.from(l.map((model) => TaskList.fromJson(model)));
      }

      final tkStr = prefs.getString('tasks');
      if (tkStr != null) {
        Iterable l = json.decode(tkStr);
        _tasks = List<TaskItem>.from(l.map((model) => TaskItem.fromJson(model)));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar tasks locais: $e');
    }
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tasks', json.encode(_tasks.map((t) => t.toJson()).toList()));
      await prefs.setString('taskLists', json.encode(_taskLists.map((t) => t.toJson()).toList()));
    } catch (e) {
      debugPrint('Erro ao salvar tasks locais: $e');
    }
  }

  void addTaskList(TaskList list) {
    _taskLists.add(list);
    saveData();
    notifyListeners();
  }

  void addTask(TaskItem task) {
    _tasks.add(task);
    saveData();
    notifyListeners();
  }

  void updateTask(String id, TaskItem updated) {
    final idx = _tasks.indexWhere((element) => element.id == id);
    if (idx != -1) {
      _tasks[idx] = updated;
      saveData();
      notifyListeners();
    }
  }

  void removeTask(String id) {
    _tasks.removeWhere((element) => element.id == id);
    saveData();
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final idx = _tasks.indexWhere((element) => element.id == id);
    if (idx != -1) {
      _tasks[idx].status = _tasks[idx].status == TaskStatus.pending 
          ? TaskStatus.completed 
          : TaskStatus.pending;
      saveData();
      notifyListeners();
    }
  }
}
