import 'package:reminds_flutter/src/models/appConfig.dart';
import 'package:reminds_flutter/src/models/survey.dart';
import 'package:reminds_flutter/src/models/survey_submission.dart';
import 'dart:typed_data';

abstract class ApiServiceInterface {
  final String apiUrl;
  final String deviceId;

  Map<String, String> get _headers;

  // Private constructor
  ApiServiceInterface._(this.apiUrl, this.deviceId);

  Future<int> registerMedication();

  Future<AppConfig> getConfig();

  Future<bool> returnMedication(int medicationId, Uint8List sensorData);

  Future<Survey> getSurvey();

  Future<SurveySubmission> submitSurvey(SurveySubmission submission);
}
