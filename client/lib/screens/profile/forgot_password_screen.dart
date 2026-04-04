import 'package:flutter/material.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/widgets/widgets.dart';
import 'package:my_tasking/utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int step = 1;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isEmailValid = false;
  bool isOtpValid = false;
  bool isPasswordValid = false;
  bool isLoading = false;
  bool obscurePassword = true;
  Map<String, dynamic>? userData;
  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() {
    setState(() {
      userData = UserService.userData;
      if (userData != null) {
        emailController.text = userData!['email'] ?? "";
      }
    });
  }

  void sendOtp() async {
    if ((userData == null && emailController.text.trim().isEmpty)) {
      AppToast.showError(context, "Please enter email");
      return;
    }
    setState(() => isLoading = true);
    String email = userData != null
        ? userData!['email']
        : emailController.text.trim();
    Map<String, dynamic> result = await UserService.sendOtp({"email": email});

    if (!result['success']) {
      setState(() => isLoading = false);
      AppToast.showError(context, result['message']);
      return;
    }
    setState(() {
      step = 2;
      isLoading = false;
    });
    AppToast.showInfo(context, result['message']);
  }

  void verifyOtp() async {
    setState(() => isLoading = true);

    Map<String, dynamic> result = await UserService.verifyOTP({
      "otp": otpController.text.trim(),
      "email": userData != null
          ? userData!['email']
          : emailController.text.trim(),
    });

    if (!result['success']) {
      setState(() => isLoading = false);
      AppToast.showError(context, result['message']);
      return;
    }
    setState(() {
      step = 3;
      isLoading = false;
    });
    AppToast.showInfo(context, result['message']);
  }

  void updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    Map<String, dynamic> result = await UserService.updatePasswordByOTP({
      "new_password": newPasswordController.text.trim(),
      "email": userData != null
          ? userData!['email']
          : emailController.text.trim(),
    });

    if (!result['success']) {
      setState(() => isLoading = false);
      AppToast.showError(context, result['message']);
      return;
    }
    setState(() {
      step = 3;
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
              child: Image.asset("assets/logo3.png", width: 280),
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
                          "Forgot password",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3A4A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (step == 1) ...[
                        if (userData == null) ...[
                          const Text("Email"),
                          const SizedBox(height: 8),
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
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed:
                                (!isLoading &&
                                    (userData != null || isEmailValid))
                                ? sendOtp
                                : null,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : const Text("Send OTP"),
                          ),
                        ),
                      ],
                      if (step == 2) ...[
                        AppTextField(
                          controller: otpController,
                          hint: "Enter OTP",
                          keyboardType: TextInputType.number,
                          liveValidation: true,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "OTP required";
                            if (value.length != 6)
                              return "OTP must be 6 digits";
                            return null;
                          },
                          onValidationChanged: (valid) {
                            setState(() => isOtpValid = valid);
                          },
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: (isOtpValid && !isLoading)
                              ? verifyOtp
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Verify OTP"),
                        ),
                      ],
                      if (step == 3) ...[
                        AppTextField(
                          controller: newPasswordController,
                          hint: "New Password",
                          obscureText: obscurePassword,
                          validator: Validators.validatePassword,
                          liveValidation: true,
                          onValidationChanged: (valid) {
                            setState(() => isPasswordValid = valid);
                          },
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: (isPasswordValid && !isLoading)
                              ? updatePassword
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Update Password"),
                        ),
                      ],
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
