
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/exercise_set.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../services/storage_service.dart';
import '../services/cloud_service.dart';

class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider() {
    loadHistory();
  }

  final StorageService storage = StorageService();
  final CloudService cloud = CloudService();

  WorkoutSession? currentWorkout;
  final List<WorkoutSession> history = [];

  Timer? _timer;

  int elapsedSeconds = 0;
  int caloriesBurned = 0;
  int calorieGoal = 500;
  int caloriesPerMinute = 8;

  String workoutIntensity = 'Heavy';
  String? accountEmail;

  bool cloudSyncing = false;
  String? cloudError;

  bool get workoutStarted => currentWorkout != null;
  bool get isLoggedIn => cloud.isLoggedIn;
  bool isInitializing = true;

  Future<void> loadHistory() async {
    try {
      await cloud.loadToken();

      history.clear();
      history.addAll(await storage.loadHistory());

      if (cloud.isLoggedIn) {
        await syncCloudHistory();
      }
    } catch (e) {
      cloudError = e.toString();
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    await cloud.register(email, password);
    await _activateAccount(email);
  }

  Future<void> login(String email, String password) async {
    await cloud.login(email, password);
    await _activateAccount(email);
  }

  Future<void> _activateAccount(String email) async {
    accountEmail = email.trim().toLowerCase();
    storage.setAccount(accountEmail!);

    history.clear();
    history.addAll(await storage.loadHistory());
    notifyListeners();

    await syncCloudHistory();
  }

  Future<void> logout() async {
    await cloud.logout();
    accountEmail = null;

    history.clear();
    storage.setAccount('default');
    history.addAll(await storage.loadHistory());

    notifyListeners();
  }

  Future<void> syncCloudHistory() async {
    if (!cloud.isLoggedIn) return;

    cloudSyncing = true;
    cloudError = null;
    notifyListeners();

    try {
      final cloudHistory = await cloud.fetchWorkouts();

      // Keep local workouts that are not yet present in the cloud.
      final cloudKeys = cloudHistory.map(_workoutKey).toSet();

      final localOnly = history.where(
        (workout) => !cloudKeys.contains(_workoutKey(workout)),
      ).toList();

      // Upload local-only workouts.
      for (final workout in localOnly) {
        await cloud.uploadWorkout(workout);
      }

      // Refresh after uploading so the cloud is the source of truth.
      final refreshed = await cloud.fetchWorkouts();

      history
        ..clear()
        ..addAll(refreshed);

      await storage.saveHistory(history);
    } catch (e) {
      cloudError = e.toString();
      await storage.saveHistory(history);
    } finally {
      cloudSyncing = false;
      notifyListeners();
    }
  }

  String _workoutKey(WorkoutSession workout) {
    return '${workout.day}_${workout.date.toIso8601String()}';
  }

  void _startTimer() {
    _timer?.cancel();
    elapsedSeconds = 0;
    caloriesBurned = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds++;
      caloriesBurned =
          ((elapsedSeconds / 60) * caloriesPerMinute).round();
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void setWorkoutIntensity(String intensity) {
    workoutIntensity = intensity;

    switch (intensity) {
      case 'Light':
        caloriesPerMinute = 4;
        break;
      case 'Moderate':
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

  void addSetToExercise(int exerciseIndex, ExerciseSet set) {
    if (currentWorkout == null) return;

    currentWorkout!.exercises[exerciseIndex].sets.add(set);
    notifyListeners();
  }

  void updateSet(
    int exerciseIndex,
    int setIndex,
    ExerciseSet newSet,
  ) {
    if (currentWorkout == null) return;

    currentWorkout!.exercises[exerciseIndex].sets[setIndex] = newSet;
    notifyListeners();
  }

  void deleteSet(int exerciseIndex, int setIndex) {
    if (currentWorkout == null) return;

    currentWorkout!.exercises[exerciseIndex].sets.removeAt(setIndex);
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

    final finishedWorkout = currentWorkout!;
    history.insert(0, finishedWorkout);

    // Always save locally first.
    await saveHistory();

    currentWorkout = null;
    elapsedSeconds = 0;
    caloriesBurned = 0;

    notifyListeners();

    // Upload in the background if signed in.
    if (cloud.isLoggedIn) {
      try {
        await cloud.uploadWorkout(finishedWorkout);
        cloudError = null;
      } catch (e) {
        cloudError = 'Saved locally; cloud upload failed: $e';
      }
      notifyListeners();
    }
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

  int get totalExercises => currentWorkout?.exercises.length ?? 0;

  List<WorkoutSession> get workoutHistory => history;

  int get totalWorkouts => history.length;

  double get totalVolume {
    return history.fold(0, (sum, workout) => sum + workout.totalVolume);
  }

  int get totalSets {
    return history.fold(0, (sum, workout) => sum + workout.totalSets);
  }

  String get formattedTime {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  int get remainingCalories =>
      (calorieGoal - caloriesBurned).clamp(0, calorieGoal);

  double get calorieProgress {
    if (calorieGoal == 0) return 0;
    return (caloriesBurned / calorieGoal).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
