import 'package:flutter/material.dart';
import 'package:appbiofitexercise/database_helper.dart';
import 'package:appbiofitexercise/teen/analytics_data_model.dart';

class AnalyticsPage extends StatelessWidget {
  // Future function to fetch the analytics data from the database
  Future<List<AnalyticsData>> _fetchAnalyticsData() async {
    final analyticsData = await DatabaseHelper.instance.getAnalyticsData();
    return analyticsData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'),
      ),
      body: FutureBuilder<List<AnalyticsData>>(
        future: _fetchAnalyticsData(), // Fetch analytics data from the database
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No analytics data available.'));
          }

          final analyticsList = snapshot.data!;

          return ListView.builder(
            itemCount: analyticsList.length,
            itemBuilder: (context, index) {
              final analytics = analyticsList[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text('Analytics #${analytics.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time Spent: ${analytics.timeSpent} minutes'),
                      Text('Calories Burned: ${analytics.caloriesBurned} kcal'),
                      Text('Workout Count: ${analytics.workoutCount}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
