import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_tasking/services/services.dart';
import 'package:my_tasking/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  Map<String, dynamic>? userData;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() {
    setState(() {
      userData = UserService.userData;
    });
  }

  void uploadImage() async {
    if (_imageFile == null) return;
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> result = await UserService.updateProfileImage({
      "avatar": _imageFile,
    });
    if (!result['success']) {
      setState(() => isLoading = false);
      AppToast.showError(context, result['message']);
      return;
    }
    setState(() {
      isLoading = false;
    });
    loadUser();
    AppToast.showSuccess(context, result['message']);
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });

      uploadImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF2F3A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Profile Image
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFFFC107),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : NetworkImage(
                                      userData?["avatar"] ??
                                          "https://i.pravatar.cc/150?img=2",
                                    )
                                    as ImageProvider,
                        ),
                      ),

                      // loading overlay
                      if (isLoading)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),

                      // Camera Button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "${userData?["name"] ?? "User"}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F3A4A),
                    ),
                  ),
                ),
                // fileds
                const SizedBox(height: 20),
                ProfileField(
                  label: "Title",
                  value: userData?["title"] ?? "Title",
                ),
                const SizedBox(height: 15),
                ProfileField(
                  label: "Description",
                  value: userData?["description"] ?? "Description",
                ),
                const SizedBox(height: 15),
                ProfileField(
                  label: "Email",
                  value: userData?["email"] ?? "Email",
                ),
                const SizedBox(height: 25),

                ProfileButton(
                  text: "Edit Profile",
                  icon: Icons.edit,
                  onTap: () {
                    Navigator.pushNamed(context, "/edit-profile").then((
                      _,
                    ) async {
                      await UserService.fetchUserProfile();
                      setState(() {
                        userData = UserService.userData;
                      });
                    });
                  },
                ),

                ProfileButton(
                  text: "Reset Password",
                  icon: Icons.lock_reset,
                  onTap: () async {
                    Navigator.pushNamed(context, "/update-password");
                  },
                ),

                ProfileButton(
                  text: "Logout",
                  icon: Icons.logout,
                  onTap: () async {
                    Map<String, dynamic> result = await AuthService.logout();
                    if (!result['success']) {
                      AppToast.showError(context, result['message']);
                      return;
                    } else {
                      AppToast.showSuccess(context, result['message']);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/login",
                        (route) => false,
                      );
                    }
                  },
                ),

                ProfileButton(
                  text: "Delete Account",
                  icon: Icons.delete,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pushNamed(context, "/delete-account");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const ProfileButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFFFFC107),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 2,
        ),
      ),
    );
  }
}
