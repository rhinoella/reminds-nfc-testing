import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminds_flutter/src/interfaces/api_service_interface.dart';
import 'package:reminds_flutter/src/models/survey.dart';
import 'package:reminds_flutter/src/models/survey_submission.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({Key? key}) : super(key: key);

  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late ApiServiceInterface apiService;
  Survey? survey;
  bool isLoading = true;

  // Video player controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Track the selected answers for each question
  Map<String, String> answers = {};

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiServiceInterface>(context, listen: false);
    _loadSurvey();
  }

  Future<void> _loadSurvey() async {
    try {
      final surveyData = await apiService.getSurvey();
      setState(() {
        survey = surveyData;
        isLoading = false;
      });

      // Initialize video player with the provided URL
      if (survey != null && survey!.videoLink.isNotEmpty) {
        _initializeVideoPlayer(survey!.videoLink);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading survey: $e");
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    _videoPlayerController = VideoPlayerController.network(videoUrl);

    _videoPlayerController!.initialize().then((_) {
      // Create ChewieController after the video is initialized
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error loading video: $errorMessage',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );

      // Force a rebuild to show the video player
      if (mounted) setState(() {});
    });
  }

  void _selectAnswer(String questionId, String answer) {
    setState(() {
      answers[questionId] = answer;
    });
  }

  Future<void> _submitSurvey() async {
    if (survey == null) return;

    // Check if all questions are answered
    bool allAnswered = true;
    for (var question in survey!.questions) {
      if (!answers.containsKey(question.id)) {
        allAnswered = false;
        break;
      }
    }

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    // Create list of SurveyAnswer objects
    List<SurveyAnswer> surveyAnswers = answers.entries.map((entry) {
      return SurveyAnswer(
        questionId: entry.key,
        answer: entry.value,
      );
    }).toList();

    // Create submission object
    SurveySubmission submission = SurveySubmission(
      id: '', // Will be assigned by the server
      answers: surveyAnswers,
      submittedAt: DateTime.now(),
    );

    try {
      await apiService.submitSurvey(submission);
      Navigator.pop(context); // Return to previous screen after submission
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting survey: $e')),
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Survey',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : survey == null
              ? const Center(child: Text('No survey available'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey!.title,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Video player section
                        if (_chewieController != null)
                          Container(
                            height: 200,
                            child: Chewie(
                              controller: _chewieController!,
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Survey questions
                        ...survey!.questions.map((question) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question.question,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              ...question.options.map((option) {
                                final bool isSelected =
                                    answers[question.id] == option;
                                return ListTile(
                                  title: Text(option),
                                  leading: Radio<String>(
                                    value: option,
                                    groupValue: answers[question.id],
                                    onChanged: (value) {
                                      if (value != null) {
                                        _selectAnswer(question.id, value);
                                      }
                                    },
                                  ),
                                  tileColor: isSelected
                                      ? Colors.purple.withOpacity(0.1)
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),

                        const SizedBox(height: 24),
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitSurvey,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
