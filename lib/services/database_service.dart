import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save or update user progress
  Future<void> saveProgress(UserProgress progress) async {
    try {
      await _db.collection('users').doc(progress.userId).set(
            progress.toMap(),
            SetOptions(merge: true),
          );
      
      // Update streak
      await _updateStreak(progress.userId);
    } catch (e) {
      // debugPrint("Error saving progress: $e");
    }
  }

  Future<void> _updateStreak(String userId) async {
    final userDoc = _db.collection('users').doc(userId);
    final snapshot = await userDoc.get();
    
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final lastActiveDate = data['lastActiveDate'] as String?;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      if (lastActiveDate != today) {
        int currentStreak = data['streak'] ?? 0;
        final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
        
        if (lastActiveDate == yesterday) {
          currentStreak += 1;
        } else {
          currentStreak = 1;
        }
        
        await userDoc.update({
          'streak': currentStreak,
          'lastActiveDate': today,
        });
      }
    } else {
      await userDoc.set({
        'streak': 1,
        'lastActiveDate': DateTime.now().toIso8601String().substring(0, 10),
      }, SetOptions(merge: true));
    }
  }

  // Get user progress
  Future<UserProgress?> getProgress(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProgress.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      // debugPrint("Error getting progress: $e");
    }
    return null;
  }
}
