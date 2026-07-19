class Exercise {
  final String workoutDay;
  final String name;
  final double weight;
  final int sets;
  final int reps;

  Exercise({
    required this.workoutDay,
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
  });

  Map<String, dynamic> toJson() {
    return {
      "workoutDay": workoutDay,
      "name": name,
      "weight": weight,
      "sets": sets,
      "reps": reps,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      workoutDay: json["workoutDay"],
      name: json["name"],
      weight: (json["weight"] as num).toDouble(),
      sets: json["sets"],
      reps: json["reps"],
    );
  }
}