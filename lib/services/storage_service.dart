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

  String get historyKey => _accountScope == 'default'
      ? 'workout_history'
      : 'workout_history_$_accountScope';

  String get pendingDeletesKey => 'pending_workout_deletes_$_accountScope';

  Future<void> migrateAccount(String fromAccount, String toAccount) async {
    final originalScope = _accountScope;
    try {
      setAccount(fromAccount);
      final fromHistoryKey = historyKey;
      final fromPendingKey = pendingDeletesKey;
      final prefs = await SharedPreferences.getInstance();
      final fromHistory = prefs.getStringList(fromHistoryKey) ?? [];
      final fromPending = prefs.getStringList(fromPendingKey) ?? [];

      setAccount(toAccount);
      final toHistoryKey = historyKey;
      final toPendingKey = pendingDeletesKey;
      if (fromHistoryKey != toHistoryKey && fromHistory.isNotEmpty) {
        final merged = <String, String>{};
        for (final item in prefs.getStringList(toHistoryKey) ?? []) {
          merged[_historyIdentity(item)] = item;
        }
        for (final item in fromHistory) {
          merged.putIfAbsent(_historyIdentity(item), () => item);
        }
        await prefs.setStringList(toHistoryKey, merged.values.toList());
      }
      if (fromPendingKey != toPendingKey && fromPending.isNotEmpty) {
        final merged = {...?prefs.getStringList(toPendingKey), ...fromPending};
        await prefs.setStringList(toPendingKey, merged.toList());
      }
    } finally {
      _accountScope = originalScope;
    }
  }

  String _historyIdentity(String workoutJson) {
    try {
      final workout = Map<String, dynamic>.from(
        jsonDecode(workoutJson) as Map<String, dynamic>,
      )..removeWhere((key, _) => {'cloudId', 'id', 'createdAt'}.contains(key));
      for (final key in ['date', 'startTime', 'endTime']) {
        final value = workout[key];
        if (value is String) {
          workout[key] =
              DateTime.tryParse(value)?.toUtc().toIso8601String() ?? value;
        }
      }
      return jsonEncode(workout);
    } on Object {
      return workoutJson;
    }
  }

  Future<Set<int>> loadPendingDeletes() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(pendingDeletesKey) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  Future<void> savePendingDeletes(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      pendingDeletesKey,
      ids.map((id) => id.toString()).toList(),
    );
  }

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
      return WorkoutSession.fromJson(jsonDecode(item) as Map<String, dynamic>);
    }).toList();
  }
}
