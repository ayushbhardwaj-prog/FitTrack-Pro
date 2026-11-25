import 'exercise_set.dart';

class Exercise {
  final String workoutDay;
  final String name;
  final List<ExerciseSet> sets;

  Exercise({
    required this.workoutDay,
    required this.name,
    required this.sets,
  });

  //--------------------------------------------------
  // Total Volume
  //--------------------------------------------------

  double get totalVolume {
    return sets.fold(
      0,
      (sum, set) => sum + set.volume,
    );
  }

  //--------------------------------------------------
  // Total Reps
  //--------------------------------------------------

  int get totalReps {
    return sets.fold(
      0,
      (sum, set) => sum + set.reps,
    );
  }

  //--------------------------------------------------
  // Number of Sets
  //--------------------------------------------------

  int get totalSets {
    return sets.length;
  }

  //--------------------------------------------------
  // Estimated Calories
  //--------------------------------------------------

  double get estimatedCalories {
    return totalVolume / 75;
  }

  //--------------------------------------------------
  // JSON
  //--------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      "workoutDay": workoutDay,
      "name": name,
      "sets": sets
          .map((set) => set.toJson())
          .toList(),
    };
  }

  factory Exercise.fromJson(
      Map<String, dynamic> json) {
    return Exercise(
      workoutDay: json["workoutDay"],
      name: json["name"],
      sets: (json["sets"] as List)
          .map(
            (e) => ExerciseSet.fromJson(e),
          )
          .toList(),
    );
  }
}