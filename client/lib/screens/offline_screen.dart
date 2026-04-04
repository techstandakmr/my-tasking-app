import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png", height: 100),

            const SizedBox(height: 20),

            const Text(
              "No Internet Connection",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Please check your connection",
              style: TextStyle(color: Colors.grey),
            ),
            ElevatedButton(
              onPressed: () async {
                final online = await ConnectivityService.isOnline();
                if (online) {
                  Navigator.pushReplacementNamed(context, "/");
                }
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
