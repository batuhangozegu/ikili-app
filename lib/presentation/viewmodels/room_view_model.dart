import 'package:ikili_app/data/repositories/room_repository.dart';
import 'package:ikili_app/presentation/viewmodels/async_view_model.dart';

class RoomViewModel extends AsyncViewModel {
  final RoomRepository _roomRepository = RoomRepository();

  String? _createdRoomId;
  String? get createdRoomId => _createdRoomId;

  Future<void> createRoom(String creatorId) async {
    final roomId = await runAsync(
      () => _roomRepository.createRoom(creatorId),
      onError: (_) => 'Oda oluşturulurken bir hata oluştu',
    );
    if (roomId != null) _createdRoomId = roomId;
  }
}
