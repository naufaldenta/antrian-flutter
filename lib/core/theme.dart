import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/models.dart';

class AppColors {
  AppColors._();

  static const blue = Color(0xFF007AFF);
  static const indigo = Color(0xFF5856D6);
  static const purple = Color(0xFFAF52DE);
  static const pink = Color(0xFFFF2D55);
  static const red = Color(0xFFFF3B30);
  static const orange = Color(0xFFFF9500);
  static const yellow = Color(0xFFFFCC00);
  static const green = Color(0xFF34C759);
  static const teal = Color(0xFF30B0C7);
  static const gray = Color(0xFF8E8E93);

  static const label = Color(0xFF000000);
  static const secondaryLabel = Color(0x993C3C43);
  static const tertiaryLabel = Color(0x4D3C3C43);
  static const separator = Color(0x4A3C3C43);
  static const groupedBackground = Color(0xFFF2F2F7);
  static const card = Color(0xFFFFFFFF);
  static const fill = Color(0x1F767680);
  static const pressed = Color(0xFFE5E5EA);
}

class AppText {
  AppText._();

  static const largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.label,
  );
  static const title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.label,
  );
  static const title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.label,
  );
  static const title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.label,
  );
  static const headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.label,
  );
  static const body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
    color: AppColors.label,
  );
  static const callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    color: AppColors.label,
  );
  static const subhead = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    color: AppColors.secondaryLabel,
  );
  static const footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: AppColors.secondaryLabel,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryLabel,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.blue,
          onPrimary: Colors.white,
          surface: AppColors.card,
          error: AppColors.red,
        );
    const allCupertino = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.groupedBackground,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      pageTransitionsTheme: allCupertino,
      dividerColor: AppColors.separator,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.blue,
        linearTrackColor: AppColors.fill,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 8,
        contentTextStyle: AppText.subhead.copyWith(color: AppColors.label),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.blue,
        scaffoldBackgroundColor: AppColors.groupedBackground,
        barBackgroundColor: Color(0xF0F9F9F9),
      ),
    );
  }

  static Color statusColor(TicketStatus s) => switch (s) {
    TicketStatus.terjadwal => AppColors.indigo,
    TicketStatus.menunggu => AppColors.orange,
    TicketStatus.dipanggil => AppColors.green,
    TicketStatus.selesai => AppColors.gray,
    TicketStatus.dibatalkan => AppColors.red,
  };
}
