import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class SuccessOverlay extends StatefulWidget {
  final double scorePercentage;
  final int stars;
  final int streak; // Add streak
  final ConfettiController confettiController;
  final VoidCallback onDismiss;

  const SuccessOverlay({
    super.key,
    required this.scorePercentage,
    required this.stars,
    required this.streak, // Add streak
    required this.confettiController,
    required this.onDismiss,
  });

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.white.withValues(alpha: 0.95),
        child: Stack(
          children: [
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, size: 40, color: Colors.grey),
                onPressed: widget.onDismiss,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: const Text(
                      '⭐ 참 잘했어요! ⭐\n🌈 대단해요! 🌈',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4E8E),
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '${widget.scorePercentage.toStringAsFixed(1)}% 완벽하게 썼어요!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.streak > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 30),
                        Text(
                          ' ${widget.streak}일 연속 공부 중! ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 30),
                      ],
                    ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(
                          Icons.stars_rounded,
                          color: index < widget.stars ? const Color(0xFFFFD93D) : Colors.grey.shade300,
                          size: index == 1 ? 90 : 70,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF77E4D4),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: const Text(
                      '화면을 터작하면\n다음 글자로 넘어가요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ConfettiWidget(
                    confettiController: widget.confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    numberOfParticles: 30,
                    gravity: 0.1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
