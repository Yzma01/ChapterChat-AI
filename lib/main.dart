import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'blocs/book/bloc/book_bloc.dart';
import 'blocs/book/repository/book_repository.dart';
import 'blocs/chat/repository/chat_local_storage.dart';
import 'blocs/chat/repository/active_chats_storage.dart';
import 'blocs/library/bloc/library_bloc.dart';
import 'blocs/library/repository/library_local_storage.dart';
import 'blocs/loggin/bloc/loggin_bloc.dart';
import 'blocs/loggin/repository/loggin_repository.dart';
import 'blocs/signup/bloc/signup_bloc.dart';
import 'blocs/signup/repository/signup_repository.dart';
import 'blocs/user/bloc/user_bloc.dart';
import 'blocs/user/bloc/user_event.dart';
import 'blocs/user/repository/user_repository.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_provider.dart';
import 'screens/auth/loggin_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // FIREBASE INITIALIZATION
  // ============================================================
  await Firebase.initializeApp();

  // ============================================================
  // HIVE INITIALIZATION (Local Storage)
  // ============================================================
  await Hive.initFlutter();
  await ChatLocalStorage.initialize();
  await ActiveChatsStorage.initialize();
  await LibraryLocalStorage.initialize();

  // ============================================================
  // GEMINI INITIALIZATION
  // ============================================================
  try {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      Gemini.init(apiKey: apiKey, enableDebugging: true);
      print('✅ Gemini inicializado correctamente');
    } else {
      print('⚠️ GEMINI_API_KEY not found in .env');
    }
  } catch (e) {
    print('❌ Error al inicializar Gemini: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
        BlocProvider(create: (_) => SignupBloc(SignupRepository())),
        BlocProvider(create: (_) => BookBloc(BookRepository())),
        BlocProvider(create: (_) => LibraryBloc()),
        BlocProvider(
          create: (_) => ProfileBloc(UserRepository())..add(LoadProfile()),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    ),
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

    updateSystemUI(themeProvider);

    return MaterialApp(
      title: 'ChapterChat AI',
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: themeProvider.colors.background,
              body: Center(
                child: CircularProgressIndicator(
                  color: themeProvider.colors.primary,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return const LogginScreen();
          } else if (snapshot.hasData) {
            return const MainShell();
          } else {
            return const LogginScreen();
          }
        },
      ),
    );
  }
}
