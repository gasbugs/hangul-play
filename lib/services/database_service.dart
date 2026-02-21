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
    } catch (e) {
      print("Error saving progress: $e");
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
      print("Error getting progress: $e");
    }
    return null;
  }
}
