import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/utils/validators.dart';
import 'package:my_tasking/widgets/widgets.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final categoryController = TextEditingController();
  DateTime? endDate;

  String? selectedStage;
  String? selectedPriority;

  bool isLoading = false;

  final List<String> stages = ["pending", "started", "completed"];
  final List<String> priorities = ["high", "medium", "low"];

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  Future<void> pickDate(bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void createTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (endDate == null) {
      AppToast.showError(context, "Please select end date");
      return;
    }

    setState(() => isLoading = true);
    final userData = UserService.userData;

    if (userData == null) {
      setState(() => isLoading = false);
      return;
    }
    Map<String, dynamic> result = await TaskService.createTask({
      "title": titleController.text,
      "description": descController.text,
      "due_date": endDate!.toIso8601String(),
      "stage": selectedStage,
      "priority": selectedPriority,
      "user_id": userData["id"],
    });
    if (!result['success']) {
      setState(() => isLoading = false);
      AppToast.showError(context, result['message']);
      return;
    }

    setState(() => isLoading = false);

    AppToast.showSuccess(context, result['message']);
    // Navigate to My Tasks after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushNamed(context, "/my-tasks");
    });
  }

  String formatDate(DateTime? date) {
    if (date == null) return "dd-mm-yyyy";
    return DateFormat("dd-MM-yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset("assets/logo3.png", width: 250),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "New Task",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3A4A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Title
                      const Text("Title"),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: titleController,
                        hint: "Title",
                        validator: Validators.validateTitle,
                        liveValidation: true,
                      ),

                      const SizedBox(height: 20),

                      // Description
                      const Text("Description"),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: descController,
                        hint: "Description",
                        validator: Validators.validateDescription,
                        liveValidation: true,
                      ),

                      const SizedBox(height: 20),

                      // Dates
                      GestureDetector(
                        onTap: () => pickDate(false),
                        child: _dateField("Due Date", endDate),
                      ),

                      const SizedBox(height: 20),

                      // Stage
                      const Text("Stage"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStage,
                        decoration: _inputDecoration("Select Stage"),
                        items: stages
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedStage = value),
                        validator: (value) =>
                            value == null ? "Select stage" : null,
                      ),

                      const SizedBox(height: 20),

                      // Priority
                      const Text("Priority"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPriority,
                        decoration: _inputDecoration("Select Priority"),
                        items: priorities
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedPriority = value),
                        validator: (value) =>
                            value == null ? "Select priority" : null,
                      ),

                      const SizedBox(height: 30),

                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : createTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 8,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Create Task",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Back
                      const SizedBox(height: 15),
                      if (!isLoading)
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              // backgroundColor: const Color(0xFFFFC107),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 8,
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                // color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField(String label, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDate(date)),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF4F4F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
