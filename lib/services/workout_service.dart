import '../models/exercise.dart';

class WorkoutService {
  final List<Exercise> _exercises = [];

  List<Exercise> get exercises => _exercises;

  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
  }

  void deleteExercise(int index) {
    _exercises.removeAt(index);
  }

  int get totalExercises => _exercises.length;

  List<Exercise> exercisesForDay(String day) {
    return _exercises.where((e) => e.workoutDay == day).toList();
  }

  void clearWorkout() {
    _exercises.clear();
  }
}