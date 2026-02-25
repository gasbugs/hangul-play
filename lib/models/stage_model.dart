enum StageType {
  drawing,
  puzzle
}

class Level {
  final String id;
  final String title;
  final List<String> targetChars;
  final StageType type;
  final bool isLocked;
  final int stars;

  Level({
    required this.id,
    required this.title,
    required this.targetChars,
    this.type = StageType.drawing,
    this.isLocked = true,
    this.stars = 0,
  });

  Level copyWith({bool? isLocked, int? stars}) {
    return Level(
      id: id,
      title: title,
      targetChars: targetChars,
      type: type,
      isLocked: isLocked ?? this.isLocked,
      stars: stars ?? this.stars,
    );
  }
}

class Stage {
  final String id;
  final String name;
  final List<Level> levels;

  Stage({
    required this.id,
    required this.name,
    required this.levels,
  });
}

final List<Stage> hangulStages = [
  Stage(
    id: 'stage_1',
    name: '자음의 비밀',
    levels: [
      Level(id: 'l1_1', title: '기본 자음 (ㄱ,ㄴ,ㄷ)', targetChars: ['ㄱ', 'ㄴ', 'ㄷ'], type: StageType.puzzle, isLocked: false),
      Level(id: 'l1_2', title: '기본 자음 (ㄹ,ㅁ,ㅂ)', targetChars: ['ㄹ', 'ㅁ', 'ㅂ'], type: StageType.puzzle),
      Level(id: 'l1_3', title: '자음 완성하기', targetChars: ['ㅅ', 'ㅇ', 'ㅈ', 'ㅊ'], type: StageType.drawing),
    ],
  ),
  Stage(
    id: 'stage_2',
    name: '모음의 마법',
    levels: [
      Level(id: 'l2_1', title: '기본 모음 (ㅏ,ㅑ,ㅓ)', targetChars: ['ㅏ', 'ㅑ', 'ㅓ'], type: StageType.puzzle),
      Level(id: 'l2_2', title: '기본 모음 (ㅕ,ㅗ,ㅛ)', targetChars: ['ㅕ', 'ㅗ', 'ㅛ'], type: StageType.puzzle),
      Level(id: 'l2_3', title: '모음 완성하기', targetChars: ['ㅜ', 'ㅠ', 'ㅡ', 'ㅣ'], type: StageType.drawing),
    ],
  ),
];
