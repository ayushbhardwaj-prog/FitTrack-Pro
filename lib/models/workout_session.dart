import 'exercise.dart';

class WorkoutSession {
  final String day;
  final DateTime date;
  final DateTime startTime;
  DateTime? endTime;
  final List<Exercise> exercises;
  bool completed;
  int caloriesBurned;

WorkoutSession({
  required this.day,
  required this.date,
  required this.exercises,
  required this.startTime,
  this.endTime,
  this.completed = false,
  this.caloriesBurned = 0,
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
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
    day: json["day"],
    date: DateTime.parse(json["date"]),

    startTime: json["startTime"] != null
        ? DateTime.parse(json["startTime"])
        : DateTime.parse(json["date"]),

    endTime: json["endTime"] != null
        ? DateTime.parse(json["endTime"])
        : null,

    completed: json["completed"] ?? false,
    caloriesBurned: json["caloriesBurned"] ?? 0,

    exercises: (json["exercises"] as List)
        .map((e) => Exercise.fromJson(e))
        .toList(),
  );
  }

  int get totalExercises => exercises.length;

  double get totalVolume {
    double volume = 0;

    for (final exercise in exercises) {
      volume += exercise.weight * exercise.sets * exercise.reps;
    }

    return volume;
  }
  int get totalSets {
  int sets = 0;

  for (final exercise in exercises) {
    sets += exercise.sets;
  }

  return sets;
}
int get durationMinutes {
  if (endTime == null) return 0;

  return endTime!
      .difference(startTime)
      .inMinutes;
}
}