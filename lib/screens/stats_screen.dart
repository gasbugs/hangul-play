import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BadgeCastleScreen extends StatelessWidget {
  const BadgeCastleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('🏰 훈장 성'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryHeader(user),
              const SizedBox(height: 30),
              const Text('✨ 오늘 나의 공부 기록', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildDailyStats(user),
              const SizedBox(height: 40),
              const Text('🗓️ 이번 주 성취도', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildWeeklyChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black12.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${user?.displayName ?? "아이"} 기사님!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('한글 정복까지 얼마 안 남았어요!', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats(User? user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('daily_scores')
          .where('userId', isEqualTo: user?.uid)
          .where('date', isEqualTo: DateTime.now().toIso8601String().substring(0, 10))
          .snapshots(),
      builder: (context, snapshot) {
        int totalStars = 0;
        int completedCount = 0;
        if (snapshot.hasData) {
          completedCount = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            totalStars += (doc['score'] as int);
          }
        }

        return Row(
          children: [
            _statCard('오늘의 별', '⭐ $totalStars', Colors.amber),
            const SizedBox(width: 15),
            _statCard('완성한 글자', '📝 $completedCount', Colors.blueAccent),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Simple bar visual for now
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(0.4, '월'), _bar(0.7, '화'), _bar(1.0, '수'), 
          _bar(0.6, '목'), _bar(0.2, '금'), _bar(0.0, '토'), _bar(0.0, '일'),
        ],
      ),
    );
  }

  Widget _bar(double heightFactor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 120 * heightFactor,
          width: 25,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFB7B2), Color(0xFFFF85A1)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
