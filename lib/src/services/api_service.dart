import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:reminds_flutter/config.dart';
import 'package:reminds_flutter/src/interfaces/api_service_interface.dart';
import 'package:reminds_flutter/src/models/appConfig.dart';

class ApiService implements ApiServiceInterface {
  final String apiUrl;
  final String deviceId;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json', // Set content type as JSON
        'Authorization': 'Id $deviceId',
      };

  // Private constructor
  ApiService._(this.apiUrl, this.deviceId);

  // Factory method to create an instance of ApiService
  static Future<ApiService> create(String apiUrl) async {
    final deviceId = await _getDeviceId();
    return ApiService._(apiUrl, deviceId);
  }

  // Helper function to get device ID based on platform
  static Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Unique ID for Android device
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.identifierForVendor == null) {
        throw Exception("No id Found");
      }
      return iosInfo.identifierForVendor!; // Unique ID for iOS device
    } else {
      throw Exception('Unsupported platform');
    }
  }

  Future<String> registerMedication() async {
    if (mode == 'dev') {
      return "1234";
    }

    try {
      // Sending POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: _headers,
      );

      // Check if the response status code is 200
      if (response.statusCode == 200) {
        // If response is 200, return true
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        return jsonResponse['id'];
      } else {
        // If not 200, print the response and return false
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors during the request
      throw Exception('Error occurred: $e');
    }
  }

  Future<AppConfig> getConfig() async {
    if (mode == "dev") {
      return AppConfig.dev();
    }

    // Sending POST request
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: _headers,
    );

    // Check if the response status code is 200
    if (response.statusCode == 200) {
      // If the response is successful, parse it as JSON
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Convert the JSON response into the AppConfig model
      AppConfig config = AppConfig.fromJson(jsonResponse);

      return config;
    } else {
      print('Request failed with status: ${response.statusCode}');
      throw Exception('Failed to load config');
    }
  }
}
