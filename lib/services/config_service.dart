import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigService {
  static Map<String, dynamic> _config = {};

  static Future<void> loadConfig() async {
    try {
      final configString = await rootBundle.loadString('assets/config.json');
      _config = json.decode(configString);
    } catch (e) {
      print('Could not load config: $e');
      // Fallback or default values
      _config = {
        'api_url': 'http://localhost:8080',
        'environment': 'development',
      };
    }
  }

  static String get apiUrl => _config['api_url'] ?? 'http://localhost:8080';
  static String get environment => _config['environment'] ?? 'development';

  // Firebase Config
  static String get firebaseApiKey => _config['firebase_api_key'] ?? '';
  static String get firebaseAuthDomain => _config['firebase_auth_domain'] ?? '';
  static String get firebaseProjectId => _config['firebase_project_id'] ?? '';
  static String get firebaseStorageBucket => _config['firebase_storage_bucket'] ?? '';
  static String get firebaseMessagingSenderId => _config['firebase_messaging_sender_id'] ?? '';
  static String get firebaseAppId => _config['firebase_app_id'] ?? '';
  static String get firebaseMeasurementId => _config['firebase_measurement_id'] ?? '';

  static dynamic get(String key) => _config[key];
}
