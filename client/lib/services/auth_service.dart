import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const storage = FlutterSecureStorage();
  static Future<void> saveToken(String token) async {
    await storage.write(key: "token", value: token);
  }

  static Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  static Future<Map<String, dynamic>> logout() async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/auth/logout"),
      headers: await ApiService.headers(),
    );

    await storage.delete(key: "token");
    await storage.delete(key: "userData");
    UserService.userData = null;
    if (response.statusCode == 200) {
      return {"success": true, "message": "Logged out successfully"};
    } else {
      return {"success": false, "message": "Logout failed"};
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      if (!(await ConnectivityService.isOnline())) {
        return {"success": false, "message": "No internet connection"};
      }
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/auth/login"),
        headers: await ApiService.headers(),
        body: jsonEncode({"email": email, "password": password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await saveToken(data["access_token"]);
        return {
          "success": true,
          "message": data["message"] ?? "Login successful",
        };
      } else {
        return {"success": false, "message": ApiService.extractError(data)};
      }
    } catch (e) {
      return {"success": false, "message": "Network error"};
    }
  }

  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    if (!(await ConnectivityService.isOnline())) {
      return {"success": false, "message": "No internet connection"};
    }
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/auth/signup"),
      headers: await ApiService.headers(),
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await saveToken(data["access_token"]);
      return {
        "success": true,
        "message": data["message"] ?? "Registration successful",
      };
    } else {
      return {"success": false, "message": ApiService.extractError(data)};
    }
  }
}
