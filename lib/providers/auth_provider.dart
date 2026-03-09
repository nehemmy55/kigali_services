import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  UserModel? _userProfile;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _init();
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  UserModel? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get currentUid => _firebaseUser?.uid;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------
  void _init() {
    _authSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (e) {
        // Handle auth state errors gracefully
        _status = AuthStatus.authenticated;
        _userProfile = null;
        notifyListeners();
      },
    );
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _userProfile = null;
    } else {
      _status = AuthStatus.authenticated;
      // Load profile in background - don't crash if it fails
      try {
        _userProfile = await _authService.getUserProfile(user.uid);
      } catch (e) {
        // Profile fetch failed - continue without profile
        _userProfile = null;
      }
    }
    notifyListeners();
  }

  /// Reload the Firebase user to sync emailVerified status.
  Future<void> checkEmailVerification() async {
    try {
      _errorMessage = null;
      await _authService.reloadUser();
      _firebaseUser = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      _errorMessage =
          'Failed to refresh verification status. Please check your internet and try again.';
      notifyListeners();
    }
  }

  /// Send verification email manually.
  Future<void> resendVerificationEmail() async {
    try {
      _errorMessage = null;
      await _authService.sendEmailVerification();
    } catch (e) {
      _errorMessage =
          'Too many requests. Please wait a few minutes before trying again.';
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Auth operations
  // ---------------------------------------------------------------------------
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading();
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      // State will update via stream
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading();
    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/Password authentication is not enabled in Firebase Console.';
      case 'unauthorized-domain':
        return 'This domain is not authorized. Add "localhost" and "127.0.0.1" to Firebase Authentication settings.';
      case 'api-not-activated':
        return 'Google Maps API is not activated. Please enable it in Google Cloud Console.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
