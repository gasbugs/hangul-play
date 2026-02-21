import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/world_map_screen.dart';
import 'services/auth_service.dart';
import 'services/config_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load configuration first
  await ConfigService.loadConfig();
  
  // 2. Initialize Firebase with dynamic config
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: ConfigService.firebaseApiKey,
      authDomain: ConfigService.firebaseAuthDomain,
      projectId: ConfigService.firebaseProjectId,
      storageBucket: ConfigService.firebaseStorageBucket,
      messagingSenderId: ConfigService.firebaseMessagingSenderId,
      appId: ConfigService.firebaseAppId,
      measurementId: ConfigService.firebaseMeasurementId,
    ),
  );
  
  runApp(const HangulPlayApp());
}

class HangulPlayApp extends StatelessWidget {
  const HangulPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '한글 놀이',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF85A1),
          primary: const Color(0xFFFF85A1),
          secondary: const Color(0xFF77E4D4),
        ),
        textTheme: GoogleFonts.nanumGothicTextTheme(),
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const WorldMapScreen();
        }
        return LoginScreen();
      },
    );
  }
}
