import 'package:flutter/material.dart';
import 'app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 44});
  final double size;

  @override
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
      );
}
