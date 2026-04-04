import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/screens/screens.dart';
import 'package:my_tasking/widgets/widgets.dart';

class TaskDetailsScreen extends StatefulWidget {
  final dynamic arguments;
  const TaskDetailsScreen({super.key, this.arguments});
  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  Map<String, dynamic>? task;

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null && widget.arguments is int) {
      task = TaskService.findTaskDetail(widget.arguments);
    }
  }

  Future<void> deleteTask() async {
    Map<String, dynamic> result = await TaskService.deleteTask(task!["id"]);
    if (!result['success']) {
      AppToast.showError(context, result['message']);
    } else {
      AppToast.showSuccess(context, result['message']);
    }
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  void showDeleteDialog() async {
    final confirm = await AppDialog.showConfirmDialog(
      context: context,
      title: "Delete Task",
      message: "Are you sure you want to delete this task?",
    );

    if (confirm == true) {
      deleteTask();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: const Text("Task Details"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: TaskCard(
              showingType: "full",
              title: task!["title"],
              description: task!["description"],
              dueDateString: task!["due_date"],
              stage: task!["stage"],
              priority: task!["priority"],

              onExplore: () {},

              onEdit: () {
                Navigator.pushNamed(
                  context,
                  "/edit-task",
                  arguments: task!['id'],
                );
              },

              onDelete: showDeleteDialog,
            ),
          ),
        ),
      ),
    );
  }
}
