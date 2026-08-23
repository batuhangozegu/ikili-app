import 'package:flutter/material.dart';
import 'package:ikili_app/data/repositories/room_repository.dart';

class RoomViewModel extends ChangeNotifier {
  final RoomRepository _roomRepository = RoomRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _createdRoomId;
  String? get createdRoomId => _createdRoomId;

  Future<void> createRoom(String creatorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      _createdRoomId = await _roomRepository.createRoom(creatorId);
    }catch(e){
      _errorMessage = 'Oda oluşturulurken bir hata oluştu';
    }

    _isLoading = false;
    notifyListeners();
  }
}