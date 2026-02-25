import 'package:flutter_test/flutter_test.dart';
import 'package:hangul_play/models/stage_model.dart';

void main() {
  group('Magic Canvas Stage Model Tests', () {
    test('Stage 1 should contain expected levels', () {
      final stage1 = hangulStages[0];
      expect(stage1.name, '자음의 비밀');
      expect(stage1.levels.length, 3);
      expect(stage1.levels[0].type, StageType.puzzle);
    });

    test('Stage 2 should be locked by default (simulated logic)', () {
      final stage2 = hangulStages[1];
      // In a real app, we check if all stage1 levels are cleared
      expect(stage2.levels.every((l) => l.isLocked), true);
    });
  });

  group('Level Progression Tests', () {
    test('Level copyWith should update lock status', () {
      final level = hangulStages[0].levels[1];
      expect(level.isLocked, true);
      
      final unlockedLevel = level.copyWith(isLocked: false);
      expect(unlockedLevel.isLocked, false);
      expect(unlockedLevel.id, level.id);
    });
  });
}
