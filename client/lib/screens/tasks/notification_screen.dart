import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/widgets/widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> allTasks = [];
  List<Map<String, dynamic>> upcomingTasks = [];
  @override
  void initState() {
    super.initState();
    refreshTasks();
  }

  void refreshTasks() {
    setState(() {
      allTasks = List.from(TaskService.allTasks);
      upcomingTasks = TaskService.getImportantTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentPage: "notifications"),
      backgroundColor: const Color(0xffF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            // Top Container with menu button
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber,
                        ),
                        child: const Icon(Icons.menu, color: Colors.white),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFFFFC107),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, "/add-task").then((
                            updated,
                          ) {
                            if (updated == true) {
                              setState(() {
                                refreshTasks();
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Notification List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (upcomingTasks.isNotEmpty)
                    ...upcomingTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: NotificationTile(
                          task: task,
                          refreshTasks: refreshTasks,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "No notifications",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback refreshTasks;
  const NotificationTile({
    super.key,
    required this.task,
    required this.refreshTasks,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/task-details",
          arguments: task['id'],
        ).then((_) {
          refreshTasks();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // Clock Icon
            const CircleAvatar(
              backgroundColor: Color(0xff3F4A5A),
              child: Icon(Icons.access_time, color: Colors.white),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task["title"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(task["reason"], style: TextStyle(color: task["color"])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
