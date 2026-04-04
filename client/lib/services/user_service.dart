import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  static const storage = FlutterSecureStorage();
  static Map<String, dynamic>? userData;

  static Future<void> fetchUserProfile() async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/user"),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      UserService.userData = jsonDecode(response.body);
    } else {
      UserService.userData = {};
    }
  }

  static Future<Map<String, dynamic>> updateProfileImage(
    Map<String, dynamic> userData,
  ) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }

    final uri = Uri.parse("${ApiService.baseUrl}/user");

    final request = http.MultipartRequest("POST", uri);
    request.fields['_method'] = 'PATCH';

    // headers (without content-type)
    final headers = await ApiService.headers();
    headers.remove("Content-Type");
    request.headers.addAll(headers);

    // attach file
    request.files.add(
      await http.MultipartFile.fromPath('avatar', userData["avatar"].path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      UserService.userData = data['user'];
      return {
        "success": true,
        "message": data["message"] ?? "Profile updated successfully",
      };
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }

  static Future<Map<String, dynamic>> updateUser(
    Map<String, dynamic> userData,
  ) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.patch(
      Uri.parse("${ApiService.baseUrl}/user"),
      headers: await ApiService.headers(),
      body: jsonEncode(userData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      UserService.userData = data['user'];
      return {
        "success": true,
        "message": data["message"] ?? "Profile updated successfully",
      };
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }

  static Future<Map<String, dynamic>> updatePasswordByOld(
    Map<String, dynamic> passwordData,
  ) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/user/change-password-by-old"),
      headers: await ApiService.headers(),
      body: jsonEncode(passwordData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": data["message"] ?? "Password updated successfully",
      };
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }

  static Future<Map<String, dynamic>> sendOtp(
    Map<String, dynamic> userData,
  ) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/user/send-otp"),
      headers: await ApiService.headers(),
      body: jsonEncode(userData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": data["message"] ?? "OTP sent successfully",
      };
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(
    Map<String, dynamic> otpData,
  ) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/user/verify-otp"),
      headers: await ApiService.headers(),
      body: jsonEncode(otpData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {"success": true, "message": data["message"] ?? "OTP verified"};
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }

  static Future<Map<String, dynamic>> updatePasswordByOTP(
    Map<String, dynamic> passwordData,
  ) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/user/change-password-by-otp"),
      headers: await ApiService.headers(),
      body: jsonEncode(passwordData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": data["message"] ?? "Password reset successfully",
      };
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(userData) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.delete(
      Uri.parse("${ApiService.baseUrl}/user"),
      headers: await ApiService.headers(),
      body: jsonEncode(userData),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": data["message"] ?? "Account deleted successfully",
      };
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }
}
