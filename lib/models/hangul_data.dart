class HangulChar {
  final String char;
  final String sound;

  HangulChar({required this.char, required this.sound});
}

final List<HangulChar> hangulList = [
  // Consonants
  HangulChar(char: 'ㄱ', sound: '기역'),
  HangulChar(char: 'ㄴ', sound: '니은'),
  HangulChar(char: 'ㄷ', sound: '디귿'),
  HangulChar(char: 'ㄹ', sound: '리을'),
  HangulChar(char: 'ㅁ', sound: '미음'),
  HangulChar(char: 'ㅂ', sound: '비읍'),
  HangulChar(char: 'ㅅ', sound: '시옷'),
  HangulChar(char: 'ㅇ', sound: '이응'),
  HangulChar(char: 'ㅈ', sound: '지읒'),
  HangulChar(char: 'ㅊ', sound: '치읓'),
  HangulChar(char: 'ㅋ', sound: '키읔'),
  HangulChar(char: 'ㅌ', sound: '티읕'),
  HangulChar(char: 'ㅍ', sound: '피읖'),
  HangulChar(char: 'ㅎ', sound: '히읗'),
  // Vowels
  HangulChar(char: 'ㅏ', sound: '아'),
  HangulChar(char: 'ㅑ', sound: '야'),
  HangulChar(char: 'ㅓ', sound: '어'),
  HangulChar(char: 'ㅕ', sound: '여'),
  HangulChar(char: 'ㅗ', sound: '오'),
  HangulChar(char: 'ㅛ', sound: '요'),
  HangulChar(char: 'ㅜ', sound: '우'),
  HangulChar(char: 'ㅠ', sound: '유'),
  HangulChar(char: 'ㅡ', sound: '으'),
  HangulChar(char: 'ㅣ', sound: '이'),
];
