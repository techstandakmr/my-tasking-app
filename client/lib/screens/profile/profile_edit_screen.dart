import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/utils/validators.dart';
import 'package:my_tasking/widgets/widgets.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final titleController = TextEditingController();
  final descController = TextEditingController();

  bool isNameValid = false;
  bool isEmailValid = false;
  bool isTitleValid = false;
  bool isDescValid = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final userData = UserService.userData;

    if (userData != null) {
      nameController.text = userData["name"] ?? "";
      emailController.text = userData["email"] ?? "";
      titleController.text = userData["title"] ?? "";
      descController.text = userData["description"] ?? "";

      // default value
      isNameValid = (userData["name"] ?? "").isNotEmpty;
      isEmailValid = (userData["email"] ?? "").isNotEmpty;
      isTitleValid = (userData["title"] ?? "").isNotEmpty;
      isDescValid = (userData["description"] ?? "").isNotEmpty;
      print("isTitleValid$isTitleValid");
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  void updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final userData = UserService.userData;

    if (userData == null) {
      setState(() => isLoading = false);
      return;
    }

    final Map<String, dynamic> fieldsData = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "title": titleController.text.trim(),
      "description": descController.text.trim(),
    };

    final Map<String, dynamic> updatingData = {};
    fieldsData.forEach((key, value) {
      if (value != userData[key] && value.isNotEmpty) {
        updatingData[key] = value;
      }
    });
    if (updatingData.isEmpty) {
      setState(() => isLoading = false);
      AppToast.showInfo(context, "No changes detected");
      return;
    }
    Map<String, dynamic> result = await UserService.updateUser(updatingData);
    if (!result['success']) {
      setState(() => isLoading = false);
      AppToast.showError(context, result['message']);
      return;
    }
    setState(() {
      isLoading = false;
    });
    AppToast.showSuccess(context, result['message']);
    Navigator.pop(context);
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
                width: 350,
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3A4A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Name
                      const Text("Name"),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: nameController,
                        hint: "Enter name",
                        validator: Validators.validateName,
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isNameValid = valid);
                        },
                        isDefaultValueValid: isNameValid,
                      ),

                      const SizedBox(height: 20),
                      const Text("Email"),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: emailController,
                        hint: "Enter email",
                        validator: Validators.validateEmail,
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isEmailValid = valid);
                        },
                        isDefaultValueValid: isEmailValid,
                      ),

                      const SizedBox(height: 20),

                      // Title
                      const Text("Title"),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: titleController,
                        hint: "Enter title",
                        validator: Validators.validateTitle,
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isTitleValid = valid);
                        },
                        isDefaultValueValid: isTitleValid,
                      ),

                      const SizedBox(height: 20),

                      // Description
                      const Text("Description"),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: descController,
                        hint: "Enter description",
                        validator: Validators.validateDescription,
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isDescValid = valid);
                        },
                        isDefaultValueValid: isDescValid,
                      ),

                      const SizedBox(height: 30),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Update",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
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
}
