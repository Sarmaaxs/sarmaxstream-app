import 'package:flutter/material.dart';
import 'app_theme.dart';

/// The square SarmaxStream logo (same image the website uses as its icon).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 44});
  final double size;

  @override
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
      );
}
