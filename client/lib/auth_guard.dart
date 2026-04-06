import 'package:flutter/material.dart';
import 'services/services.dart';
import 'widgets/widgets.dart';
import 'package:http/http.dart' as http;
import "screens/screens.dart";
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Protected routes
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
    initApp();
  }

  void initApp() async {
    // Check connectivity at app open — same time as auth check
    final online = await ConnectivityService.isOnline();
    _initiallyOffline = !online;
    bool hasUpdate = await checkForUpdate();

    if (hasUpdate) return;
    await checkAuth();
  }

  //  version compare function
  bool isNewerVersion(String current, String latest) {
    List<int> c = current.split('.').map(int.parse).toList();
    List<int> l = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < l.length; i++) {
      int cv = i < c.length ? c[i] : 0;
      int lv = i < l.length ? l[i] : 0;

      if (lv > cv) return true;
      if (lv < cv) return false;
    }

    return false;
  }

  //  check app version
  Future<bool> checkForUpdate() async {
    try {
      final res = await http.get(
        Uri.parse("${ApiService.baseUrl}/app-version"),
      );

      final data = jsonDecode(res.body);

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String latestVersion = data['latestVersion'];

      if (isNewerVersion(currentVersion, latestVersion)) {
        if (data['forceUpdate'] == true) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text("Update Required"),
              content: const Text("You must update to continue"),
              actions: [
                TextButton(
                  onPressed: () async {
                    final url = Uri.parse(data['apkUrl']);
                    await launchUrl(url);
                  },
                  child: const Text("Update"),
                ),
              ],
            ),
          );

          return true; // stop app flow until update is done
        }

        // Optional update
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Update Available"),
            content: const Text("A new version is available"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Later"),
              ),
              TextButton(
                onPressed: () async {
                  final url = Uri.parse(data['apkUrl']);
                  await launchUrl(url);
                },
                child: const Text("Update"),
              ),
            ],
          ),
        );
      }

      return false;
    } catch (e) {
      print("Update error: $e");
      return false;
    }
  }

  //  auth check
  Future<void> checkAuth() async {
    final online = await ConnectivityService.isOnline();
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

        if (_lastOnlineStatus != null) {
          if (_lastOnlineStatus == true && isOnline == false) {
            //offline
            AppToast.showError(context, "No Internet Connection");
          } else if (_lastOnlineStatus == false && isOnline == true) {
            // online
            AppToast.showSuccess(context, "Back Online");
          }
        }

        _lastOnlineStatus = isOnline;

        return Stack(children: [screen!]);
      },
    );
  }
}
