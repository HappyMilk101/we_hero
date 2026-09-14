import 'package:flutter/material.dart';

import '../../features/missions/domain/mission.dart';
import '../tokens.dart';

class PremiumMissionCard extends StatelessWidget {
  const PremiumMissionCard({
    super.key,
    required this.mission,
    required this.done,
    required this.onTap,
  });
  final Mission mission;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label:
        '${mission.title}, ${mission.minutes}분, Coin ${mission.coin}, XP ${mission.xp}',
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(HeroRadius.large),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(HeroRadius.large),
            border: Border.all(
              color: HeroColors.yellow.withValues(alpha: .65),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1417233C),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: HeroColors.mint.withValues(alpha: .4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(mission.icon, color: HeroColors.navy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.category.toUpperCase(),
                      style: const TextStyle(
                        color: HeroColors.coral,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission.title,
                      style: const TextStyle(
                        color: HeroColors.navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 15,
                          color: HeroColors.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${mission.minutes} min',
                          style: const TextStyle(
                            color: HeroColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _reward(
                          Icons.bolt,
                          '+${mission.coin}',
                          HeroColors.yellow,
                        ),
                        const SizedBox(width: 6),
                        _reward(Icons.star, '+${mission.xp}', HeroColors.mint),
                      ],
                    ),
                  ],
                ),
              ),
              done
                  ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                  : const Icon(
                      Icons.arrow_forward_rounded,
                      color: HeroColors.navy,
                    ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _reward(IconData icon, String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .3),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: HeroColors.navy),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: HeroColors.navy,
          ),
        ),
      ],
    ),
  );
}
