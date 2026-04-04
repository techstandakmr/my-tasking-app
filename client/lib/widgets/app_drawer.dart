import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/widgets/widgets.dart';

class AppDrawer extends StatefulWidget {
  final String currentPage;
  const AppDrawer({super.key, required this.currentPage});
  @override
  State<AppDrawer> createState() => _AppDrawerScreen();
}

class _AppDrawerScreen extends State<AppDrawer> {
  int importantTaskCount = 0;
  @override
  void initState() {
    super.initState();
    calculateStats();
  }

  void calculateStats() {
    setState(() {
      importantTaskCount = TaskService.getImportantTasks().length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          DrawerHeader(
            child: Stack(
              children: [
                //Background Logo
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.18,
                    child: Image.asset("assets/logo3.png", fit: BoxFit.cover),
                  ),
                ),

                // Centered Content
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_box, size: 36, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "MY TASKING",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pushNamed(context, "/");
            },
          ),
          // My Tasks
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("My Tasks"),
            onTap: () {
              Navigator.pushNamed(context, "/my-tasks");
            },
          ),

          // Notification
          ListTile(
            leading: Stack(
              children: [
                const Icon(Icons.notifications, size: 28),

                if (importantTaskCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        importantTaskCount > 99
                            ? "99+"
                            : importantTaskCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),

            title: const Text("Notifications"),

            onTap: () {
              Navigator.pushNamed(context, "/notifications");
            },
          ),

          const Spacer(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              Map<String, dynamic> result = await AuthService.logout();
              if (!result['success']) {
                AppToast.showError(context, result['message']);
                return;
              } else {
                AppToast.showSuccess(context, result['message']);
                Scaffold.of(context).closeDrawer();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (route) => false,
                );
              }
            },
          ),

          // profile
          ListTile(
            leading: const Icon(Icons.person_sharp),
            title: const Text("Profile"),
            onTap: () {
              Scaffold.of(context).closeDrawer();
              Navigator.pushNamed(context, "/profile");
            },
          ),
        ],
      ),
    );
  }
}
