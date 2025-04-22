import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:appbiofitexercise/exercise/another_dashboard.dart';
// Main Arms Page displaying exercises
class ArmsPage extends StatelessWidget {
  const ArmsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cardio Exercise"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RunningDashboard()),
                );
              },
              child: _buildExerciseBox("Running", "3 Sets of 12 Reps", "assets/img/running.jpg"),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CyclingDashboard()),
                );
              },
              child: _buildExerciseBox("Cycling", "3 Sets of 15 Reps", "assets/img/cycling.png"),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JumpingJackDashboard()),
                );
              },
              child: _buildExerciseBox("Brisk Walking", "3 Sets of 10 Reps", "assets/img/briskwalking.jpg"),
            ),

            const Spacer(), // This will push the Next button to the bottom

          ],
        ),
      ),
    );
  }

  Widget _buildExerciseBox(String title, String duration, String imagePath) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                duration,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Placeholder classes for the exercise dashboards
class RunningDashboard extends StatelessWidget {
  const RunningDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Running",
      description: "Running is a great way to build endurance and strengthen your arms.",
      videoPath: 'assets/video/crunch.mp4',
      steps: [
        Step(title: "Step 1", description: "Stand straight with your feet hip-width apart.", imagePath: "assets/img/run1.jpg"),
        Step(title: "Step 2", description: "Begin running by lifting your knees and pumping your arms.", imagePath: "assets/img/runstep2.jpg"),
        Step(title: "Step 3", description: "Maintain a steady pace and focus on your breath.", imagePath: "assets/img/runstep3.jpeg"),
      ],
    );
  }
}

class CyclingDashboard extends StatelessWidget {
  const CyclingDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Cycling",
      description: "Cycling helps tone your arms while improving cardiovascular fitness.",
      videoPath: 'assets/video/crunch.mp4',
      steps: [
        Step(title: "Step 1", description: "Sit on the bike with your feet on the pedals.", imagePath: "assets/img/bike1.jpg"),
        Step(title: "Step 2", description: "Start pedaling at a moderate pace.", imagePath: "assets/img/bike2.jpeg"),
        Step(title: "Step 3", description: "Engage your core and keep your arms steady on the handlebars.", imagePath: "assets/img/bike3.jpg"),
      ],
    );
  }
}

class JumpingJackDashboard extends StatelessWidget {
  const JumpingJackDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Brisk walking",
      description: " is a moderate-intensity aerobic exercise that involves walking at a faster pace than a casual stroll.",
      videoPath: 'assets/video/crunch.mp4',
      steps: [
        Step(title: "Step 1", description: "Stand upright with your arms at your sides.", imagePath: "assets/img/jump1.jpg"),
        Step(title: "Step 2", description: "Jump up and spread your legs while raising your arms above your head.", imagePath: "assets/img/jump2.jpg"),
        Step(title: "Step 3", description: "Jump back to the starting position and repeat.", imagePath: "assets/img/jump3.jpg"),
      ],
    );
  }
}

// Common ExerciseDashboard class to display each exercise's video and steps
class ExerciseDashboard extends StatefulWidget {
  final String title;
  final String description;
  final String videoPath;
  final List<Step> steps;

  const ExerciseDashboard({
    Key? key,
    required this.title,
    required this.description,
    required this.videoPath,
    required this.steps,
  }) : super(key: key);

  @override
  _ExerciseDashboardState createState() => _ExerciseDashboardState();
}

class _ExerciseDashboardState extends State<ExerciseDashboard> {
  late VideoPlayerController _controller;
  bool _isExerciseStarted = false;
  String _buttonText = "Watch Exercise";

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..setVolume(0)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Exercise Complete", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          content: Text("You have completed the ${widget.title} exercise!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.push(
                  context,
                MaterialPageRoute(builder: (context) => AnotherDashboard(userId: 1),), // Replace 1 with the actual integer userId
                );
              },
              child: const Text("Next", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            ),
          ],
        );
      },
    );
  }

  void _startExercise() {
    if (!_isExerciseStarted) {
      setState(() {
        _isExerciseStarted = true;
        _buttonText = "Exercise Playing";
      });
      _controller.play();
      const durationLimit = Duration(seconds: 3);
      Future.delayed(durationLimit, () {
        _controller.pause();
        _showCompletionDialog();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.title} Exercise",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 7, 7, 7)),
            ),
            const SizedBox(height: 20),
            Text(
              "Description: ${widget.description}",
              style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 142, 140, 140)),
            ),
            const SizedBox(height: 20),
            const Text("Steps to perform:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 1, 1, 1))),
            const SizedBox(height: 10),
            ...widget.steps.map((step) => _buildStepCard(step)).toList(), 
            const SizedBox(height: 20),
            Center(
              child: _controller.value.isInitialized
                  ? Container(
                      height: MediaQuery.of(context).size.width * 0.75,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoPlayer(_controller),
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.width * 0.75,
                      color: Colors.black,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 6, 6, 6),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isExerciseStarted ? null : _startExercise,
                child: Text(_buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(Step step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                step.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    step.description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Step Class for exercise steps
class Step {
  final String title;
  final String description;
  final String imagePath;

  Step({required this.title, required this.description, required this.imagePath});
}