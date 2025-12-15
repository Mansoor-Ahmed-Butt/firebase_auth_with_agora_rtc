import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signUpWithEmail({required String name, required String email, required String password}) async {
    final userCred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = userCred.user?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).set({'uid': uid, 'name': name, 'email': email, 'createdAt': FieldValue.serverTimestamp()});
    }
    return userCred;
  }

  Future<UserCredential> signInWithEmail({required String email, required String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Log for debugging and rethrow so callers can handle it
      // ignore: avoid_print
      print('AuthService.signInWithEmail FirebaseAuthException: code=${e.code}, message=${e.message}');
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('AuthService.signInWithEmail unexpected error: $e');
      rethrow;
    }
  }

  // Future<List<String>> fetchSignInMethodsForEmail(String email) async {

  //   try {
  //     final methods = await _auth.fetchSignInMethodsForEmail(email: email);
  //     return methods;
  //   } on FirebaseAuthException catch (e) {
  //     // ignore: avoid_print
  //     print('AuthService.fetchSignInMethodsForEmail FirebaseAuthException: code=${e.code}, message=${e.message}');
  //     rethrow;
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print('AuthService.fetchSignInMethodsForEmail unexpected error: $e');
  //     rethrow;
  //   }
  // }
}
