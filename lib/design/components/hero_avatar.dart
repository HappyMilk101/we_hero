import 'package:flutter/material.dart';

class HeroAvatar extends StatelessWidget {
  const HeroAvatar({
    super.key,
    this.back,
    this.body,
    this.head,
    this.hands,
    this.accessory,
    this.effect,
  });

  final ImageProvider<Object>? back;
  final ImageProvider<Object>? body;
  final ImageProvider<Object>? head;
  final ImageProvider<Object>? hands;
  final ImageProvider<Object>? accessory;
  final ImageProvider<Object>? effect;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 100,
    height: 140,
    child: Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        if (back != null) Image(image: back!, fit: BoxFit.contain),
        Image.asset('assets/images/base_hero.png', fit: BoxFit.contain),
        if (body != null) Image(image: body!, fit: BoxFit.contain),
        if (hands != null) Image(image: hands!, fit: BoxFit.contain),
        if (head != null) Image(image: head!, fit: BoxFit.contain),
        if (accessory != null) Image(image: accessory!, fit: BoxFit.contain),
        if (effect != null) Image(image: effect!, fit: BoxFit.contain),
      ],
    ),
  );
}
