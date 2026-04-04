import 'services.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000/api";
  static Future<Map<String, String>> headers() async {
    final token = await AuthService.getToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static String extractError(dynamic data) {
    if (data["message"] != null) return data["message"];

    if (data["errors"] != null) {
      return data["errors"].values.first[0];
    }

    return "Something went wrong";
  }
}
