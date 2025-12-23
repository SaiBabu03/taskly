import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'Main_Screens/MainTasks_Screen.dart';
import 'Main_Screens/OnBoarding_Screen.dart';
import 'Main_Screens/Login_Screen.dart';

// Blocs
import 'package:taskly/blocs/auth/auth_bloc.dart';
import 'package:taskly/blocs/auth/auth_event.dart';
import 'package:taskly/blocs/auth/auth_state.dart';
import 'package:taskly/blocs/tasks/task_bloc.dart';
import 'package:taskly/blocs/tasks/tasks_event.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()..add(AppStarted())),
        // FIX: Remove ..add(LoadTasks()) from here.
        // We only want to load tasks once we are "Authenticated".
        BlocProvider(create: (context) => TasksBloc()),
      ],
      child: MyApp(isFirstTime: isFirstTime),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.read<TasksBloc>().add(LoadTasks());
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // 1. If user is logged in, they already finished onboarding, go to tasks
            if (state is Authenticated) {
              return const MainTasksScreen();
            }

            // 2. Decide between Onboarding or Login/Signup
            if (state is Unauthenticated ||
                state is AuthError ||
                state is AuthInitial) {
              // ONLY show Onboarding if isFirstTime is true
              if (isFirstTime) {
                return OnboardingScreen();
              } else {
                // Once they've seen onboarding once, they go to Login
                return const LoginScreen();
              }
            }

            // 3. Loading state
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF7E7CF7)),
              ),
            );
          },
        ),
      ),
    );
  }
}
