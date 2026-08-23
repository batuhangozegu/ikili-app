enum RoomStatus { waiting, active, finished, cancelled }

class Room {
  final String id;
  final String code;
  final String creatorId;
  final String? opponentId;
  final RoomStatus status;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.code,
    required this.creatorId,
    this.opponentId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'creatorId': creatorId,
      'opponentId': opponentId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
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
    );
  }
}