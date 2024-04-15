import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      // Obtain the authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential using the Google tokens
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } catch (error) {
      throw FirebaseAuthException(
        code: 'ERROR_GOOGLE_SIGN_IN_FAILED',
        message: 'Google sign-in failed: $error',
      );
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
