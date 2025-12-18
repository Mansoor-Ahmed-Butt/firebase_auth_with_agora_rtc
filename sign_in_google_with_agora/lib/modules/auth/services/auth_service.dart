import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

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

  ///  User this function for reset email password

  Future<void> forgetPassword({required String email}) async {
    return await _auth.sendPasswordResetEmail(email: email);
  }

  ////  Logout firebase
  Future<void> logoutAccount() async {
    return await _auth.signOut();
  }

  Future<Null> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the authentication details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Save user info to Firestore
      final uid = userCredential.user?.uid;
      debugPrint('Google Sign-In successful for UID: $uid');
      // if (uid != null) {
      //   await _firestore.collection('users').doc(uid).set({
      //     'uid': uid,
      //     'name': userCredential.user?.displayName,
      //     'email': userCredential.user?.email,
      //     'photoURL': userCredential.user?.photoURL,
      //     'lastSignIn': FieldValue.serverTimestamp(),
      //   }, SetOptions(merge: true));
      // }

      // return userCredential;

      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}, ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> signOutWithGoogle() async {
    await GoogleSignIn().signOut();
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
