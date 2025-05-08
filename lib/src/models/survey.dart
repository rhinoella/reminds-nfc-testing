class Survey {
  final String title;
  final List<SurveyQuestion> questions;
  final String videoLink;

  Survey({
    required this.title,
    required this.questions,
    required this.videoLink,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      title: json['title'] as String,
      questions: (json['questions'] as List)
          .map((q) => SurveyQuestion.fromJson(q))
          .toList(),
      videoLink: json['videoLink'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'questions': questions.map((q) => q.toJson()).toList(),
      'videoLink': videoLink,
    };
  }
}

class SurveyQuestion {
  final String id;
  final String question;
  final List<String> options;

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List).map((o) => o as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
    };
  }
}
