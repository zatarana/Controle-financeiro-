import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroTimerTab extends StatefulWidget {
  const PomodoroTimerTab({Key? key}) : super(key: key);

  @override
  State<PomodoroTimerTab> createState() => _PomodoroTimerTabState();
}

class _PomodoroTimerTabState extends State<PomodoroTimerTab> {
  int _focusMinutes = 25;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _focusMinutes * 60;
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          timer.cancel();
          _isRunning = false;
          // Play sound or notification here
        }
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _focusMinutes * 60;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    String minStr = minutes.toString().padLeft(2, '0');
    String secStr = seconds.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text('Foco (Pomodoro)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _isRunning ? Colors.red : Colors.grey, width: 4),
              ),
              child: Text(
                '$minStr:$secStr',
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  heroTag: 'pomodoro_play',
                  onPressed: _toggleTimer,
                  backgroundColor: _isRunning ? Colors.red.shade100 : Colors.black,
                  foregroundColor: _isRunning ? Colors.red : Colors.white,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 24),
                FloatingActionButton(
                  heroTag: 'pomodoro_stop',
                  onPressed: _resetTimer,
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  child: const Icon(Icons.stop),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
