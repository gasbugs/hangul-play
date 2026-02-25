import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../utils/sound_service.dart';

class HandwritingCanvas extends StatefulWidget {
  final String targetChar;
  final bool isPuzzleMode;
  final List<String> distractors;
  final Function(int score, double percentage) onComplete;
  final VoidCallback onClear;

  const HandwritingCanvas({
    super.key,
    required this.targetChar,
    required this.onComplete,
    required this.onClear,
    this.isPuzzleMode = false,
    this.distractors = const [],
  });

  @override
  State<HandwritingCanvas> createState() => HandwritingCanvasState();
}

class HandwritingCanvasState extends State<HandwritingCanvas> {
  final List<Offset?> _points = [];
  bool _isSuccess = false;
  final List<String> _puzzlePieces = [];
  final List<String> _placedPieces = [];

  @override
  void initState() {
    super.initState();
    if (widget.isPuzzleMode) {
      _puzzlePieces.addAll(widget.targetChar.split(''));
      _puzzlePieces.addAll(widget.distractors);
      _puzzlePieces.shuffle();
    }
  }

  void clear() {
    setState(() {
      _points.clear();
      _placedPieces.clear();
      if (widget.isPuzzleMode) {
        _puzzlePieces.clear();
        _puzzlePieces.addAll(widget.targetChar.split(''));
        _puzzlePieces.addAll(widget.distractors);
        _puzzlePieces.shuffle();
      }
    });
    widget.onClear();
  }

  Future<Map<String, dynamic>> _calculateScore() async {
    if (widget.isPuzzleMode) {
      if (_placedPieces.length == widget.targetChar.length) {
        return {'score': 3, 'percentage': 100.0};
      }
      return {'score': 0, 'percentage': 0.0};
    }
    
    if (_points.isEmpty) return {'score': 0, 'percentage': 0.0};

    const double size = 300.0;
    const int gridSize = 30; 
    
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.scale(gridSize / size);

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
    
    final ui.PictureRecorder userRecorder = ui.PictureRecorder();
    final Canvas userCanvas = Canvas(userRecorder);
    userCanvas.scale(gridSize / size);
    final userPainter = DrawingPainter(points: _points, strokeWidth: 15.0);
    userPainter.paint(userCanvas, const Size(size, size));
    
    final ui.Image userImg = await userRecorder.endRecording().toImage(gridSize, gridSize);
    final ByteData? userData = await userImg.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (targetData == null || userData == null) return {'score': 1, 'percentage': 0.0};

    int matchCount = 0;
    int targetTotal = 0;
    int extraCount = 0;

    for (int i = 0; i < gridSize * gridSize; i++) {
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
    double accuracy = matchCount / (matchCount + extraCount * 0.5);
    
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
    double fontSize = 180.0;
    if (widget.targetChar.length > 1) {
      fontSize = 250.0 / widget.targetChar.length;
      if (fontSize > 120) fontSize = 120;
    }

    return Column(
      children: [
        Container(
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
          child: widget.isPuzzleMode
              ? _buildPuzzleTarget(fontSize)
              : _buildDrawingCanvas(fontSize),
        ),
        if (widget.isPuzzleMode && _puzzlePieces.isNotEmpty) ...[
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            runSpacing: 10,
            children: _puzzlePieces.map((char) => _buildDraggablePiece(char)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPuzzleTarget(double fontSize) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data == widget.targetChar[_placedPieces.length],
      onAcceptWithDetails: (details) {
        SoundService().playPop();
        setState(() {
          _placedPieces.add(details.data);
          _puzzlePieces.remove(details.data);
        });
        if (_placedPieces.length == widget.targetChar.length) {
          SoundService().playSuccess();
          submit();
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            Center(
              child: Text(
                widget.targetChar,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.withValues(alpha: 0.1),
                  letterSpacing: widget.targetChar.length > 1 ? 4.0 : 0.0,
                ),
              ),
            ),
            Center(
              child: Text(
                _placedPieces.join(''),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                  letterSpacing: widget.targetChar.length > 1 ? 4.0 : 0.0,
                ),
              ),
            ),
            if (candidateData.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDrawingCanvas(double fontSize) {
    return GestureDetector(
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
          CustomPaint(
            size: Size.infinite,
            painter: DrawingPainter(points: _points),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggablePiece(String char) {
    return Draggable<String>(
      data: char,
      onDragStarted: () => SoundService().playPop(),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF85A1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Text(
            char,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _pieceContainer(char),
      ),
      child: _pieceContainer(char),
    );
  }

  Widget _pieceContainer(String char) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF85A1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        char,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
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
