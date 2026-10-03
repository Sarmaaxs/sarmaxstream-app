import 'package:flutter/material.dart';
import 'app_theme.dart';

<<<<<<< HEAD
/// The square SarmaxStream logo (same image the website uses as its icon).
=======
>>>>>>> 559808d1ebbae9b95dcf20f0dd4adef721fc732e
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 44});
  final double size;

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(size * .22),
        child: Image.asset('assets/brand/logo.png',
            width: size, height: size, fit: BoxFit.cover),
      );
}

/// The "sarmaxstream" wordmark: white "sarmax" + lime "stream".
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 24});
  final double fontSize;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -fontSize * .03,
              height: 1),
          children: const [
            TextSpan(text: 'sarmax', style: TextStyle(color: Colors.white)),
            TextSpan(text: 'stream', style: TextStyle(color: AppTheme.lime)),
          ],
        ),
        semanticsLabel: 'SarmaxStream',
=======
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.lime,
          borderRadius: BorderRadius.circular(size * .28),
          boxShadow: [
            BoxShadow(
                color: AppTheme.lime.withValues(alpha: .22),
                blurRadius: 18,
                spreadRadius: 1)
          ],
        ),
        alignment: Alignment.center,
        child: Text('S',
            style: TextStyle(
                color: Colors.black,
                fontSize: size * .62,
                fontWeight: FontWeight.w900,
                height: 1)),
>>>>>>> 559808d1ebbae9b95dcf20f0dd4adef721fc732e
      );
}
