import 'dart:async';

import 'package:ikili_app/data/service/auth_service.dart';
import 'package:ikili_app/presentation/viewmodels/async_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends AsyncViewModel {

  final AuthService _authService = AuthService();

  // Firebase'in mevcut/oturum durumunu dinler: login, signup, misafir girişi,
  // çıkış ve uygulama yeniden açıldığında hatırlanan oturum dahil her
  // durumda _currentUser'ı günceller. main.dart'taki AuthGate bunu izleyerek
  // Login/Home ekranı arasında otomatik geçiş yapar.
  late final StreamSubscription<User?> _authStateSub;

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Firebase henüz ilk oturum durumunu bildirmediyse true; AuthGate bu süre
  // boyunca Login ekranını erken göstermemek için bekleme ekranı gösterebilir.
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  AuthViewModel() {
    _authStateSub = _authService.authStateChanges.listen((user) {
      _currentUser = user;
      _isInitializing = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSub.cancel();
    super.dispose();
  }

  Future<void> signOut() => _authService.signOut();

  Future<void> signUp(String email, String password) async {
    final user = await runAsync(() => _authService.signUp(email, password));
    if (user != null) _currentUser = user;
  }

  Future<void> signIn(String email, String password) async {
    final user = await runAsync(() => _authService.signIn(email, password));
    if (user != null) _currentUser = user;
  }

  Future<void> signInAnonymously() async {
    final user = await runAsync(() => _authService.signInAnonymously());
    if (user != null) _currentUser = user;
  }
}
