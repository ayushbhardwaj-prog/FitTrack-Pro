
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_session.dart';

class StorageService {
  String _accountScope = 'default';

  void setAccount(String account) {
    _accountScope = account.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '_',
    );
  }

  String get historyKey =>
      _accountScope == 'default'
          ? 'workout_history'
          : 'workout_history_$_accountScope';

  Future<void> saveHistory(List<WorkoutSession> history) async {
    final prefs = await SharedPreferences.getInstance();

    final workoutList = history
        .map((workout) => jsonEncode(workout.toJson()))
        .toList();

    await prefs.setStringList(historyKey, workoutList);
  }

  Future<List<WorkoutSession>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutList = prefs.getStringList(historyKey);

    if (workoutList == null) return [];

    return workoutList.map((item) {
      return WorkoutSession.fromJson(
        jsonDecode(item) as Map<String, dynamic>,
      );
    }).toList();
  }
}
