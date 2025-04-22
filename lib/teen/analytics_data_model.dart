class AnalyticsData {
  final int? id; // Nullable id for auto increment
  final int timeSpent; // Time spent in seconds
  final int caloriesBurned; // Calories burned during the workout
  final int workoutCount; // Count of workouts

  // Named constructors for the keys
  static const String _idKey = 'id';
  static const String _timeSpentKey = 'timeSpent';
  static const String _caloriesBurnedKey = 'caloriesBurned';
  static const String _workoutCountKey = 'workoutCount';

  AnalyticsData({
    this.id,
    required this.timeSpent,
    required this.caloriesBurned,
    required this.workoutCount,
  });

  // Convert a Map into an AnalyticsData instance
  factory AnalyticsData.fromMap(Map<String, dynamic> map) {
    return AnalyticsData(
      id: map[_idKey], // or map['id'] if you want
      timeSpent: map[_timeSpentKey],
      caloriesBurned: map[_caloriesBurnedKey],
      workoutCount: map[_workoutCountKey],
    );
  }

  // Convert an AnalyticsData instance into a Map
  Map<String, dynamic> toMap() {
    return {
      _idKey: id,
      _timeSpentKey: timeSpent,
      _caloriesBurnedKey: caloriesBurned,
      _workoutCountKey: workoutCount,
    };
  }

  // Update data
  AnalyticsData update({
    int? timeSpent,
    int? caloriesBurned,
    int? workoutCount,
  }) {
    return AnalyticsData(
      id: this.id,
      timeSpent: (timeSpent != null) ? this.timeSpent + timeSpent : this.timeSpent,
      caloriesBurned: (caloriesBurned != null) ? this.caloriesBurned + caloriesBurned : this.caloriesBurned,
      workoutCount: (workoutCount != null) ? this.workoutCount + workoutCount : this.workoutCount,
    );
  }

  @override
  String toString() {
    return 'AnalyticsData{id: $id, timeSpent: $timeSpent, caloriesBurned: $caloriesBurned, workoutCount: $workoutCount}';
  }
}