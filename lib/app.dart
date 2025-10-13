import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:authx/providers/totp_provider.dart';
import 'package:authx/providers/theme_provider.dart';
import 'package:authx/services/timer_service.dart';
import 'package:authx/ui/screens/home_screen.dart';
import 'package:authx/utils/app_theme.dart';

class AuthXApp extends StatefulWidget {
  const AuthXApp({super.key});

  @override
  State<AuthXApp> createState() => _AuthXAppState();
}

class _AuthXAppState extends State<AuthXApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TotpProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'AuthX TOTP',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}