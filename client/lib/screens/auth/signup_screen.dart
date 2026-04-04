import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/widgets/widgets.dart';
import 'package:my_tasking/utils/validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isNameValid = false;
  bool isEmailValid = false;
  bool isPasswordValid = false;
  bool isConfirmPasswordValid = false;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    Map<String, dynamic> result = await AuthService.signup(
      nameController.text,
      emailController.text,
      passwordController.text,
    );
    if (!result['success']) {
      setState(() => isLoading = false);
      AppToast.showError(context, result['message']);
      return;
    }
    await UserService.fetchUserProfile();
    AppToast.showSuccess(context, result["message"]);
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(context, "/");
    });
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
              child: Image.asset("assets/logo2.png", width: 250),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3A4A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      const Text(
                        "Name",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2F3A4A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppTextField(
                        controller: nameController,
                        hint: "Enter your name",
                        validator: Validators.validateName,
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isNameValid = valid);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Email
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2F3A4A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppTextField(
                        controller: emailController,
                        hint: "Enter Email",
                        validator: Validators.validateEmail,
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isEmailValid = valid);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2F3A4A),
                        ),
                      ),
                      const SizedBox(height: 6),
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

                      const SizedBox(height: 20),

                      // Confirm Password
                      const Text(
                        "Confirm Password",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2F3A4A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppTextField(
                        controller: confirmPasswordController,
                        hint: "Confirm Password",
                        obscureText: obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm password";
                          }
                          if (value != passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                        liveValidation: true,
                        onValidationChanged: (valid) {
                          setState(() => isConfirmPasswordValid = valid);
                        },
                      ),

                      const SizedBox(height: 35),

                      // signup Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed:
                              (isNameValid &&
                                  isEmailValid &&
                                  isPasswordValid &&
                                  isConfirmPasswordValid &&
                                  !isLoading)
                              ? signup
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
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // have account?
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Already have an account?  ",
                              style: TextStyle(
                                color: Color(0xFF2F3A4A),
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/login");
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero, // removes extra space
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Login",
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
