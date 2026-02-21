class UserProgress {
  final String userId;
  final int lastIndex;
  final List<String> completedChars;

  UserProgress({
    required this.userId,
    required this.lastIndex,
    required this.completedChars,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lastIndex': lastIndex,
      'completedChars': completedChars,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] ?? '',
      lastIndex: map['lastIndex'] ?? 0,
      completedChars: List<String>.from(map['completedChars'] ?? []),
    );
  }
}
