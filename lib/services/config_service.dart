import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

class ConfigService {
  static Map<String, dynamic> _config = {};

  static void resetConfig() {
    _config = {};
  }

  static Future<void> loadConfig() async {
    try {
      final configString = await rootBundle.loadString('assets/config.json');
      _config = json.decode(configString);
    } catch (e) {
      // debugPrint('Could not load config: $e');
      _config = {
        'api_url': 'http://localhost:8080',
        'environment': 'development',
      };
    }
  }

  static FirebaseOptions get firebaseOptions => FirebaseOptions(
        apiKey: _config['firebase_api_key'] ?? '',
        authDomain: _config['firebase_auth_domain'] ?? '',
        projectId: _config['firebase_project_id'] ?? '',
        storageBucket: _config['firebase_storage_bucket'] ?? '',
        messagingSenderId: _config['firebase_messaging_sender_id'] ?? '',
        appId: _config['firebase_app_id'] ?? '',
        measurementId: _config['firebase_measurement_id'] ?? '',
      );

  static String get apiUrl => _config['api_url'] ?? 'http://localhost:8080';
  static String get environment => _config['environment'] ?? 'development';

  static dynamic get(String key) => _config[key];
}
