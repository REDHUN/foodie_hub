import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:foodiehub/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider() {
    _user = _authService.currentUser;
    _authSubscription = _authService.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<User?> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _authService.signInWithEmailAndPassword(email, password);
      _errorMessage = null;
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> signUp(String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _authService.createUserWithEmailAndPassword(email, password);
      _errorMessage = null;
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

