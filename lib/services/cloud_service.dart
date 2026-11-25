
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_session.dart';

class CloudService {
  static const String baseUrl = 'https://fittrackcloud.duckdns.org';
  static const String _tokenKey = 'fittrack_access_token';

  String? _token;

  bool get isLoggedIn => _token != null;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>> _authRequest(
    String endpoint,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['detail'] ?? data['error'] ?? 'Authentication failed');
    }

    final token = data['access_token'] as String?;
    if (token == null) {
      throw Exception('The server did not return an access token.');
    }

    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    return data;
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) {
    return _authRequest('register', email, password);
  }

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) {
    return _authRequest('login', email, password);
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Map<String, String> get _headers {
    if (_token == null) {
      throw Exception('Please log in first.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  Future<void> uploadWorkout(WorkoutSession workout) async {
    final response = await http.post(
      Uri.parse('$baseUrl/workouts'),
      headers: _headers,
      body: jsonEncode(workout.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Workout upload failed: ${response.body}');
    }
  }

  Future<List<WorkoutSession>> fetchWorkouts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/workouts'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Could not load cloud history: ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    final List<dynamic> items =
        decoded is List ? decoded : decoded['workouts'] as List<dynamic>;

    return items.map((item) {
      final workoutJson = Map<String, dynamic>.from(item);

      // The API may include database metadata; the model ignores extra fields.
      return WorkoutSession.fromJson(workoutJson);
    }).toList();
  }
}
