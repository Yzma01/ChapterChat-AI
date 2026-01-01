// ============================================================
// IMPORTS DE AUTENTICACIÓN (COMENTADOS TEMPORALMENTE)
// ============================================================
import 'package:chapter_chat_ai/blocs/book/bloc/book_bloc.dart';
import 'package:chapter_chat_ai/blocs/book/repository/book_repository.dart';
import 'package:chapter_chat_ai/blocs/loggin/bloc/loggin_bloc.dart';
import 'package:chapter_chat_ai/blocs/loggin/repository/loggin_repository.dart';
import 'package:chapter_chat_ai/blocs/signup/repository/signup_repository.dart';
import 'package:chapter_chat_ai/blocs/signup/bloc/signup_bloc.dart';
import 'package:chapter_chat_ai/blocs/user/repository/user_repository.dart';
import 'package:chapter_chat_ai/blocs/user/bloc/user_bloc.dart';
import 'package:chapter_chat_ai/blocs/user/bloc/user_event.dart';
import 'package:chapter_chat_ai/screens/auth/loggin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/theme_provider.dart';
import 'blocs/chat/repository/chat_local_storage.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // FIREBASE COMENTADO TEMPORALMENTE
  // ============================================================
  await Firebase.initializeApp();

  await ChatLocalStorage.initialize();

  try {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    Gemini.init(apiKey: apiKey!, enableDebugging: true);
    print('✅ Gemini inicializado correctamente');
  } catch (e) {
    print('❌ Error al inicializar Gemini: $e');
  }

  runApp(
    // ============================================================
    // BLOC PROVIDERS COMENTADOS TEMPORALMENTE
    // ============================================================
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
        BlocProvider(create: (_) => SignupBloc(SignupRepository())),
        BlocProvider(create: (_) => BookBloc(BookRepository())),
        BlocProvider(
          create: (_) => ProfileBloc(UserRepository())..add(LoadProfile()),
        ),
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
      home: StreamBuilder<User?>(
        stream:
            FirebaseAuth.instance
                .authStateChanges(), // Escucha cambios de autenticación
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Muestra un indicador mientras se verifica el estado
          } else if (snapshot.hasError) {
            return const LogginScreen();
          } else if (snapshot.hasData) {
            // Si el usuario está autenticado, muestra la pantalla principal
            return const MainShell();
          } else {
            // Si el usuario no está autenticado, muestra la pantalla de login
            return const LogginScreen();
          }
        },
      ),
    );
  }
}
