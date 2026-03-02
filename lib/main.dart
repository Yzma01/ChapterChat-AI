// main.dart
import 'package:chapter_chat_ai/blocs/chat/bloc/chat_bloc.dart';
import 'package:chapter_chat_ai/blocs/payment/bloc/payment_bloc.dart';
import 'package:chapter_chat_ai/blocs/payment/reporitory/payment_repository.dart';
import 'package:chapter_chat_ai/blocs/user/bloc/user_state.dart';
import 'package:chapter_chat_ai/core/ads/ad_provider.dart';
import 'package:chapter_chat_ai/core/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

  // Initialize the Mobile Ads SDK.
  MobileAds.instance.initialize();

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (_) => AuthBloc(
                  authRepository: AuthRepository(),
                  userRepository: UserRepository(),
                ),
          ),
          BlocProvider(create: (_) => SignupBloc(SignupRepository())),
          BlocProvider(create: (_) => BookBloc(BookRepository())),
          BlocProvider(create: (_) => PaymentBloc(PaymentRepository())),
          BlocProvider(create: (_) => LibraryBloc()),
          BlocProvider(create: (_) => ChatBloc()),
          BlocProvider(
            create:
                (context) => ProfileBloc(UserRepository())..add(LoadProfile()),
          ),
        ],
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

    // ⭐ Sincronizar ProfileBloc con UserProvider
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        debugPrint('📊 ProfileBloc state changed: ${state.runtimeType}');

        if (state is ProfileLoaded) {
          debugPrint('✅ ProfileLoaded - Setting user in UserProvider');
          context.read<UserProvider>().setUser(state.user);
        } else if (state is ProfileError) {
          debugPrint('❌ ProfileError: ${state.error}');
          context.read<UserProvider>().clear();
        } else if (state is ProfileLoading) {
          debugPrint('⏳ ProfileLoading');
        }
      },
      child: MaterialApp(
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
            debugPrint(
              '🔄 StreamBuilder - connectionState: ${snapshot.connectionState}',
            );
            debugPrint('🔄 StreamBuilder - hasData: ${snapshot.hasData}');

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
              debugPrint('❌ StreamBuilder error: ${snapshot.error}');
              return const LogginScreen();
            } else if (snapshot.hasData) {
              debugPrint(
                '✅ StreamBuilder - User authenticated: ${snapshot.data?.email}',
              );

              // ⭐ Usuario autenticado - Verificar si UserProvider está listo
              return Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  debugPrint(
                    '👤 UserProvider.isReady: ${userProvider.isReady}',
                  );

                  if (userProvider.isReady) {
                    debugPrint('✅ UserProvider ready - Showing MainShell');
                    return const MainShell();
                  } else {
                    debugPrint('⏳ UserProvider not ready - Loading profile...');

                    // Asegurar que LoadProfile se dispare
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final profileBloc = context.read<ProfileBloc>();
                      final currentState = profileBloc.state;

                      debugPrint(
                        '📊 Current ProfileBloc state: ${currentState.runtimeType}',
                      );

                      if (currentState is! ProfileLoaded &&
                          currentState is! ProfileLoading) {
                        debugPrint('🚀 Dispatching LoadProfile event');
                        profileBloc.add(LoadProfile());
                      }
                    });

                    return Scaffold(
                      backgroundColor: themeProvider.colors.background,
                      body: Center(
                        child: CircularProgressIndicator(
                          color: themeProvider.colors.primary,
                        ),
                      ),
                    );
                  }
                },
              );
            } else {
              debugPrint('🚪 No authenticated user - Showing LogginScreen');
              return const LogginScreen();
            }
          },
        ),
      ),
    );
  }
}
