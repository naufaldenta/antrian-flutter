import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 84});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.225),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E9BFF), AppColors.blue, AppColors.indigo],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.add_rounded, color: Colors.white, size: size * 0.78),
          Positioned(
            right: size * 0.16,
            top: size * 0.16,
            child: Icon(
              CupertinoIcons.heart_fill,
              color: Colors.white.withValues(alpha: 0.9),
              size: size * 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
