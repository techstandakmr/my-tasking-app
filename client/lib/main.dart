import 'auth_guard.dart';
import 'package:flutter/material.dart';
import "screens/screens.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const AuthGuard(routeName: "/"),

      routes: {
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const SignupScreen(),
        "/forgot-password": (context) => const ForgotPasswordScreen(),

        "/": (context) => HomeScreen(),

        "/add-task": (context) => const AddTaskScreen(),
        "/edit-task": (context) => const EditTaskScreen(),
        "/my-tasks": (context) => const MyTasksScreen(),
        "/task-details": (context) => const TaskDetailsScreen(),
        "/notifications": (context) => const NotificationScreen(),

        "/profile": (context) => const ProfileScreen(),
        "/edit-profile": (context) => const ProfileEditScreen(),
        "/update-password": (context) => const UpdatePasswordScreen(),
        "/delete-account": (context) => const DeleteAccountScreen(),
      },
    );
  }
}
