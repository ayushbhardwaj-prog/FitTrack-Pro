import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_session.dart';

class StorageService {
  static const String historyKey = "workout_history";

  Future<void> saveHistory(List<WorkoutSession> history) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> workoutList =
        history.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList(historyKey, workoutList);
  }

  Future<List<WorkoutSession>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final workoutList = prefs.getStringList(historyKey);

    if (workoutList == null) {
      return [];
    }

    return workoutList
        .map(
          (e) => WorkoutSession.fromJson(
            jsonDecode(e),
          ),
        )
        .toList();
  }
}