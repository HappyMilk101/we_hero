import 'package:flutter/material.dart';

import '../tokens.dart';

class SidekickWidget extends StatelessWidget {
  const SidekickWidget({
    super.key,
    required this.message,
    required this.loading,
    required this.onTap,
  });
  final String message;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: HeroColors.yellow,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Color(0x33FFC857), blurRadius: 14),
          ],
        ),
        child: const Center(child: _RobotFace()),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: GestureDetector(
          onTap: loading ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              border: Border.all(color: HeroColors.mint),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1217233C),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: HeroColors.navy,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.arrow_forward_rounded,
                        color: HeroColors.navy,
                      ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _RobotFace extends StatelessWidget {
  const _RobotFace();
  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 27,
    decoration: BoxDecoration(
      color: HeroColors.navy,
      borderRadius: BorderRadius.circular(11),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(radius: 3, backgroundColor: HeroColors.mint),
        SizedBox(width: 7),
        CircleAvatar(radius: 3, backgroundColor: HeroColors.mint),
      ],
    ),
  );
}
