import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';

// Screen to check authentication status on app start
class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  @override
  void initState() {
    super.initState();
    checkAuth(); // run auth check on load
  }

  // Checks token and navigates accordingly
  void checkAuth() async {
    String? token = await AuthService.getToken(); // get saved token
    if (!mounted) return; // ensure widget is active
    await Future.delayed(const Duration(seconds: 1)); // small delay for UX
    if (token == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        "/login",
        (route) => false,
      ); // go to login
    } else {
      await UserService.fetchUserProfile(); // load user data
      await TaskService.getTasks(); // load tasks
      Navigator.pushReplacementNamed(context, "/"); // go to home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset("assets/logo.png", height: 100),

            const SizedBox(height: 10),

            // App Title
            const Text(
              "My Tasking",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3A4A),
              ),
            ),

            const SizedBox(height: 30),

            // Loading Indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
