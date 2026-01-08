import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Create the instance (This is the unnamed constructor)
      final GoogleSignIn googleSignIn = GoogleSignIn(); 

      // 2. Trigger the dialog
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled
      }

      // 3. Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 4. Create credential (accessToken is back in v6.2.1!)
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Sign in
      return await FirebaseAuth.instance.signInWithCredential(credential);
      
    } catch (e) {
      print("Error logging in with Google: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}