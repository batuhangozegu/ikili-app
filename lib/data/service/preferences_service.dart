import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _lastRoomIdKey = 'last_room_id';

   Future<void> saveLastRoomId(String roomId) async {
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRoomIdKey, roomId);

   }

   Future<String?> getLastRoomId() async {

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastRoomIdKey);
   }

   Future<void> clearLastRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRoomIdKey);

   }



  // 1. Bir oda ID'sini kaydeden bir metot yaz: saveLastRoomId(String roomId)
  //    İpucu: SharedPreferences.getInstance() bir Future<SharedPreferences> döndürür,
  //    onu await'lemen lazım. Sonra prefs.setString(key, value) ile kaydedersin.

  // 2. Kaydedilen ID'yi okuyan bir metot yaz: getLastRoomId() -> Future<String?>
  //    İpucu: prefs.getString(key) kullan, bulunamazsa zaten otomatik null döner.

  // 3. Kaydı silen bir metot yaz: clearLastRoomId()
  //    İpucu: prefs.remove(key) kullan.
}