enum RoomStatus { waiting, active, finished, cancelled }

class Room {
  final String id;
  final String code;
  final String creatorId;
  final String? opponentId;
  final RoomStatus status;
  final DateTime createdAt;
  // Oda sahibi "Turu Başlat"a bastığında true olur; rakip tarafı bunu
  // dinleyip otomatik Quiz ekranına geçer.
  final bool roundStarted;

  // Tur bittiğinde doldurulan alanlar (ResultScreen -> RoomRepository.finishRoom).
  final int? score;
  final int? totalQuestions;
  final DateTime? finishedAt;
  // Her biri {questionText, correctAnswer, givenAnswer, isCorrect} taşıyan,
  // sonuç ekranında hesaplanmış cevap dökümü (Tur Detayı bunu okur).
  final List<Map<String, dynamic>>? answers;

  Room({
    required this.id,
    required this.code,
    required this.creatorId,
    this.opponentId,
    required this.status,
    required this.createdAt,
    this.roundStarted = false,
    this.score,
    this.totalQuestions,
    this.finishedAt,
    this.answers,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'creatorId': creatorId,
      'opponentId': opponentId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'roundStarted': roundStarted,
      if (score != null) 'score': score,
      if (totalQuestions != null) 'totalQuestions': totalQuestions,
      if (finishedAt != null) 'finishedAt': finishedAt!.toIso8601String(),
      if (answers != null) 'answers': answers,
    };
  }

  factory Room.fromMap(String id, Map<String, dynamic> map) {
    return Room(
      id: id,
      code: map['code'],
      creatorId: map['creatorId'],
      opponentId: map['opponentId'],
      status: RoomStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['createdAt']),
      roundStarted: map['roundStarted'] as bool? ?? false,
      score: map['score'] as int?,
      totalQuestions: map['totalQuestions'] as int?,
      finishedAt: map['finishedAt'] != null
          ? DateTime.parse(map['finishedAt'] as String)
          : null,
      answers: map['answers'] != null
          ? List<Map<String, dynamic>>.from(
              (map['answers'] as List).map((e) => Map<String, dynamic>.from(e)),
            )
          : null,
    );
  }
}
