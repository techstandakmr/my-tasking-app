import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    initApp();
  }

  // Checks token and navigates accordingly
  void initApp() async {
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
    String? token = await AuthService.getToken();

    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 1));

    if (token == null) {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    } else {
      await UserService.fetchUserProfile();
      await TaskService.getTasks();
      Navigator.pushReplacementNamed(context, "/");
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
