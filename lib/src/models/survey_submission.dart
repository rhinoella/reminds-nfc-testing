class SurveySubmission {
  final String id;
  final List<SurveyAnswer> answers;
  final DateTime submittedAt;

  SurveySubmission({
    required this.id,
    required this.answers,
    required this.submittedAt,
  });

  factory SurveySubmission.fromJson(Map<String, dynamic> json) {
    return SurveySubmission(
      id: json['id'] as String,
      answers: (json['answers'] as List)
          .map((a) => SurveyAnswer.fromJson(a))
          .toList(),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class SurveyAnswer {
  final String questionId;
  final String answer;

  SurveyAnswer({
    required this.questionId,
    required this.answer,
  });

  factory SurveyAnswer.fromJson(Map<String, dynamic> json) {
    return SurveyAnswer(
      questionId: json['questionId'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
    };
  }
}
