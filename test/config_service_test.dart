import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_play/services/config_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfigService Tests', () {
    setUp(() {
      ConfigService.resetConfig();
      rootBundle.evict('assets/config.json');
    });

    const mockConfig = {
      'api_url': 'https://api.test.com',
      'environment': 'test',
      'firebase_api_key': 'test-key',
    };

    setupMockConfig() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final Uint8List encoded = utf8.encoder.convert(json.encode(mockConfig));
        return encoded.buffer.asByteData();
      });
    }

    test('loadConfig loads configuration correctly', () async {
      setupMockConfig();
      await ConfigService.loadConfig();
      
      expect(ConfigService.apiUrl, 'https://api.test.com');
      expect(ConfigService.environment, 'test');
    });

    test('firebaseOptions returns correct values', () async {
      setupMockConfig();
      await ConfigService.loadConfig();
      
      final options = ConfigService.firebaseOptions;
      expect(options.apiKey, 'test-key');
    });

    test('fallback when config loading fails', () async {
      // Mock failure by setting a handler that throws
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        return null; // Simulate file not found
      });

      await ConfigService.loadConfig();
      
      expect(ConfigService.apiUrl, 'http://localhost:8080');
      expect(ConfigService.environment, 'development');
    });
  });
}
