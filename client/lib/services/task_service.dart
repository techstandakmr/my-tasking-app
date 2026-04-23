import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services.dart';
import 'package:flutter/material.dart';

class TaskService {
  static List<Map<String, dynamic>> allTasks = [];
  static Future<void> getTasks() async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/tasks"),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      TaskService.allTasks = List<Map<String, dynamic>>.from(
        jsonDecode(response.body),
      );
    } else {
      TaskService.allTasks = [];
    }
  }

  static Map<String, dynamic> findTaskDetail(int taskID) {
    return TaskService.allTasks.firstWhere((task) => task["id"] == taskID);
  }

  static List<Map<String, dynamic>> getImportantTasks() {
    List<Map<String, dynamic>> importantTasks = [];

    List<Map<String, dynamic>> tasks = List.from(allTasks);

    DateTime now = DateTime.now();
    DateTime todayDate = DateTime(now.year, now.month, now.day);

    for (var task in tasks) {
      if (task["stage"] == "completed") continue;
      DateTime dueRaw = DateTime.parse(task["due_date"]);
      DateTime dueDate = DateTime(dueRaw.year, dueRaw.month, dueRaw.day);

      int difference = dueDate.difference(todayDate).inDays;

      //  Get formatted data (reuse your logic)
      final dueInfo = TaskService.formatDueDateWithColor(
        task["due_date"],
        task["stage"],
      );

      //  Overdue
      if (difference < 0) {
        importantTasks.add({
          ...task,
          "reason": "Overdue by ${difference.abs()} day(s)",
          "dueText": dueInfo["text"],
          "color": Colors.red,
        });
      }
      // Upcoming (Today, Tomorrow, In 2 days)
      else if (difference <= 2) {
        String message;

        if (difference == 0) {
          message = "Due today";
        } else if (difference == 1) {
          message = "Due tomorrow";
        } else {
          message = "Due in 2 days";
        }

        importantTasks.add({
          ...task,
          "reason": message,
          "dueText": dueInfo["text"],
          "color": dueInfo["color"],
        });
      }
    }

    return importantTasks;
  }

  static Map<String, dynamic> formatDueDateWithColor(
    String dueDateString,
    String? stage,
  ) {
    DateTime now = DateTime.now();
    DateTime todayDate = DateTime(now.year, now.month, now.day);

    DateTime dueRaw = DateTime.parse(dueDateString);
    DateTime dueDate = DateTime(dueRaw.year, dueRaw.month, dueRaw.day);

    int difference = dueDate.difference(todayDate).inDays;
    if (stage == "completed") {
      return {
        "text": DateFormat("dd MMM yyyy").format(dueDate),
        "color": Colors.green,
      };
    }
    if (difference < 0) {
      return {
        "text": "Overdue by ${difference.abs()} day(s)",
        "color": Colors.red,
      };
    }
    if (difference == 0) {
      return {"text": "Today", "color": Colors.red};
    }

    if (difference == 1) {
      return {"text": "Tomorrow", "color": Colors.orange};
    }

    if (difference == 2) {
      return {"text": "In 2 days", "color": Colors.orangeAccent};
    }

    return {
      "text": DateFormat("dd MMM yyyy").format(dueDate),
      "color": Colors.green,
    };
  }

  static Future<Map<String, dynamic>> createTask(
    Map<String, dynamic> taskData,
  ) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/tasks"),
      headers: await ApiService.headers(),
      body: jsonEncode(taskData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      TaskService.allTasks.add(data['task']);
      return {
        "success": true,
        "message": data["message"] ?? "Task created successfully",
      };
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }

  static Future<Map<String, dynamic>> updateTask(
    int id,
    Map<String, dynamic> taskData,
  ) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.patch(
      Uri.parse("${ApiService.baseUrl}/tasks/$id"),
      headers: await ApiService.headers(),
      body: jsonEncode(taskData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      int index = TaskService.allTasks.indexWhere((task) => task["id"] == id);
      if (index != -1) {
        TaskService.allTasks[index] = data["task"];
      }
      return {
        "success": true,
        "message": data["message"] ?? "Task updated successfully",
      };
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }

  static Future<Map<String, dynamic>> deleteTask(int id) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.delete(
      Uri.parse("${ApiService.baseUrl}/tasks/$id"),
      headers: await ApiService.headers(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      TaskService.allTasks.removeWhere((task) => task["id"] == id);
      return {
        "success": true,
        "message": data["message"] ?? "Task deleted successfully",
      };
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }
}
