import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/widgets/widgets.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  String searchText = "";
  String? stageFilter;
  String? priorityFilter;
  List<Map<String, dynamic>> filteredTasks = [];
  @override
  void initState() {
    super.initState();
    filteredTasks = List.from(TaskService.allTasks);
  }

  void applyFilters() {
    List<Map<String, dynamic>> tasks = List.from(TaskService.allTasks);
    if (searchText.isNotEmpty) {
      tasks = tasks.where((task) {
        return task["title"].toLowerCase().contains(searchText.toLowerCase()) ||
            task["description"].toLowerCase().contains(
              searchText.toLowerCase(),
            ) ||
            task["stage"].toLowerCase().contains(searchText.toLowerCase()) ||
            task["due_date"].toLowerCase().contains(searchText.toLowerCase()) ||
            task["priority"].toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }
    if (stageFilter != null) {
      tasks = tasks.where((task) => task['stage'] == stageFilter).toList();
    }
    if (priorityFilter != null) {
      tasks = tasks
          .where((task) => task['priority'] == priorityFilter)
          .toList();
    }
    setState(() {
      filteredTasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("all tasks$filteredTasks");
    return Scaffold(
      drawer: const AppDrawer(currentPage: "my-tasks"),
      backgroundColor: const Color(0xffF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            // Top Menu Container
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
                          Navigator.pushNamed(context, "/add-task").then((_) {
                            applyFilters();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search + Filter
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        searchText = value;
                        applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: "Search tasks...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xffF1F3F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Filter Tasks",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),
                                DropdownButtonFormField<String>(
                                  initialValue: stageFilter,
                                  hint: const Text("Filter by Stage"),
                                  items: const [
                                    DropdownMenuItem(
                                      value: "pending",
                                      child: Text("Pending"),
                                    ),
                                    DropdownMenuItem(
                                      value: "started",
                                      child: Text("Started"),
                                    ),
                                    DropdownMenuItem(
                                      value: "completed",
                                      child: Text("Completed"),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    stageFilter = value;
                                  },
                                ),

                                const SizedBox(height: 10),

                                DropdownButtonFormField<String>(
                                  initialValue: priorityFilter,
                                  hint: const Text("Filter by Priority"),
                                  items: const [
                                    DropdownMenuItem(
                                      value: "High",
                                      child: Text("High"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Medium",
                                      child: Text("Medium"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Low",
                                      child: Text("Low"),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    priorityFilter = value;
                                  },
                                ),

                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        applyFilters();
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Apply Filters"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        searchText = "";
                                        stageFilter = null;
                                        priorityFilter = null;
                                        applyFilters();
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Clear Filters"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      "Filters",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Task List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (filteredTasks.isNotEmpty)
                    ...filteredTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: TaskCard(
                          showingType: "half",
                          title: task["title"],
                          description: task["description"],
                          dueDateString: task["due_date"],
                          stage: task["stage"],
                          priority: task["priority"],
                          onExplore: () {
                            Navigator.pushNamed(
                              context,
                              "/task-details",
                              arguments: task['id'],
                            ).then((_) {
                              applyFilters();
                            });
                          },
                          onEdit: () {
                            Navigator.pushNamed(
                              context,
                              "/edit-task",
                              arguments: task['id'],
                            ).then((_) {
                              applyFilters();
                            });
                          },
                          onDelete: () async {
                            final confirm = await AppDialog.showConfirmDialog(
                              context: context,
                              title: "Delete Task",
                              message:
                                  "Are you sure you want to delete this task?",
                            );

                            if (confirm == true) {
                              Map<String, dynamic> result =
                                  await TaskService.deleteTask(task["id"]);
                              if (!result['success']) {
                                AppToast.showSuccess(
                                  context,
                                  result['message'],
                                );
                              } else {
                                AppToast.showError(context, result['message']);
                              }
                              Navigator.pop(context); // close dialog
                              applyFilters();
                            }
                          },
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
                            "No upcoming tasks",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "You're all caught up!",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
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

class TaskCard extends StatelessWidget {
  final String showingType;
  final String title;
  final String description;
  final String dueDateString;
  final String stage;
  final String priority;
  final VoidCallback onExplore;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const TaskCard({
    super.key,
    required this.showingType,
    required this.title,
    required this.description,
    required this.dueDateString,
    required this.stage,
    required this.priority,
    required this.onExplore,
    required this.onEdit,
    required this.onDelete,
  });

  Color getStageColor() {
    switch (stage) {
      case "completed":
        return Colors.green;
      case "pending":
        return Colors.blue;
      case "started":
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  Color getPriorityColor() {
    switch (priority) {
      case "High":
        return Colors.red.shade100;
      case "Medium":
        return Colors.blue.shade100;
      case "Low":
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Map<String, dynamic>? alertMessage() {
    if (stage == "completed") return null;

    DateTime now = DateTime.now();
    DateTime todayDate = DateTime(now.year, now.month, now.day);

    DateTime dueRaw = DateTime.parse(dueDateString);
    DateTime dueDate = DateTime(dueRaw.year, dueRaw.month, dueRaw.day);

    int difference = dueDate.difference(todayDate).inDays;

    if (difference == 0) {
      return {"text": "Due today", "color": Colors.red};
    }

    if (difference == 1) {
      return {"text": "Due tomorrow", "color": Colors.orange};
    }

    if (difference == 2) {
      return {"text": "Due in 2 days", "color": Colors.orangeAccent};
    }

    return {
      "text": "Overdue by ${difference.abs()} day(s)",
      "color": Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Priority
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  softWrap: true,
                  maxLines: showingType == "full" ? null : 2,
                  overflow: showingType == "full"
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getPriorityColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(priority),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            description,
            softWrap: true,
            maxLines: showingType == "full" ? null : 2,
            overflow: showingType == "full"
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),

          if (alertMessage() != null) ...[
            const SizedBox(height: 6),
            Text(
              alertMessage()!['text'],
              style: TextStyle(
                color: alertMessage()!['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(text: "Stage: "),
                TextSpan(
                  text: stage,
                  style: TextStyle(
                    color: getStageColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Buttons
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showingType != "full")
                    InkWell(
                      onTap: onExplore,
                      child: const Row(
                        children: [
                          Icon(Icons.remove_red_eye, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Explore",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 20),

                  InkWell(
                    onTap: onEdit,
                    child: const Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Edit", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  InkWell(
                    onTap: onDelete,
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Delete", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
