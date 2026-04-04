import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/widgets/widgets.dart';
import 'package:my_tasking/utils/validators.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isCurrentPasswordValid = false;
  bool isNewPasswordValid = false;
  bool isLoading = false;
  bool obscureCurrentPassword = true;
  bool obscurePassword = true;
  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  void updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    String currentPassword = currentPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    setState(() => isLoading = true);

    Map<String, dynamic> result = await UserService.updatePasswordByOld({
      "current_password": currentPassword,
      "new_password": newPassword,
    });
    if (!result['success']) {
      setState(() => isLoading = false);
      AppToast.showError(context, result['message']);
      return;
    }
    setState(() {
      isLoading = false;
    });
    AppToast.showSuccess(context, result['message']);
    await AuthService.logout();
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
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
                          "Update Password",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3A4A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Current password Label
                      const Text(
                        "Current Password",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2F3A4A),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Current Password Field
                      AppTextField(
                        controller: currentPasswordController,
                        hint: "Current Password",
                        obscureText: obscureCurrentPassword,
                        validator: Validators.validatePassword,
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isCurrentPasswordValid = valid);
                        },
                      ),

                      const SizedBox(height: 25),

                      // Password Label
                      const Text(
                        "New Password",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2F3A4A),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password Field
                      AppTextField(
                        controller: newPasswordController,
                        hint: "New Password",
                        obscureText: obscurePassword,
                        validator: Validators.validatePassword,
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isNewPasswordValid = valid);
                        },
                      ),

                      const SizedBox(height: 35),

                      // update Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed:
                              (isCurrentPasswordValid &&
                                  isNewPasswordValid &&
                                  !isLoading)
                              ? updatePassword
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
                                  "Update Password",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // cancel button
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

                      const SizedBox(height: 25),

                      // Forgot Password
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Forgot ",
                              style: TextStyle(
                                color: Color(0xFF2F3A4A),
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/forgot-password",
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero, // removes extra space
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Password?",
                                style: TextStyle(
                                  color: Color(0xFFFFA000),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
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
