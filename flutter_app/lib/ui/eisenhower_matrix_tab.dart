import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/task_provider.dart';
import '../core/task_models.dart';

class EisenhowerMatrixTab extends StatelessWidget {
  const EisenhowerMatrixTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final allPending = provider.tasks.where((e) => e.status != TaskStatus.completed).toList();

    final q1 = allPending.where((e) => e.priority == TaskPriority.high).toList(); // Important & Urgent (We simplify highest priority here)
    final q2 = allPending.where((e) => e.priority == TaskPriority.medium).toList(); // Important, Not Urgent
    final q3 = allPending.where((e) => e.priority == TaskPriority.low).toList(); // Urgent, Not Important
    final q4 = allPending.where((e) => e.priority == TaskPriority.none).toList(); // Not Urgent, Not Important

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Matriz de Eisenhower', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildQuadrant(context, 'Pendente e Urgente', q1, Colors.red.shade100, Colors.red)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildQuadrant(context, 'Agendar', q2, Colors.orange.shade100, Colors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildQuadrant(context, 'Delegar', q3, Colors.blue.shade100, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildQuadrant(context, 'Eliminar / Depois', q4, Colors.grey.shade200, Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuadrant(BuildContext context, String title, List<TaskItem> tasks, Color bgColor, Color headerColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: headerColor.withOpacity(0.8), fontSize: 13)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tasks.length,
              itemBuilder: (ctx, i) {
                final t = tasks[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.read<TaskProvider>().toggleTaskStatus(t.id),
                        child: const Icon(Icons.circle_outlined, size: 20, color: Colors.black38),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
