import 'exercise.dart';

class WorkoutSession {
  final String day;
  final DateTime date;
  final DateTime startTime;
  DateTime? endTime;
  final List<Exercise> exercises;
  bool completed;
  int caloriesBurned;
  int? cloudId;

  WorkoutSession({
    required this.day,
    required this.date,
    required this.exercises,
    required this.startTime,
    this.endTime,
    this.completed = false,
    this.caloriesBurned = 0,
    this.cloudId,
  });

  Map<String, dynamic> toJson() {
    return {
      "day": day,
      "date": date.toIso8601String(),
      "startTime": startTime.toIso8601String(),
      "endTime": endTime?.toIso8601String(),
      "completed": completed,
      "caloriesBurned": caloriesBurned,
      "exercises": exercises.map((e) => e.toJson()).toList(),
      if (cloudId != null) "cloudId": cloudId,
    };
  }

  Map<String, dynamic> toCloudJson() {
    final json = toJson()..remove('cloudId');
    return json;
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      day: json["day"],
      date: DateTime.parse(json["date"]),

      startTime: json["startTime"] != null
          ? DateTime.parse(json["startTime"])
          : DateTime.parse(json["date"]),

      endTime: json["endTime"] != null ? DateTime.parse(json["endTime"]) : null,

      completed: json["completed"] ?? false,
      caloriesBurned: json["caloriesBurned"] ?? 0,
      cloudId: (json["cloudId"] ?? json["id"]) is num
          ? ((json["cloudId"] ?? json["id"]) as num).toInt()
          : null,

      exercises: (json["exercises"] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }

  int get totalExercises => exercises.length;

  double get totalVolume {
    double volume = 0;

    for (final exercise in exercises) {
      volume += exercise.totalVolume;
    }

    return volume;
  }

  int get totalSets {
    int total = 0;

    for (final exercise in exercises) {
      total += exercise.totalSets;
    }

    return total;
  }

  int get durationMinutes {
    if (endTime == null) return 0;

    return endTime!.difference(startTime).inMinutes;
  }
}
