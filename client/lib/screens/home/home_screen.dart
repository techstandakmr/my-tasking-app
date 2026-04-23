import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime today = DateTime.now();
  DateTime focusedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay, DateTime focusDay) {
    setState(() {
      today = selectedDay;
      focusedDay = focusDay;
    });
  }

  // status initials
  int pendingTask = 0;
  int startedTask = 0;
  int completedTask = 0;
  int overdueTask = 0;
  int total = 0;
  List<Map<String, dynamic>> allTasks = [];
  List<Map<String, dynamic>> upcomingTasks = [];
  @override
  void initState() {
    super.initState();
  }

  void calculateStats() {
    pendingTask = 0;
    startedTask = 0;
    completedTask = 0;
    overdueTask = 0;
    upcomingTasks.clear();
    allTasks = List.from(TaskService.allTasks);
    total = allTasks.length;

    DateTime now = DateTime.now();
    DateTime todayDate = DateTime(now.year, now.month, now.day);

    for (var task in allTasks) {
      DateTime dueRaw = DateTime.parse(task["due_date"]);
      DateTime due = DateTime(dueRaw.year, dueRaw.month, dueRaw.day);

      int difference = due.difference(todayDate).inDays;

      if (difference < 0) {
        overdueTask++;
      } else {
        switch (task["stage"]) {
          case "pending":
            pendingTask++;
            break;
          case "started":
            startedTask++;
            break;
          case "completed":
            completedTask++;
            break;
        }
      }

      if (difference <= 2 && difference >= 0 && upcomingTasks.length < 4) {
        upcomingTasks.add(task);
      }
    }
  }

  List<Map<String, dynamic>> getTasksForDay(DateTime day) {
    return allTasks.where((task) {
      DateTime due = DateTime.parse(task["due_date"]);
      return isSameDay(day, due);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    calculateStats();
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      drawer: const AppDrawer(currentPage: "home"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // top bar
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
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
                            Navigator.pushNamed(context, "/add-task").then((_) {
                              setState(() {
                                calculateStats();
                              });
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // status card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Status",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildProgress("Pending", pendingTask, total, Colors.amber),
                    _buildProgress(
                      "Started",
                      startedTask,
                      total,
                      Colors.deepOrange,
                    ),
                    _buildProgress(
                      "Completed",
                      completedTask,
                      total,
                      Colors.green,
                    ),
                    _buildProgress(
                      "Overdue Tasks",
                      overdueTask,
                      total,
                      Colors.red,
                    ),
                  ],
                ),
              ),

              // upcoming tasks
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Upcoming tasks",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 30),
                    Column(
                      children: [
                        if (upcomingTasks.isNotEmpty)
                          ...upcomingTasks.map(
                            (task) => InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  "/task-details",
                                  arguments: task['id'],
                                ).then((_) {
                                  calculateStats();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Text(
                                        task["title"],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Text(
                                      TaskService.formatDueDateWithColor(
                                        task["due_date"],
                                        task["stage"],
                                      )["text"],
                                      style: TextStyle(
                                        color:
                                            TaskService.formatDueDateWithColor(
                                              task["due_date"],
                                              task["stage"],
                                            )["color"],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Center(
                                  child: Text(
                                    "No upcoming tasks",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Center(
                                  child: Text(
                                    "You're all caught up!",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // calendar
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Calendar",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TableCalendar(
                      focusedDay: focusedDay,
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      selectedDayPredicate: (day) => isSameDay(today, day),
                      onDaySelected: _onDaySelected,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
                        markerDecoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFFFFC107),
                          shape: BoxShape.circle,
                        ),
                      ),
                      eventLoader: (day) {
                        return getTasksForDay(day);
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildSelectedDayTasks(),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // reusable card
  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  // progress bar widget
  Widget _buildProgress(String title, int value, int total, Color color) {
    double percent = total == 0 ? 0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), Text("$value/$total")],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: Colors.blueGrey.shade100,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSelectedDayTasks() {
    final tasks = getTasksForDay(today);

    if (tasks.isEmpty) {
      return const Text(
        "No tasks for this day",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: tasks.map((task) {
        final dueInfo = TaskService.formatDueDateWithColor(
          task["due_date"],
          task["stage"],
        );

        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/task-details",
              arguments: task['id'],
            ).then((_) {
              calculateStats();
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Dot indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dueInfo["color"],
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 10),

                // Title
                Expanded(
                  child: Text(
                    task["title"],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),

                // Date text
                Text(
                  dueInfo["text"],
                  style: TextStyle(
                    color: dueInfo["color"],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
