
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MedicationService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

static Future<List<Map<String, dynamic>>> getTracking({
  required String date,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  if (token == null || token.isEmpty) {
    throw Exception('Please log in first.');
  }

  final response = await http.get(
    Uri.parse('$baseUrl/api/medications/tracking?date=$date'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  ).timeout(const Duration(seconds: 15));

  final decoded = jsonDecode(response.body);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      decoded['message'] ?? 'Failed to load tracking records.',
    );
  }

  return List<Map<String, dynamic>>.from(decoded['logs'] ?? []);
}

static Future<void> updateTracking({
  required String medicationId,
  required String date,
  required String time,
  required bool isTaken,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  if (token == null || token.isEmpty) {
    throw Exception('Please log in first.');
  }

  final response = await http.patch(
    Uri.parse('$baseUrl/api/medications/$medicationId/tracking'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'date': date,
      'time': time,
      'is_taken': isTaken,
    }),
  ).timeout(const Duration(seconds: 15));

  final decoded = jsonDecode(response.body);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      decoded['message'] ?? 'Failed to update medication status.',
    );
  }
}

  static Future<List<Map<String, dynamic>>> getMedications() async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');

        if (token == null || token.isEmpty) {
            throw Exception('Please log in first.');
        }

        final response = await http.get(
            Uri.parse('$baseUrl/api/medications'),
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
            throw Exception(decoded['message'] ?? 'Failed to load medications.');
        }

        final medications = decoded['medications'];

        if (medications is! List) {
            throw Exception('Invalid medication data.');
        }

        return medications
            .whereType<Map<String, dynamic>>()
            .toList();
    }

  static Future<Map<String, dynamic>> saveMedication({
    required String name,
    required String bentukObat,
    required double jumlah,
    required double jumlahPerMinum,
    required int frequency,
    required bool isAsNeeded,
    required List<String> times,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Please log in before saving medication.');
    }

    final response = await http
        .post(
          Uri.parse('$baseUrl/api/medications'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name': name,
            'bentuk_obat': bentukObat,
            'jumlah': jumlah,
            'jumlah_per_minum': jumlahPerMinum,
            'frequency': frequency,
            'is_as_needed': isAsNeeded,
            'times': times,
          }),
        )
        .timeout(const Duration(seconds: 15));

        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
            throw Exception('Invalid server response.');
        }

        if (response.statusCode < 200 || response.statusCode >= 300) {
            throw Exception(
                decoded['message'] ?? 'Failed to save medication.'
            );
        }

        return decoded;
  }
}
