import 'package:flutter/material.dart';

/// [AuthViewModel] ve [RoomViewModel] gibi Firebase çağrısı yapan
/// ViewModel'lerde tekrar eden "isLoading aç/kapat + hata yakala +
/// notifyListeners" iskeletini tek yerde toplar. Alt sınıflar asıl işlemi
/// sadece [runAsync] ile sarmalar.
abstract class AsyncViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// [action]'ı çalıştırırken isLoading/errorMessage state'ini yönetir.
  /// Başarılı olursa sonucu döner; hata olursa null döner ve
  /// [errorMessage]'ı doldurur ([onError] verilmezse hatanın kendisi
  /// (`toString`) kullanılır). Çağıran taraf, önceki state'i hatada
  /// ezmemek için dönen değeri null kontrolüyle atamalıdır.
  @protected
  Future<T?> runAsync<T>(
    Future<T> Function() action, {
    String Function(Object error)? onError,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    T? result;
    try {
      result = await action();
    } catch (e) {
      _errorMessage = onError != null ? onError(e) : e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
