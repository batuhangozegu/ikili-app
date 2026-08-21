import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
        );
        return credential.user;
    }on FirebaseAuthException catch (e){
      if(e.code == 'weak-password') {
        throw "Zayıf şifre";
      }else if (e.code == "email-already-in-use"){
        throw "Bu e-posta adresiyle ilişkili hesap zaten mevcut.";
      }else{
        throw "Kayıt sırasında bir hata oluştu";
      }
    }
  }

  Future<User?> signIn(String email, String password) async {
    try{
      final signInCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
        );
        return signInCredential.user;
    }on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found'){
        throw "Bu e-posta adresiyle ilişkili bir kullanıcı bulunamadı.";
      }else if (e.code == 'wrong-password'){
        throw "Parolanız veya emailiniz yanlış.";
      }else{
        throw "Giriş sırasında bir hata oluştu";
      }
    }
  }

  Future<User?> signInAnonymously() async {
    try{
    final signInAnonymouslyCredential = await _auth.signInAnonymously();
    return signInAnonymouslyCredential.user;
    }on FirebaseAuthException catch(e){
      throw "Giriş sırasında bir hata oluştu";
    }
  }
}