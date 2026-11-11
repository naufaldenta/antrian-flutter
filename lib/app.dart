import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_shell.dart';
import 'services/auth_service.dart';

class AntreSehatApp extends StatelessWidget {
  const AntreSehatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AntreSehat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      locale: const Locale('id'),
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.select<AuthService, bool>((a) => a.isLoggedIn);
    return loggedIn ? const HomeShell() : const LoginScreen();
  }
}
