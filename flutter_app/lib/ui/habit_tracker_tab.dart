import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class HabitTrackerTab extends StatefulWidget {
  const HabitTrackerTab({Key? key}) : super(key: key);

  @override
  State<HabitTrackerTab> createState() => _HabitTrackerTabState();
}

class Habit {
  String id;
  String name;
  List<String> activeDates; // ISO strings

  Habit({required this.id, required this.name, this.activeDates = const []});
}

class _HabitTrackerTabState extends State<HabitTrackerTab> {
  List<Habit> habits = [];
  final df = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    final p = await SharedPreferences.getInstance();
    final hStr = p.getString('habits');
    if (hStr != null) {
      Iterable l = jsonDecode(hStr);
      habits = l.map((e) => Habit(
        id: e['id'], 
        name: e['name'], 
        activeDates: List<String>.from(e['activeDates'] ?? [])
      )).toList();
    }
    setState(() {});
  }

  void _saveHabits() async {
    final p = await SharedPreferences.getInstance();
    final l = habits.map((e) => {'id': e.id, 'name': e.name, 'activeDates': e.activeDates}).toList();
    p.setString('habits', jsonEncode(l));
  }

  void _toggleHabit(Habit h, String dateStr) {
    if (h.activeDates.contains(dateStr)) {
      h.activeDates.remove(dateStr);
    } else {
      h.activeDates.add(dateStr);
    }
    setState(() {});
    _saveHabits();
  }

  @override
  Widget build(BuildContext context) {
    String todayStr = df.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hábitos', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final ctrl = TextEditingController();
              showDialog(context: context, builder: (ctx) => AlertDialog(
                title: const Text('Novo Hábito'),
                content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Ler 10 páginas')),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                  ElevatedButton(onPressed: () {
                    if (ctrl.text.isNotEmpty) {
                      habits.add(Habit(id: DateTime.now().toString(), name: ctrl.text));
                      _saveHabits();
                      setState(() {});
                    }
                    Navigator.pop(ctx);
                  }, child: const Text('Salvar'))
                ],
              ));
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: habits.length,
        itemBuilder: (ctx, i) {
          final h = habits[i];
          bool completedToday = h.activeDates.contains(todayStr);

          // streak calculation
          int streak = 0;
          DateTime checkDate = DateTime.now();
          while (h.activeDates.contains(df.format(checkDate))) {
            streak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
          }
          if (streak == 0 && h.activeDates.contains(df.format(DateTime.now().subtract(const Duration(days: 1))))) {
             // fallback check for yesterday
            checkDate = DateTime.now().subtract(const Duration(days: 1));
            while (h.activeDates.contains(df.format(checkDate))) {
              streak++;
              checkDate = checkDate.subtract(const Duration(days: 1));
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('🔥 $streak dias seguidos', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleHabit(h, todayStr),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completedToday ? Colors.green : const Color(0xFFF3F4F6),
                    ),
                    child: completedToday 
                      ? const Icon(Icons.check, color: Colors.white, size: 28)
                      : null,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
