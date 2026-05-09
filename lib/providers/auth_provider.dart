import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleInit;

  User? _user;
  String? _name;
  bool _isAdmin = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get email => _user?.email;
  String get displayName => _name ?? _user?.email?.split('@').first ?? 'Guest';

  AuthProvider() {
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _name = null;
        _isAdmin = false;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _name = doc.data()?['name'];
        _isAdmin = doc.data()?['isAdmin'] ?? false;
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        _error = 'Firestore permission denied. Please check your Firebase rules.';
      }
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = cred.user;
      if (_user != null) await _loadUserData(_user!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = cred.user;
      _name = name;
      // Save user profile in Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email.trim(),
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseException catch (e) {
      _error = e.code == 'permission-denied'
          ? 'Firestore permission denied. Please update Firestore rules.'
          : 'An internal database error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _googleInit ??= _googleSignIn.initialize();
      await _googleInit;
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      _user = userCred.user;

      if (_user != null) {
        final userDoc = _db.collection('users').doc(_user!.uid);
        final snapshot = await userDoc.get();
        if (!snapshot.exists) {
          await userDoc.set({
            'name': _user?.displayName ?? _user?.email?.split('@').first ?? '',
            'email': _user?.email ?? '',
            'isAdmin': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
          _name = _user?.displayName ?? _user?.email?.split('@').first;
        } else {
          _name = snapshot.data()?['name'];
          _isAdmin = snapshot.data()?['isAdmin'] ?? false;
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
    } on FirebaseException catch (e) {
      _error = e.code == 'permission-denied'
          ? 'Firestore permission denied. Please update Firestore rules.'
          : 'Google sign in failed. Please try again.';
    } catch (_) {
      _error = 'Google sign in failed. Please try again.';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProfile(String name, String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _db.collection('users').doc(_user!.uid).update({
        'name': name,
        'email': email.trim(),
      });
      _name = name;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _auth.signOut();
    _googleSignIn.signOut();
    _user = null;
    _name = null;
    _isAdmin = false;
    notifyListeners();
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
