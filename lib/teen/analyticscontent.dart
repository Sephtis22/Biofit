import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:appbiofitexercise/database_helper.dart';
import 'analytics_data_model.dart';

class AnalyticsContent extends StatefulWidget {
  const AnalyticsContent({Key? key}) : super(key: key);

  @override
  _AnalyticsContentState createState() => _AnalyticsContentState();
}

class _AnalyticsContentState extends State<AnalyticsContent> {
  int totalSteps = 0; // Variable to hold total steps
  int currentSteps = 0; // Variable to simulate steps taken in the session
  bool isWalking = false; // Indicates if the user is currently walking
  Timer? timer; // Timer to track walking time
  Duration duration = Duration(); // Duration of the walking session

  // This will hold the latest analytics data fetched from the database
  AnalyticsData? latestAnalytics;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData(); // Load analytics data when the widget is initialized
  }

  void _loadAnalyticsData() async {
    final data = await DatabaseHelper.instance.getAnalyticsData();
    if (data.isNotEmpty) {
      setState(() {
        latestAnalytics = data.last; // Assuming you want the most recent analytics record
      });
    }
  }

  void startWalking() {
    setState(() {
      isWalking = true;
      currentSteps = 0; // Reset current steps for the new session
      duration = Duration(); // Reset duration
    });

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        duration += Duration(seconds: 1);
        currentSteps += 100; // Simulate step count increment, can be adjusted
      });
    });
  }

  void finishWalking() async {
  if (timer != null) {
    timer!.cancel(); // Cancel the timer if it's running
  }

  // Compute the calories burned and time spent
  int caloriesBurned = currentSteps * 0.04.toInt();
  int timeSpent = duration.inMinutes;

  // First, fetch the most recent analytics data from the database
  final data = await DatabaseHelper.instance.getAnalyticsData();

  if (data.isNotEmpty) {
    // Fetch the last (most recent) analytics record
    final lastAnalytics = data.last;

    print("Last workout count before increment: ${lastAnalytics.workoutCount}");

    // Increment the workout count by 1
    final updatedAnalytics = AnalyticsData(
      timeSpent: timeSpent,
      caloriesBurned: caloriesBurned,
      workoutCount: lastAnalytics.workoutCount + 1, // Increment workout count by 1
    );

    // Update the existing analytics record with the new workout count
    await DatabaseHelper.instance.insertOrUpdateAnalytics(updatedAnalytics);

    setState(() {
      totalSteps += currentSteps; // Add current steps to total steps
      isWalking = false; // Stop walking
    });
  } else {
    // If no previous analytics data exists, treat this as the first workout
    final initialAnalytics = AnalyticsData(
      timeSpent: timeSpent,
      caloriesBurned: caloriesBurned,
      workoutCount: 1, // Set workout count to 1 for the first workout
    );

    // Insert the first workout data
    await DatabaseHelper.instance.insertOrUpdateAnalytics(initialAnalytics);

    setState(() {
      totalSteps += currentSteps;
      isWalking = false;
    });
  }

  // Reload the latest analytics data from the database
  _loadAnalyticsData();
}



  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel(); // Cancel the timer when widget is disposed
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Walking Animation and Control Buttons
          Column(
            children: [
              Lottie.asset(
                'assets/lottie/walking.json', // Path to your Lottie animation
                width: 200,
                height: 200,
                fit: BoxFit.fill,
                repeat: isWalking,
              ),
              SizedBox(height: 20),
              if (!isWalking)
                ElevatedButton(
                  onPressed: startWalking,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                  ),
                  child: Text('Start Walking', style: TextStyle(fontSize: 18)),
                )
              else
                Column(
                  children: [
                    Text(
                      'Walking for: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: finishWalking,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Rounded corners
                        ),
                      ),
                      child: Text('Finish', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 20),
          // Analytics Summary Header
          Text(
            "Fitness Analytics",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Responsive GridView for analytics cards
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (MediaQuery.of(context).size.width / 140).floor(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildAnalyticsCard(
                context,
                index == 0 ? "Calories Burned" : index == 1 ? "Time Spent" : index == 2 ? "Finished Workouts" : "Total Steps",
                index == 0
                    ? "${latestAnalytics?.caloriesBurned ?? 0} kcal"
                    : index == 1
                        ? "${latestAnalytics?.timeSpent ?? 0} Sec"
                        : index == 2
                            ? "${latestAnalytics?.workoutCount ?? 0}"
                            : "$totalSteps steps",
                index == 0
                    ? Icons.local_fire_department
                    : index == 1
                        ? Icons.access_time
                        : index == 2
                            ? Icons.check_circle
                            : Icons.directions_walk,
              );
            },
          ),
          SizedBox(height: 20), // Space before footer
          // Footer
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Keep the progress!",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text("You are more successful\nthan 88% of users."),
                  ],
                ),
                Icon(Icons.trending_up, size: 40, color: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      height: 100,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
