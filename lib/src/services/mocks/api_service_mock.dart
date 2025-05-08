import 'package:reminds_flutter/src/interfaces/api_service_interface.dart';
import 'package:reminds_flutter/src/models/appConfig.dart';
import 'package:reminds_flutter/src/models/survey.dart';
import 'package:reminds_flutter/src/models/survey_submission.dart';
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
    const mockDeviceId = "fakeDeviceId";
    print("Mock Device ID: $mockDeviceId");
    return ApiServiceMock._(apiUrl, mockDeviceId);
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

  @override
  Future<Survey> getSurvey() async {
    return Survey(
      title: 'Test Survey',
      questions: [
        SurveyQuestion(
          id: '1',
          question: 'Test Question',
          options: ['Option 1', 'Option 2'],
        ),
      ],
      videoLink: 'https://example.com/video',
    );
  }

  @override
  Future<SurveySubmission> submitSurvey(SurveySubmission submission) async {
    return SurveySubmission(
      id: '123',
      answers: submission.answers,
      submittedAt: DateTime.now(),
    );
  }
}
