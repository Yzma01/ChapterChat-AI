// ============================================================
// IMPORTS DE AUTENTICACIÓN (COMENTADOS TEMPORALMENTE)
// ============================================================
import 'package:chapter_chat_ai/blocs/loggin/loggin_bloc.dart';
import 'package:chapter_chat_ai/blocs/loggin/repository/loggin_repository.dart';
import 'package:chapter_chat_ai/blocs/signup/repository/signup_repository.dart';
import 'package:chapter_chat_ai/blocs/signup/signup_bloc.dart';
import 'package:chapter_chat_ai/screens/auth/loggin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/theme_provider.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // FIREBASE COMENTADO TEMPORALMENTE
  // ============================================================
  await Firebase.initializeApp();

  runApp(
    // ============================================================
    // BLOC PROVIDERS COMENTADOS TEMPORALMENTE
    // ============================================================
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
        BlocProvider(create: (_) => SignupBloc(SignupRepository())),
      ],
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    ),

    // 👇 VERSIÓN SIN AUTENTICACIÓN - CARGA DIRECTO AL HOME
    //   ChangeNotifierProvider(
    //     create: (_) => ThemeProvider(),
    //     child: const MyApp(),
    //   ),
    // );
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void updateSystemUI(ThemeProvider themeProvider) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: themeProvider.colors.background,
        systemNavigationBarIconBrightness:
            themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    updateSystemUI(themeProvider); // 🔥 Actualiza barra de estado y navegación

    return MaterialApp(
      title: 'Mi Biblioteca',
      debugShowCheckedModeBanner: false,

      themeMode: themeProvider.themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.lightSurface,
          error: AppColors.error,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.darkSurface,
          error: AppColors.error,
        ),
      ),

      // ============================================================
      // PANTALLA DE LOGIN COMENTADA TEMPORALMENTE
      // ============================================================
      home: const LogginScreen(), // 👈 Ya NO necesita ThemeProvider
      // 👇 CARGA DIRECTA AL HOME (MainShell)
      //home: MainShell(themeProvider: themeProvider),
    );
  }
}
