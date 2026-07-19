import 'dart:async';

import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../services/storage_service.dart';

class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider() {
    loadHistory();
  }

  final StorageService storage = StorageService();

  WorkoutSession? currentWorkout;

  final List<WorkoutSession> history = [];

  Timer? _timer;

  int elapsedSeconds = 0;

  int caloriesBurned = 0;

  int calorieGoal = 500;

  int caloriesPerMinute = 8;

  String workoutIntensity = "Heavy";

  bool get workoutStarted => currentWorkout != null;

  void _startTimer() {
    _timer?.cancel();

    elapsedSeconds = 0;
    caloriesBurned = 0;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        elapsedSeconds++;

        caloriesBurned =
            ((elapsedSeconds / 60) * caloriesPerMinute)
                .round();

        notifyListeners();
      },
    );
  }

  void _stopTimer() {
    _timer?.cancel();
  }
  void setWorkoutIntensity(String intensity) {
    workoutIntensity = intensity;
    
    switch (intensity) {
      case "Light":
        caloriesPerMinute = 4;
        break;

      case "Moderate":
        caloriesPerMinute = 6;
        break;

      default:
        caloriesPerMinute = 8;
    }

    notifyListeners();
  }
  void startWorkout(String day) {
    currentWorkout = WorkoutSession(
      day: day,
      date: DateTime.now(),
      startTime: DateTime.now(),
      exercises: [],
      completed: false,
    );

    _startTimer();

    notifyListeners();
  }

  void addExercise(Exercise exercise) {
    if (currentWorkout == null) return;

    currentWorkout!.exercises.add(exercise);

    notifyListeners();
  }

  void deleteExercise(int index) {
    if (currentWorkout == null) return;

    currentWorkout!.exercises.removeAt(index);

    notifyListeners();
  }
    Future<void> finishWorkout() async {
    if (currentWorkout == null) return;

    _stopTimer();

    currentWorkout!.completed = true;
    currentWorkout!.endTime = DateTime.now();
    currentWorkout!.caloriesBurned = caloriesBurned;

    history.insert(0, currentWorkout!);

    await saveHistory();

    currentWorkout = null;

    elapsedSeconds = 0;
    caloriesBurned = 0;

    notifyListeners();
  }

  Future<void> loadHistory() async {
    history.clear();
    history.addAll(await storage.loadHistory());
    notifyListeners();
  }

  Future<void> saveHistory() async {
    await storage.saveHistory(history);
  }

  Future<void> deleteWorkout(int index) async {
    history.removeAt(index);

    await saveHistory();

    notifyListeners();
  }

  Future<void> clearHistory() async {
    history.clear();

    await saveHistory();

    notifyListeners();
  }

  int get totalExercises =>
      currentWorkout?.exercises.length ?? 0;

  List<WorkoutSession> get workoutHistory => history;

  int get totalWorkouts => history.length;

  double get totalVolume {
    double volume = 0;

    for (final workout in history) {
      volume += workout.totalVolume;
    }

    return volume;
  }

  int get totalSets {
    return history.fold(
      0,
      (sum, workout) => sum + workout.totalSets,
    );
  }

  String get formattedTime {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  int get remainingCalories {
    return (calorieGoal - caloriesBurned).clamp(
      0,
      calorieGoal,
    );
  }

  double get calorieProgress {
    if (calorieGoal == 0) return 0;

    return (caloriesBurned / calorieGoal).clamp(
      0.0,
      1.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}