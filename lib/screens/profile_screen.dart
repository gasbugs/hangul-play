import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final user = FirebaseAuth.instance.currentUser;
  
  // List of kid-friendly avatars
  final List<String> _avatars = ['🦁', '🐰', '🐥', '🐼', '🦊', '🐸'];
  String _selectedAvatar = '🦁';

  void _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text('👤 나의 프로필'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              // Current Avatar
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 20)],
                  border: Border.all(color: Colors.pinkAccent, width: 4),
                ),
                child: Center(
                  child: Text(_selectedAvatar, style: const TextStyle(fontSize: 80)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user?.displayName ?? '꼬마 기사님',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              
              const Text('어떤 친구로 꾸며볼까요?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              // Avatar Selection
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: _avatars.map((avatar) => GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = avatar),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedAvatar == avatar ? Colors.pinkAccent.withOpacity(0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _selectedAvatar == avatar ? Colors.pinkAccent : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Text(avatar, style: const TextStyle(fontSize: 40)),
                  ),
                )).toList(),
              ),
              
              const Spacer(),
              
              ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: const BorderSide(color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
