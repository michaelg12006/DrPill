
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

  static Future<void> completeOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  if (token == null || token.isEmpty) {
    throw Exception('Please log in first.');
  }

  final response = await http.patch(
    Uri.parse('$baseUrl/api/auth/onboarding/complete'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  ).timeout(const Duration(seconds: 15));

  final decoded = jsonDecode(response.body);

  if (decoded is! Map<String, dynamic>) {
    throw Exception('Invalid server response.');
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      decoded['message'] ?? 'Failed to complete onboarding.',
    );
  }
}

  // Register a new user.
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _post(
      '/api/auth/register',
      {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      },
    );
  }

  // Login an existing user.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await _post(
      '/api/auth/login',
      {
        'email': email.trim(),
        'password': password,
      },
    );

    // Get the access token from the backend response.
    final session = data['session'];

    final String? accessToken = session is Map
        ? session['access_token']?.toString()
        : data['access_token']?.toString();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception(
        'Login successful, but no access token was received.',
      );
    }

    // Save token for authenticated API requests.
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('access_token', accessToken);

    debugPrint('Access token saved successfully.');

    return data;
  }

  // Shared POST request handler.
  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      debugPrint('API Request: $uri');
      debugPrint('Platform: ${kIsWeb ? "WEB" : defaultTargetPlatform}');
      debugPrint('Base URL: $baseUrl');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('API Status: ${response.statusCode}');

      final data = _decodeResponse(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data['message'] ??
              data['error'] ??
              'Request failed (${response.statusCode})',
        );
      }

      return data;
    } on TimeoutException {
      throw Exception(
        'Connection timed out. Please check your backend.',
      );
    } on http.ClientException catch (e) {
      debugPrint('HTTP Client Error: $e');

      throw Exception(
        'Cannot connect to the server. '
        'Make sure your backend is running.',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('An unexpected error occurred.');
    }
  }

  static Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Unexpected server response.');
    } on FormatException {
      throw Exception('Invalid response received from server.');
    }
  }
}
