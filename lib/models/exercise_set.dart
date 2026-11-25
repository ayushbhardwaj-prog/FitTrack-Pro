class ExerciseSet {
  final double weight;
  final int reps;

  ExerciseSet({
    required this.weight,
    required this.reps,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'reps': reps,
    };
  }

  factory ExerciseSet.fromJson(
      Map<String, dynamic> json) {
    return ExerciseSet(
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'],
    );
  }

  double get volume => weight * reps;
}