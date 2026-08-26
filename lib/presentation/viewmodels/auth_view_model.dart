import 'dart:async';

import 'package:ikili_app/data/models/app_user_model.dart';
import 'package:ikili_app/data/repositories/user_repository.dart';
import 'package:ikili_app/data/service/auth_service.dart';
import 'package:ikili_app/presentation/viewmodels/async_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends AsyncViewModel {

  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

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
    if (user != null) {
      _currentUser = user;
      await _upsertProfile(user, isGuest: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    final user = await runAsync(() => _authService.signIn(email, password));
    if (user != null) {
      _currentUser = user;
      await _upsertProfile(user, isGuest: false);
    }
  }

  Future<void> signInAnonymously() async {
    final user = await runAsync(() => _authService.signInAnonymously());
    if (user != null) {
      _currentUser = user;
      await _upsertProfile(user, isGuest: true);
    }
  }

  /// Kayıt/giriş sonrası `users/{uid}` dokümanını yazar. displayName şimdilik
  /// e-postanın @ öncesi kısmından türetiliyor (login ekranında ayrı bir
  /// "isim" alanı yok); misafirler için sabit "Misafir" kullanılıyor.
  Future<void> _upsertProfile(User user, {required bool isGuest}) async {
    final email = user.email ?? '';

    try {
      // Kullanıcı Profil ekranından ismini değiştirmiş olabilir; her
      // girişte varsayılan isimle ezmemek için var olanı koru.
      final existing = await _userRepository.fetchUser(user.uid);
      final displayName = existing?.displayName ??
          (isGuest
              ? 'Misafir'
              : (email.contains('@') ? email.split('@').first : email));

      await _userRepository.upsertUser(
        AppUser(
          id: user.uid,
          email: email,
          displayName: displayName,
          isGuest: isGuest,
        ),
      );
    } catch (_) {
      // Profil yazımı başarısız olsa bile giriş akışını bozma; History/Profile
      // ekranları isim bulunamazsa zaten yedek metin gösteriyor.
    }
  }
}
