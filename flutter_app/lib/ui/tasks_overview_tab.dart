import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/task_provider.dart';
import '../core/task_models.dart';
import 'task_detail_page.dart';
import 'eisenhower_matrix_tab.dart';
import 'pomodoro_timer_tab.dart';
import 'habit_tracker_tab.dart';

class TasksOverviewTab extends StatefulWidget {
  const TasksOverviewTab({super.key});

  @override
  State<TasksOverviewTab> createState() => _TasksOverviewTabState();
}

class _TasksOverviewTabState extends State<TasksOverviewTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(text: 'Hoje'),
                    Tab(text: 'Inbox'),
                    Tab(text: 'Concluídas'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.grid_view),
                tooltip: 'Matriz de Eisenhower',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EisenhowerMatrixTab()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.timer_outlined),
                tooltip: 'Foco (Pomodoro)',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PomodoroTimerTab()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.loop),
                tooltip: 'Hábitos',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HabitTrackerTab()));
                },
              )
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(context, (p) => p.todayTasks, isToday: true),
              _buildTaskList(context, (p) => p.inboxTasks),
              _buildTaskList(context, (p) => p.completedTasks),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context, List<TaskItem> Function(TaskProvider) selector, {bool isToday = false}) {
    final provider = context.watch<TaskProvider>();
    final tasks = selector(provider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isToday ? Icons.wb_sunny_outlined : Icons.inbox_outlined, size: 64, color: Colors.black26),
                  const SizedBox(height: 16),
                  const Text('Nenhuma tarefa aqui.', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isCompleted = task.status == TaskStatus.completed;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3F4F6))
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: GestureDetector(
                      onTap: () => provider.toggleTaskStatus(task.id),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isCompleted ? Colors.green : Colors.black26, width: 2),
                          color: isCompleted ? Colors.green : Colors.transparent,
                        ),
                        child: isCompleted 
                            ? const Icon(Icons.check, size: 16, color: Colors.white) 
                            : null,
                      ),
                    ),
                    title: GestureDetector(
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailPage(taskId: task.id)));
                      },
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.black38 : Colors.black87,
                        ),
                      ),
                    ),
                    subtitle: task.dueDate != null 
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              DateFormat('dd MMM, yyyy').format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 12,
                                color: task.dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1))) && !isCompleted
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                          )
                        : null,
                    trailing: _buildPriorityIndicator(task.priority),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showAddTaskForm(context),
      ),
    );
  }

  Widget? _buildPriorityIndicator(TaskPriority priority) {
    if (priority == TaskPriority.none) return null;
    Color color;
    switch (priority) {
      case TaskPriority.high: color = Colors.red; break;
      case TaskPriority.medium: color = Colors.amber; break;
      case TaskPriority.low: color = Colors.blue; break;
      default: color = Colors.transparent;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  void _showAddTaskForm(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.none;
    DateTime? selectedDate;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Nova Tarefa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 24),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Título da Tarefa',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: 'Descrição (opcional)',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data de Vencimento', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : 'Sem data'),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100)
                  );
                  if (date != null) setState(() => selectedDate = date);
                },
              ),
              const SizedBox(height: 16),
              const Text('Prioridade', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _priorityButton('Nenhuma', TaskPriority.none, selectedPriority, Colors.grey, () => setState(() => selectedPriority = TaskPriority.none)),
                  _priorityButton('Baixa', TaskPriority.low, selectedPriority, Colors.blue, () => setState(() => selectedPriority = TaskPriority.low)),
                  _priorityButton('Média', TaskPriority.medium, selectedPriority, Colors.amber, () => setState(() => selectedPriority = TaskPriority.medium)),
                  _priorityButton('Alta', TaskPriority.high, selectedPriority, Colors.red, () => setState(() => selectedPriority = TaskPriority.high)),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    final task = TaskItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      dueDate: selectedDate,
                      priority: selectedPriority,
                    );
                    context.read<TaskProvider>().addTask(task);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Salvar Tarefa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priorityButton(String label, TaskPriority value, TaskPriority current, Color color, VoidCallback onTap) {
    bool isSelected = value == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.black26),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Text(label, style: TextStyle(color: isSelected ? color : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}
