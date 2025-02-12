import 'package:reminds_flutter/src/models/appConfig.dart';

abstract class ApiServiceInterface {
  final String apiUrl;
  final String deviceId;

  Map<String, String> get _headers;

  // Private constructor
  ApiServiceInterface._(this.apiUrl, this.deviceId);

  Future<String> registerMedication();

  Future<AppConfig> getConfig();
}
