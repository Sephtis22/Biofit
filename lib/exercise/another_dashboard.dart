import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import '/database_helper.dart';
import 'package:appbiofitexercise/teen/analytics_data_model.dart';

class AnotherDashboard extends StatefulWidget {
  final int userId;

  const AnotherDashboard({Key? key, required this.userId}) : super(key: key);

  @override
  _AnotherDashboardState createState() => _AnotherDashboardState();
}

class _AnotherDashboardState extends State<AnotherDashboard> with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _isRunning = false;
  int _caloriesBurned = 0;
  int _workoutCount = 0;
  int _start = 0;

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _start++;
        _caloriesBurned = (_start * 0.2).toInt();
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _workoutCount++;
    });

    _timer?.cancel();
    _saveAnalyticsData();
    Navigator.pop(context);
  }

  Future<void> _saveAnalyticsData() async {
    final analyticsData = AnalyticsData(
      timeSpent: _start,
      caloriesBurned: _caloriesBurned,
      workoutCount: _workoutCount,
    );

    await DatabaseHelper.instance.insertOrUpdateAnalytics(analyticsData);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track your exercise and stay healthy 💪',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 90,
                backgroundColor: Colors.deepPurple[50],
                child: Lottie.asset(
                  'assets/lottie/exercise.json',
                  height: 160,
                  width: 160,
                  repeat: _isRunning,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Time: $_start sec",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                "Calories Burned: $_caloriesBurned kcal",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isRunning ? _stopTimer : _startTimer,
                icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(_isRunning ? 'Finish Workout' : 'Start Workout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.redAccent : Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
