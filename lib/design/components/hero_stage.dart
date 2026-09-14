import 'package:flutter/material.dart';

import '../tokens.dart';

class HeroStage extends StatelessWidget {
  const HeroStage({
    super.key,
    required this.nickname,
    required this.coins,
    required this.xp,
    required this.hero,
  });
  final String nickname;
  final int coins, xp;
  final Widget hero;

  @override
  Widget build(BuildContext context) => Container(
    height: 360,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: HeroColors.navy,
      borderRadius: BorderRadius.circular(HeroRadius.card),
      boxShadow: const [
        BoxShadow(
          color: Color(0x3317233C),
          blurRadius: 22,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _StagePainter())),
        Positioned(
          top: 22,
          left: 22,
          child: _label('HERO HQ', HeroColors.mint),
        ),
        Positioned(
          top: 22,
          right: 22,
          child: _label('ONLINE', HeroColors.yellow),
        ),
        Positioned(
          top: 67,
          left: 24,
          right: 24,
          child: Container(height: 1, color: Colors.white12),
        ),
        Positioned(
          top: 86,
          left: 0,
          right: 0,
          child: Center(child: Transform.scale(scale: 1.38, child: hero)),
        ),
        Positioned(
          bottom: 84,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 150,
              height: 18,
              decoration: BoxDecoration(
                color: HeroColors.yellow.withValues(alpha: .22),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LV. 02  •  $nickname',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 190,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: (xp % 125) / 125,
                    backgroundColor: Colors.white24,
                    color: HeroColors.yellow,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$xp / 225 HERO XP',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Positioned(right: 22, bottom: 24, child: _console(coins)),
      ],
    ),
  );

  Widget _label(String text, Color color) => Text(
    text,
    style: TextStyle(
      color: color,
      letterSpacing: 1.5,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    ),
  );
  Widget _console(int coins) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      children: [
        const Icon(Icons.bolt, color: HeroColors.yellow, size: 16),
        const SizedBox(width: 4),
        Text(
          '$coins',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _StagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .035);
    for (var i = 0; i < 5; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(20 + i * 78, 92, 58, 90),
          const Radius.circular(14),
        ),
        paint,
      );
    }
    final glow = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x55FFC857), Color(0x0017233C)],
          ).createShader(
            Rect.fromCircle(center: Offset(size.width / 2, 215), radius: 150),
          );
    canvas.drawCircle(Offset(size.width / 2, 215), 150, glow);
    final platform = Paint()..color = const Color(0x338ED8C5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, 278),
        width: 230,
        height: 38,
      ),
      platform,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
