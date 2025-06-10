// ignore_for_file: use_super_parameters

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PurchaseSuccessOverlay extends StatelessWidget {
  final AnimationController animation;
  final VoidCallback onComplete;

  const PurchaseSuccessOverlay({
    Key? key,
    required this.animation,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (animation.value == 0.0) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.black.withOpacity(0.8 * animation.value),
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
              ),
            );

            final checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
              ),
            );

            final confettiAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
              ),
            );

            return Stack(
              children: [
                ...List.generate(
                  20,
                  (index) => _buildConfetti(confettiAnimation, index),
                ),

                Transform.scale(
                  scale: scaleAnimation.value,
                  child: Card(
                    margin: const EdgeInsets.all(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: CustomPaint(
                              painter: CheckmarkPainter(checkAnimation.value),
                              child: const SizedBox.expand(),
                            ),
                          ),

                          const SizedBox(height: 32),

                          const Text(
                            'Welcome to Premium!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'You now have unlimited access to all premium features',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryNavy.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Unlimited coin identifications',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Full collection history'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Collection value tracking'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConfetti(Animation<double> animation, int index) {
    final random = math.Random(index);
    final colors = [
      AppColors.primaryGold,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
    ];

    final color = colors[index % colors.length];
    final startX = random.nextDouble() * 400;
    final startY = random.nextDouble() * 200 + 100;
    final endY = startY + 300 + random.nextDouble() * 200;
    final rotation = random.nextDouble() * 4 * math.pi;

    return Positioned(
      left: startX,
      top: startY + (endY - startY) * animation.value,
      child: Transform.rotate(
        angle: rotation * animation.value,
        child: Opacity(
          opacity: 1.0 - animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: random.nextBool() ? BoxShape.circle : BoxShape.rectangle,
            ),
          ),
        ),
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;

  CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final checkPath = Path();

    final startPoint = Offset(center.dx - 12, center.dy);
    final midPoint = Offset(center.dx - 4, center.dy + 8);
    final endPoint = Offset(center.dx + 12, center.dy - 8);

    if (progress <= 0.5) {
      final firstProgress = progress * 2;
      final currentPoint = Offset.lerp(startPoint, midPoint, firstProgress)!;

      checkPath.moveTo(startPoint.dx, startPoint.dy);
      checkPath.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      final secondProgress = (progress - 0.5) * 2;
      final currentPoint = Offset.lerp(midPoint, endPoint, secondProgress)!;

      checkPath.moveTo(startPoint.dx, startPoint.dy);
      checkPath.lineTo(midPoint.dx, midPoint.dy);
      checkPath.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
