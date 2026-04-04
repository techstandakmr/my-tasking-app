import 'package:flutter/material.dart';
import 'services/services.dart';
import 'widgets/widgets.dart';
// Screens
import "screens/screens.dart";

class AuthGuard extends StatefulWidget {
  final String routeName;
  final dynamic arguments;

  const AuthGuard({super.key, required this.routeName, this.arguments});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  Widget? screen;
  bool _initiallyOffline = false; // tracks offline state at app open
  bool? _lastOnlineStatus;

  // Protected routes (LIKE Laravel middleware)
  final List<String> protectedRoutes = [
    "/",
    "/add-task",
    "/edit-task",
    "/my-tasks",
    "/task-details",
    "/notifications",
    "/profile",
    "/edit-profile",
    "/update-password",
    "/delete-account",
  ];

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  void checkAuth() async {
    // Check connectivity at app open — same time as auth check
    final online = await ConnectivityService.isOnline();
    _initiallyOffline = !online;
    String? token = await AuthService.getToken();

    final isProtected = protectedRoutes.contains(widget.routeName);
    if (isProtected && token == null) {
      screen = const LoginScreen();
    } else if (!isProtected && token != null) {
      if (widget.routeName == "/forgot-password") {
        screen = const ForgotPasswordScreen();
      } else {
        if (online) {
          await UserService.fetchUserProfile();
          await TaskService.getTasks();
        }
        screen = const HomeScreen();
      }
    } else {
      if (token != null && online) {
        await UserService.fetchUserProfile();
        await TaskService.getTasks();
      }
      screen = getScreen(widget.routeName);
    }

    if (mounted) setState(() {});
  }

  Widget getScreen(String route) {
    switch (route) {
      case "/":
        return HomeScreen();
      case "/login":
        return const LoginScreen();
      case "/signup":
        return const SignupScreen();
      case "/forgot-password":
        return const ForgotPasswordScreen();

      // Tasks
      case "/add-task":
        return const AddTaskScreen();
      case "/edit-task":
        return EditTaskScreen(arguments: widget.arguments);
      case "/my-tasks":
        return const MyTasksScreen();
      case "/task-details":
        return TaskDetailsScreen(arguments: widget.arguments);
      case "/notifications":
        return const NotificationScreen();

      // Profile
      case "/profile":
        return const ProfileScreen();
      case "/edit-profile":
        return const ProfileEditScreen();
      case "/update-password":
        return const UpdatePasswordScreen();
      case "/delete-account":
        return const DeleteAccountScreen();

      default:
        return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (screen == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset("assets/logo.png", height: 100),

              const SizedBox(height: 10),

              // App Name
              const Text(
                "My Tasking",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3A4A),
                ),
              ),

              const SizedBox(height: 30),

              // Loader
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
    if (_initiallyOffline) {
      return const OfflineScreen();
    }
    return StreamBuilder<bool>(
      stream: ConnectivityService.connectionStream,
      initialData: true,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        //  Detect change
        if (_lastOnlineStatus != null) {
          if (_lastOnlineStatus == true && isOnline == false) {
            // Went OFFLINE
            AppToast.showError(context, "No Internet Connection");
          } else if (_lastOnlineStatus == false && isOnline == true) {
            // Back ONLINE
            AppToast.showSuccess(context, "Back Online");
          }
        }

        _lastOnlineStatus = isOnline;

        return Stack(children: [screen!]);
      },
    );
  }
}
