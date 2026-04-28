import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/task_provider.dart';
import '../core/task_models.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;
  const TaskDetailPage({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.none;
  DateTime? _dueDate;
  DateTime? _time;
  
  late TaskItem task;

  @override
  void initState() {
    super.initState();
    final p = context.read<TaskProvider>();
    final found = p.tasks.firstWhere((e) => e.id == widget.taskId);
    task = found;
    _titleCtrl.text = task.title;
    _descCtrl.text = task.description;
    _priority = task.priority;
    _dueDate = task.dueDate;
    _time = task.time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              context.read<TaskProvider>().removeTask(task.id);
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              task.title = _titleCtrl.text;
              task.description = _descCtrl.text;
              task.priority = _priority;
              task.dueDate = _dueDate;
              task.time = _time;
              context.read<TaskProvider>().updateTask(task.id, task);
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: 'Título da Tarefa',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(_dueDate != null ? DateFormat('dd MMM yyyy').format(_dueDate!) : 'Sem data'),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _dueDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (d != null) setState(() => _dueDate = d);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: Text(_time != null ? DateFormat('HH:mm').format(_time!) : 'Sem horário'),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (t != null) {
                final now = DateTime.now();
                setState(() => _time = DateTime(now.year, now.month, now.day, t.hour, t.minute));
              }
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag_outlined),
            title: DropdownButtonHideUnderline(
              child: DropdownButton<TaskPriority>(
                value: _priority,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: TaskPriority.none, child: Text('Nenhuma prioridade')),
                  DropdownMenuItem(value: TaskPriority.low, child: Text('Baixa', style: TextStyle(color: Colors.blue))),
                  DropdownMenuItem(value: TaskPriority.medium, child: Text('Média', style: TextStyle(color: Colors.orange))),
                  DropdownMenuItem(value: TaskPriority.high, child: Text('Alta', style: TextStyle(color: Colors.red))),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Adicione detalhes...',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            ),
          )
        ],
      ),
    );
  }
}
