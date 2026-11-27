import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_session.dart';

class CloudService {
  static const String baseUrl = 'https://fittrackcloud.duckdns.org';
  static const String _tokenKey = 'fittrack_access_token';
  static const String _emailKey = 'fittrack_account_email';
  static const Duration _requestTimeout = Duration(seconds: 15);

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _token;
  String? accountEmail;
  bool restoredFromLegacyToken = false;

  bool get isLoggedIn => _token != null;

  String get accountScope {
    if (accountEmail != null && accountEmail!.isNotEmpty) return accountEmail!;
    final token = _token;
    if (token != null) {
      try {
        final payload = token.split('.')[1];
        final decoded =
            jsonDecode(
                  utf8.decode(base64Url.decode(base64Url.normalize(payload))),
                )
                as Map<String, dynamic>;
        final subject = decoded['sub'];
        if (subject is String && subject.isNotEmpty) return 'user_$subject';
      } on Object {
        // A malformed token is rejected by the backend when it is checked.
      }
    }
    return 'default';
  }

  Future<void> loadToken() async {
    restoredFromLegacyToken = false;
    _token = await _secureStorage.read(key: _tokenKey);
    accountEmail = await _secureStorage.read(key: _emailKey);

    // Migrate tokens saved by older versions without ever logging them.
    final prefs = await SharedPreferences.getInstance();
    if (_token == null) {
      final legacyToken = prefs.getString(_tokenKey);
      if (legacyToken != null && legacyToken.isNotEmpty) {
        await _secureStorage.write(key: _tokenKey, value: legacyToken);
        _token = legacyToken;
        restoredFromLegacyToken = true;
      }
    }
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> _authRequest(
    String endpoint,
    String email,
    String password,
  ) async {
    final response = await _send(
      () => http
          .post(
            Uri.parse('$baseUrl/auth/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(_requestTimeout),
    );
    final data = _decodeObject(response);
    _checkResponse(response, data);

    final token = data['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw const CloudException('The server did not return an access token.');
    }

    _token = token;
    accountEmail =
        (data['user'] as Map<String, dynamic>?)?['email'] as String? ??
        email.trim().toLowerCase();
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _emailKey, value: accountEmail);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    return data;
  }

  Future<Map<String, dynamic>> register(String email, String password) =>
      _authRequest('register', email, password);

  Future<Map<String, dynamic>> login(String email, String password) =>
      _authRequest('login', email, password);

  Future<void> logout() async {
    _token = null;
    accountEmail = null;
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _emailKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> _expireSession() async {
    _token = null;
    accountEmail = null;
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _emailKey);
  }

  Map<String, String> get _headers {
    final token = _token;
    if (token == null) {
      throw const CloudException('Please log in first.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on TimeoutException {
      throw const CloudException('The server took too long to respond.');
    } on http.ClientException {
      throw const CloudException(
        'Could not reach FitTrack Cloud. Check your internet connection.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }

  Future<void> _checkResponse(
    http.Response response,
    Map<String, dynamic> data,
  ) async {
    if (response.statusCode == 401) {
      await _expireSession();
      throw const SessionExpiredException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = data['detail'] ?? data['error'];
      throw CloudException(
        detail is String && detail.isNotEmpty
            ? detail
            : 'Cloud request failed (${response.statusCode}).',
      );
    }
  }

  Future<Map<String, dynamic>> currentUser() async {
    final response = await _send(
      () => http
          .get(Uri.parse('$baseUrl/auth/me'), headers: _headers)
          .timeout(_requestTimeout),
    );
    final data = _decodeObject(response);
    await _checkResponse(response, data);
    final user = data['user'];
    if (user is! Map<String, dynamic> || user['email'] is! String) {
      throw const CloudException('The server returned an invalid account.');
    }
    accountEmail = (user['email'] as String).trim().toLowerCase();
    await _secureStorage.write(key: _emailKey, value: accountEmail);
    return user;
  }

  Future<int> uploadWorkout(WorkoutSession workout) async {
    final response = await _send(
      () => http
          .post(
            Uri.parse('$baseUrl/workouts'),
            headers: _headers,
            body: jsonEncode(workout.toCloudJson()),
          )
          .timeout(_requestTimeout),
    );
    final data = _decodeObject(response);
    await _checkResponse(response, data);
    final id = data['id'];
    if (id is! num) {
      throw const CloudException('The server did not return a workout ID.');
    }
    return id.toInt();
  }

  Future<void> deleteWorkout(int workoutId) async {
    final response = await _send(
      () => http
          .delete(Uri.parse('$baseUrl/workouts/$workoutId'), headers: _headers)
          .timeout(_requestTimeout),
    );
    if (response.statusCode == 404) return;
    await _checkResponse(response, _decodeObject(response));
  }

  Future<List<WorkoutSession>> fetchWorkouts() async {
    final response = await _send(
      () => http
          .get(Uri.parse('$baseUrl/workouts'), headers: _headers)
          .timeout(_requestTimeout),
    );
    final decoded = _decodeObject(response);
    await _checkResponse(response, decoded);

    final Object? body;
    try {
      body = jsonDecode(response.body);
    } on FormatException {
      throw const CloudException('The server returned invalid workout data.');
    }
    final items = body is List
        ? body
        : body is Map<String, dynamic>
        ? body['workouts']
        : null;
    if (items is! List) {
      throw const CloudException('The server returned invalid workout data.');
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(WorkoutSession.fromJson)
        .toList();
  }
}

class CloudException implements Exception {
  const CloudException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SessionExpiredException extends CloudException {
  const SessionExpiredException()
    : super('Your session expired. Please log in again.');
}
