import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:appbiofitexercise/exercise/another_dashboard.dart';

class CardioPage extends StatelessWidget {
  const CardioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Body Weight Exercises"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title of the workout section
            Text(
              'Bodyweight Exercises',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20), // Space after the title

            // Example Cardio Workout Boxes
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PushUpDashboard()),
                );
              },
              child: _buildExerciseBox("Push Up", "30 Minutes", "assets/img/pushy.jpg"),
            ),
            const SizedBox(height: 16), // Space between exercise boxes
            
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SquatDashboard()),
                );
              },
              child: _buildExerciseBox("Squat", "45 Minutes", "assets/img/squat.jpg"),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LungesDashboard()),
                );
              },
              child: _buildExerciseBox("Lunges", "15 Minutes", "assets/img/lunges.jpg"),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build an individual exercise box
  Widget _buildExerciseBox(String title, String duration, String imagePath) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100], // Background color for the exercise box
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
          // Placeholder for the exercise image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16), // Space between image and text
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

// Push Up Dashboard
class PushUpDashboard extends StatelessWidget {
  const PushUpDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Push Up",
      description: "Push-ups are a vital exercise for building upper body strength.",
      videoPath: 'assets/video/crunch.mp4', // Update to correct video path
      steps: [
        Step(
          title: "Step 1: Start Position",
          description: "Lie face down with your hands slightly wider than shoulder-width apart.",
          imagePath: "assets/img/step3.jpg",
        ),
        Step(
          title: "Step 2: Lower Down",
          description: "Lower your body until your chest almost touches the ground.",
          imagePath: "assets/img/step2.jpg",
        ),
        Step(
          title: "Step 3: Push Up",
          description: "Push through your palms to return to the starting position.",
          imagePath: "assets/img/step3.jpg",
        ),
      ],
    );
  }
}

// Squat Dashboard
class SquatDashboard extends StatelessWidget {
  const SquatDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Squat",
      description: "Squats are essential for building leg strength and stability.",
      videoPath: 'assets/video/crunch.mp4', // Update to correct video path
      steps: [
        Step(
          title: "Step 1: Stand Tall",
          description: "Stand with your feet shoulder-width apart.",
          imagePath: "assets/img/standtall.png",
        ),
        Step(
          title: "Step 2: Lower Down",
          description: "Bend your knees and lower your hips down as if sitting back into a chair.",
          imagePath: "assets/img/lowerdown.png",
        ),
        Step(
          title: "Step 3: Return to Start",
          description: "Straighten your legs and return to the starting position.",
          imagePath: "assets/img/standtall.png",
        ),
      ],
    );
  }
}

// Lunges Dashboard
class LungesDashboard extends StatelessWidget {
  const LungesDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Lunges",
      description: "Lunges are great for improving balance and leg strength.",
      videoPath: 'assets/video/crunch.mp4', // Update to correct video path
      steps: [
        Step(
          title: "Step 1: Start Position",
          description: "Stand upright with your feet together.",
          imagePath: "assets/img/startposition.jpg",
        ),
        Step(
          title: "Step 2: Step Forward",
          description: "Step forward with one leg, lowering your hips until both knees are bent at about a 90-degree angle.",
          imagePath: "assets/img/stepforward.jpg",
        ),
        Step(
          title: "Step 3: Return",
          description: "Push back to the starting position and repeat with the other leg.",
          imagePath: "assets/img/return.webp",
        ),
      ],
    );
  }
}

// Common ExerciseDashboard class to display each exercise's video
class ExerciseDashboard extends StatefulWidget {
  final String title;
  final String description;
  final String videoPath;
  final List<Step> steps;

  const ExerciseDashboard({Key? key, required this.title, required this.description, required this.videoPath, required this.steps}) : super(key: key);

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

// Step Class
class Step {
  final String title;
  final String description;
  final String imagePath;

  Step({required this.title, required this.description, required this.imagePath});
}