import 'package:flutter/material.dart';
import 'package:ikili_app/data/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {

  final AuthService _authService = AuthService();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> signUp(String email,String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      _currentUser = await _authService.signUp(email, password);
    }catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email,String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(email, password);
    }catch(e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInAnonymously() async {

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      _currentUser = await _authService.signInAnonymously();
    }catch(e){
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();

  }


}