import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/widgets/widgets.dart';
import 'package:my_tasking/utils/validators.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreen();
}

class _DeleteAccountScreen extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isEmailValid = false;
  bool isPasswordValid = false;
  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void deleteAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final userData = UserService.userData;

    if (userData == null) {
      setState(() => isLoading = false);
      return;
    }
    Map<String, dynamic> result = await UserService.deleteUser({
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    });
    if (!result['success']) {
      setState(() => isLoading = false);
      AppToast.showError(context, result['message']);
      return;
    }
    setState(() => isLoading = false);
    AppToast.showSuccess(context, result['message']);
    await AuthService.logout();
    Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
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
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Delete Account",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3A4A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Deleting your account is permanent and cannot be undone.\nAll your data will be lost.\nAre you sure you want to proceed?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Email Label
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2F3A4A),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Email Field
                      AppTextField(
                        controller: emailController,
                        hint: "Enter Email",
                        validator: Validators.validateEmail,
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isEmailValid = valid);
                        },
                      ),

                      const SizedBox(height: 25),

                      // Password Label
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2F3A4A),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password Field
                      AppTextField(
                        controller: passwordController,
                        hint: "Enter Password",
                        obscureText: obscurePassword,
                        validator: Validators.validatePassword,
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isPasswordValid = valid);
                        },
                      ),

                      const SizedBox(height: 35),

                      // Delete Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed:
                              (isEmailValid && isPasswordValid && !isLoading)
                              ? () async {
                                  final confirm = await AppDialog.showConfirmDialog(
                                    context: context,
                                    title: "Delete Account",
                                    message:
                                        "Are you sure you want to permanently delete your account?",
                                  );

                                  if (confirm == true) {
                                    deleteAccount();
                                  }
                                }
                              : null,
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
                                  "Delete Account",
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
