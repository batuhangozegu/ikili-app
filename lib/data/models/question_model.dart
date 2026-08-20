enum QuestionType { multipleChoice, freeText }

class Question{
  final String id;
  final String text;
  final QuestionType type;
  final String correctAnswer;
  final List<String> wrongOptions;
  final String createdBy;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.correctAnswer,
    required this.wrongOptions,
    required this.createdBy,
  });

  Map<String,dynamic> toMap() {
    return {
      'text' : text,
      'type' : type.name,
      'correctAnswer' : correctAnswer,
      'wrongOptions' : wrongOptions,
      'createdBy' : createdBy
    };
  }

  factory Question.fromMap(String id, Map<String,dynamic> map) {

    final questionType = QuestionType.values.firstWhere(
    (e) => e.name == map['type'],
    );

    return Question(
      id: id,
      text: map['text'],
      type: questionType,
      correctAnswer: map['correctAnswer'],
      wrongOptions: List<String>.from(map['wrongOptions']),
      createdBy: map['createdBy']
      );
  }

}