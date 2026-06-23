import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use pure HTTP context for the target environment
  static const String baseUrl = "http://136.119.231.2:5010"; 

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      body: {"username": username, "password": password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["access_token"]);
      await prefs.setString("role", data["role"]);
      return data;
    }
    return null;
  }

  static Future<Map<String, dynamic>> uploadAndInspect(String jobId, File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/jobs/inspect"));
    request.headers.addAll({"Authorization": "Bearer $token"});
    request.fields['job_id'] = jobId;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"status": "ERROR", "anomalies": [{"designator": "NETWORK", "type": "HTTP_FAIL", "details": response.body}]};
    }
  }
}
