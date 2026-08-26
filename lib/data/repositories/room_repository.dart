import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ikili_app/data/models/room_model.dart';

class RoomRepository {
  final CollectionReference _roomsRef= FirebaseFirestore.instance.collection("rooms");

    Future<String> _generateUniqueRoomCode() async {
      String code;
      bool exists;

      do{
        final random = Random().nextInt(10000);
        code = random.toString().padLeft(4,'0');

        final existing = await _roomsRef
        .where('code', isEqualTo: code)
        .where('status', isEqualTo: RoomStatus.waiting.name)
        .limit(1)
        .get();
        
        exists = existing.docs.isNotEmpty;
      }while(exists);

      return code;
    }

    Future<String> createRoom(String creatorId) async {
      final code = await _generateUniqueRoomCode();

      final docRef = await _roomsRef.add({
        'code' : code,
        'creatorId' : creatorId,
        'opponentId' : null,
        'status' : RoomStatus.waiting.name,
        'createdAt' : DateTime.now().toIso8601String(),
      });

      return docRef.id;
    }

    Stream<Room> watchRoom(String roomId) {
      return _roomsRef.doc(roomId).snapshots().map(
        (snapshot) => Room.fromMap(snapshot.id, snapshot.data() as Map<String, dynamic>),
      );
    }

    Future<void> closeRoom(String roomId) async {
      try {
        await _roomsRef.doc(roomId).update({'status': RoomStatus.cancelled.name});
      } catch (_) {
      }
    }

    Future<void> startRound(String roomId) async {
      await _roomsRef.doc(roomId).update({'roundStarted': true});
    }

    Future<void> finishRoom(
      String roomId, {
      required int score,
      required int totalQuestions,
      required List<Map<String, dynamic>> answers,
    }) async {
      await _roomsRef.doc(roomId).update({
        'status': RoomStatus.finished.name,
        'score': score,
        'totalQuestions': totalQuestions,
        'answers': answers,
        'finishedAt': DateTime.now().toIso8601String(),
      });
    }

    /// Kullanıcının (oluşturan ya da katılan olarak) yer aldığı, bitmiş
    /// turları döner. Sıralama Firestore tarafında değil, client'ta yapılır;
    /// böylece composite index gerektirmez.
    Stream<List<Room>> watchFinishedRooms(String userId) {
      return _roomsRef
          .where(
            Filter.or(
              Filter('creatorId', isEqualTo: userId),
              Filter('opponentId', isEqualTo: userId),
            ),
          )
          .where('status', isEqualTo: RoomStatus.finished.name)
          .snapshots()
          .map((snapshot) {
            final rooms = snapshot.docs
                .map((doc) =>
                    Room.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                .toList();
            rooms.sort((a, b) {
              final aDate = a.finishedAt ?? a.createdAt;
              final bDate = b.finishedAt ?? b.createdAt;
              return bDate.compareTo(aDate);
            });
            return rooms;
          });
    }

    Future<Room?> joinRoom(String code, String opponentId) async {
      final query = await _roomsRef
            .where('code', isEqualTo: code)
            .where('status', isEqualTo: RoomStatus.waiting.name)
            .limit(1)
            .get();

            if(query.docs.isEmpty){
              throw 'Böyle bir oda yok ya da süresi doldu.';
            }

            final doc = query.docs.first;

            await doc.reference.update({
              'opponentId': opponentId,
              'status' : RoomStatus.active.name,
            });

            return Room.fromMap(doc.id, {
              ...doc.data() as Map<String, dynamic>,
              'opponentId': opponentId,
              'status': RoomStatus.active.name,
            });
    }

}