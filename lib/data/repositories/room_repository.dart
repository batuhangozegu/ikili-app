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

    /// Kullanıcı hâlâ rakip beklerken (opponentId boşken) odadan ayrılırsa
    /// (uygulamayı kapatma, geri gitme) odayı 'cancelled' yapar; böylece
    /// Firestore'da sahipsiz "waiting" odalar birikmez. Rakip zaten katıldıysa
    /// çağrılmamalı.
    Future<void> closeRoom(String roomId) async {
      try {
        await _roomsRef.doc(roomId).update({'status': RoomStatus.cancelled.name});
      } catch (_) {
        // Ekran kapanırken/arka planda çağrıldığı için başarısız olursa
        // (ör. doküman zaten silinmiş, bağlantı yok) sessizce yut.
      }
    }

}