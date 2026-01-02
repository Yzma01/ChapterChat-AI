import 'package:chapter_chat_ai/blocs/book/bloc/book_bloc.dart';
import 'package:chapter_chat_ai/blocs/book/repository/book_repository.dart';
import 'package:chapter_chat_ai/blocs/loggin/bloc/loggin_bloc.dart';
import 'package:chapter_chat_ai/blocs/loggin/repository/loggin_repository.dart';
import 'package:chapter_chat_ai/blocs/payment/bloc/payment_bloc.dart';
import 'package:chapter_chat_ai/blocs/payment/reporitory/payment_repository.dart';
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
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/theme_provider.dart';
import 'blocs/chat/repository/chat_local_storage.dart';
import 'blocs/chat/repository/active_chats_storage.dart';
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

  // ============================================================
  // GEMINI INITIALIZATION
  // ============================================================
  try {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    Gemini.init(apiKey: apiKey!, enableDebugging: true);
    print('✅ Gemini inicializado correctamente');
  } catch (e) {
    print('❌ Error al inicializar Gemini: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
        BlocProvider(create: (_) => SignupBloc(SignupRepository())),
        BlocProvider(create: (_) => BookBloc(BookRepository())),
        BlocProvider(create: (_) => PaymentBloc(PaymentRepository())),
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
            return const Center(child: CircularProgressIndicator());
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
