import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ikili_app/data/models/question_model.dart';

/// `rooms/{roomId}/questions` alt koleksiyonu için CRUD.
class QuestionRepository {
  CollectionReference<Map<String, dynamic>> _questionsRef(String roomId) {
    return FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('questions');
  }

  Future<void> addQuestion({
    required String roomId,
    required QuestionType type,
    required String text,
    required String correctAnswer,
    required List<String> wrongOptions,
    required String createdBy,
  }) async {
    final docRef = _questionsRef(roomId).doc();
    final question = Question(
      id: docRef.id,
      text: text,
      type: type,
      correctAnswer: correctAnswer,
      wrongOptions: wrongOptions,
      createdBy: createdBy,
    );
    await docRef.set(question.toMap());
  }

  Future<void> deleteQuestion(String roomId, String questionId) {
    return _questionsRef(roomId).doc(questionId).delete();
  }

  Stream<List<Question>> watchQuestions(String roomId) {
    return _questionsRef(roomId).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Question.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<List<Question>> fetchQuestions(String roomId) async {
    final snapshot = await _questionsRef(roomId).get();
    return snapshot.docs
        .map((doc) => Question.fromMap(doc.id, doc.data()))
        .toList();
  }
}
