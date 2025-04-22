import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'another_dashboard.dart'; 


class YogaPage extends StatelessWidget {
  const YogaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Core and Abs Exercise"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exercises',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 8, 8, 8)),
              ),
              const SizedBox(height: 20),
              _buildExerciseBox(context, "Crunches", "Hold for 30 seconds", "assets/img/cran.jpg", const CrunchesDashboard()),
              const SizedBox(height: 16),
              _buildExerciseBox(context, "Russian Twists", "Hold for 30 seconds", "assets/img/russiantwist.webp", const RussianTwistsDashboard()),
              const SizedBox(height: 16),
              _buildExerciseBox(context, "Leg Raises", "Hold for 30 seconds", "assets/img/legraises.jpg", const LegRaisesDashboard()),
              const SizedBox(height: 16),
              _buildExerciseBox(context, "Flutter Kicks", "Hold for 30 seconds", "assets/img/flutter kick.png", const FlutterKicksDashboard()),
              const SizedBox(height: 16),
              _buildExerciseBox(context, "Bicycle Crunches", "Hold for 30 seconds", "assets/img/bycicle.webp", const BicycleCrunchesDashboard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseBox(BuildContext context, String title, String duration, String imagePath, Widget dashboard) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => dashboard),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.deepPurple[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: const Offset(0, 2),
              blurRadius: 8.0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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

// Step Class
class Step {
  final String title;
  final String description;
  final String imagePath;

  Step({required this.title, required this.description, required this.imagePath});
}

// Specific exercise dashboards:
class CrunchesDashboard extends StatelessWidget {
  const CrunchesDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Crunches",
      description: "Crunches are a core exercise that focuses on strengthening the abdominal muscles.",
      videoPath: 'assets/video/crunch.mp4',
      steps: [
        Step(
          title: "Step 1: Lie Down",
          description: "Lie on your back with your knees bent and feet flat on the floor.",
          imagePath: "assets/img/lie.jpg",
        ),
        Step(
          title: "Step 2: Position Your Hands",
          description: "Place your hands behind your head or crossed over your chest.",
          imagePath: "assets/img/likod.jpg",
        ),
        Step(
          title: "Step 3: Crunch Up",
          description: "Engage your core and lift your shoulders off the floor.",
          imagePath: "assets/img/crunchup.jpg",
        ),
      ],
    );
  }
}

class RussianTwistsDashboard extends StatelessWidget {
  const RussianTwistsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Russian Twists",
      description: "Russian Twists target the obliques and improve rotational strength.",
      videoPath: 'assets/video/Russian Twist.mp4',
      steps: [
        Step(
          title: "Step 1: Sit on the Floor",
          description: "Sit with your knees bent and feet flat.",
          imagePath: "assets/img/setonthefloor.jpg",
        ),
        Step(
          title: "Step 2: Lean Back Slightly",
          description: "Lean back slightly and lift your feet off the floor.",
          imagePath: "assets/img/lean.webp",
        ),
        Step(
          title: "Step 3: Rotate Your Torso",
          description: "Rotate your torso to one side, then the other to complete one rep.",
          imagePath: "assets/img/rotate.jpg",
        ),
      ],
    );
  }
}

class LegRaisesDashboard extends StatelessWidget {
  const LegRaisesDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Leg Raises",
      description: "Leg Raises are great for building lower abdominal strength.",
      videoPath: 'assets/video/crunch.mp4',
      steps: [
        Step(
          title: "Step 1: Lie Flat",
          description: "Lie flat on your back with your legs straight.",
          imagePath: "assets/img/lie flat.webp",
        ),
        Step(
          title: "Step 2: Lift Legs",
          description: "Lift your legs off the ground, keeping them straight.",
          imagePath: "assets/img/stet ang tiil.webp",
        ),
        Step(
          title: "Step 3: Lower Legs",
          description: "Slowly lower your legs back down without touching the ground.",
          imagePath: "assets/img/nohikap.jpg",
        ),
      ],
    );
  }
}

class FlutterKicksDashboard extends StatelessWidget {
  const FlutterKicksDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Flutter Kicks",
      description: "Flutter Kicks are a dynamic exercise for your lower abs.",
      videoPath:'assets/video/crunch.mp4',
      steps: [
        Step(
          title: "Step 1: Start Position",
          description: "Lie flat on your back with your legs straight.",
          imagePath: "assets/img/lie flat.webp",
        ),
        Step(
          title: "Step 2: Lift Legs",
          description: "Lift your legs a few inches off the ground.",
          imagePath: "assets/img/lift legs.webp",
        ),
        Step(
          title: "Step 3: Flutter Kick",
          description: "Alternate kicking your legs up and down in a flutter motion.",
          imagePath: "assets/img/flutter kick.png",
        ),
      ],
    );
  }
}

class BicycleCrunchesDashboard extends StatelessWidget {
  const BicycleCrunchesDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExerciseDashboard(
      title: "Bicycle Crunches",
      description: "Bicycle Crunches engage both the upper and lower abs.",
      videoPath: 'assets/video/crunch.mp4',
      steps: [
        Step(
          title: "Step 1: Lie Down",
          description: "Lie on your back with your knees bent.",
          imagePath: "assets/img/lie.jpg",
        ),
        Step(
          title: "Step 2: Position Your Hands",
          description: "Place your hands behind your head.",
          imagePath: "assets/img/headhands.webp",
        ),
        Step(
          title: "Step 3: Perform Crunch",
          description: "Pedal your legs in the air while lifting your shoulders off of the ground.",
          imagePath: "assets/img/crunches.jpg",
        ),
      ],
    );
  }
}

