import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:typed_data';

class HandwritingCanvas extends StatefulWidget {
  final String targetChar;
  final Function(int score, double percentage) onComplete;
  final VoidCallback onClear;

  const HandwritingCanvas({
    super.key,
    required this.targetChar,
    required this.onComplete,
    required this.onClear,
  });

  @override
  State<HandwritingCanvas> createState() => HandwritingCanvasState();
}

class HandwritingCanvasState extends State<HandwritingCanvas> {
  final List<Offset?> _points = [];

  void clear() {
    setState(() {
      _points.clear();
    });
    widget.onClear();
  }

  // Returns {score, percentage}
  Future<Map<String, dynamic>> _calculateScore() async {
    if (_points.isEmpty) return {'score': 0, 'percentage': 0.0};

    const double size = 300.0;
    const int gridSize = 30; // 30x30 grid for comparison
    
    // 1. Create a bitmask for the target character
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.scale(gridSize / size); // Scale down to fit gridSize

    // Dynamic font size logic (same as build)
    double fontSize = 180.0;
    double letterSpacing = 0.0;
    if (widget.targetChar.length > 1) {
      fontSize = 250.0 / widget.targetChar.length;
      if (fontSize > 120) fontSize = 120;
      letterSpacing = 4.0;
    }
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.targetChar,
        style: TextStyle(
          fontSize: fontSize, 
          fontWeight: FontWeight.bold, 
          color: Colors.black,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2));
    
    final ui.Image targetImg = await recorder.endRecording().toImage(gridSize, gridSize);
    final ByteData? targetData = await targetImg.toByteData(format: ui.ImageByteFormat.rawRgba);
    
    // 2. Create a bitmask for the user drawing
    final ui.PictureRecorder userRecorder = ui.PictureRecorder();
    final Canvas userCanvas = Canvas(userRecorder);
    userCanvas.scale(gridSize / size); // Scale down to fit gridSize
    final userPainter = DrawingPainter(points: _points, strokeWidth: 15.0);
    userPainter.paint(userCanvas, const Size(size, size));
    
    final ui.Image userImg = await userRecorder.endRecording().toImage(gridSize, gridSize);
    final ByteData? userData = await userImg.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (targetData == null || userData == null) return {'score': 1, 'percentage': 0.0};

    int matchCount = 0;
    int targetTotal = 0;
    int extraCount = 0; // Penalize points far from the target

    for (int i = 0; i < gridSize * gridSize; i++) {
      // Check alpha channel (3rd byte in RGBA)
      bool isTarget = targetData.getUint8(i * 4 + 3) > 20;
      bool isUser = userData.getUint8(i * 4 + 3) > 20;

      if (isTarget) {
        targetTotal++;
        if (isUser) matchCount++;
      } else if (isUser) {
        extraCount++;
      }
    }

    if (targetTotal == 0) return {'score': 1, 'percentage': 0.0};
    
    double coverage = matchCount / targetTotal;
    double accuracy = matchCount / (matchCount + extraCount * 0.5); // Slight penalty for messy scribbles
    
    double finalPercentage = (coverage * 0.7 + accuracy * 0.3) * 100 * 2.0;
    if (finalPercentage > 100.0) finalPercentage = 100.0;
    
    int stars = 0;
    if (finalPercentage >= 90) {
      stars = 3;
    } else if (finalPercentage >= 80) {
      stars = 2;
    } else if (finalPercentage >= 70) {
      stars = 1;
    }
    
    return {'score': stars, 'percentage': finalPercentage};
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic font size based on text length
    double fontSize = 180.0;
    if (widget.targetChar.length > 1) {
      fontSize = 250.0 / widget.targetChar.length;
      if (fontSize > 120) fontSize = 120;
    }

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD93D), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            _points.add(renderBox.globalToLocal(details.globalPosition));
          });
        },
        onPanEnd: (details) async {
          _points.add(null);
        },
        child: Stack(
          children: [
            // Guide Character
            Center(
              child: Text(
                widget.targetChar,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.withValues(alpha: 0.2),
                  letterSpacing: widget.targetChar.length > 1 ? 4.0 : 0.0,
                ),
              ),
            ),
            // User Drawing
            CustomPaint(
              size: Size.infinite,
              painter: DrawingPainter(points: _points),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submit() async {
    final result = await _calculateScore();
    widget.onComplete(result['score'], result['percentage']);
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final double strokeWidth;

  DrawingPainter({required this.points, this.strokeWidth = 12.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}
