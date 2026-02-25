import 'package:cloud_firestore/cloud_firestore.dart';

class StickerService {
  final FirebaseFirestore _db;

  StickerService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // Award a sticker to a user
  Future<void> awardSticker(String userId, String char) async {
    try {
      await _db.collection('users').doc(userId).collection('stickers').doc(char).set({
        'char': char,
        'earnedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // debugPrint("Error awarding sticker: $e");
    }
  }

  // Get all earned stickers for a user
  Future<List<String>> getEarnedStickers(String userId) async {
    try {
      final snapshot = await _db.collection('users').doc(userId).collection('stickers').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      // debugPrint("Error getting stickers: $e");
      return [];
    }
  }
}
