import 'package:reminds_flutter/src/interfaces/api_service_interface.dart';
import 'package:reminds_flutter/src/models/appConfig.dart';
import 'dart:typed_data';

class ApiServiceMock implements ApiServiceInterface {
  final String apiUrl;
  final String deviceId;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json', // Set content type as JSON
        'Authorization': 'Id $deviceId',
      };

  // Private constructor
  ApiServiceMock._(this.apiUrl, this.deviceId);

  // Factory method to create an instance of ApiService
  static Future<ApiServiceMock> create(String apiUrl) async {
    return ApiServiceMock._(apiUrl, "fakeDeviceId");
  }

  Future<int> registerMedication() async {
    return 1234;
  }

  Future<AppConfig> getConfig() async {
    return AppConfig.dev();
  }

  Future<bool> returnMedication(int medicationId, Uint8List sensorData) async {
    return true;
  }
}
