import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/function_utilities.dart';
import 'package:know_better/views/static/splash.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();
  // ignore: unused_field
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // GET UID
  Future<String> getCurrentUID() async {
    return (_firebaseAuth.currentUser)!.uid;
  }

  // GET CURRENT USER
  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<UserData> getUserData() async {
    final user = await FirestoreDatabase().getUser();
    final json = user.data()! as Map<String, dynamic>;
    final userData = UserData.fromJson(json: json);
    return userData;
  }

  // Future<String> getCurrentUserEmail() async {
  //   User user = await getCurrentUser();
  //   return user.email!;
  // }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(
          color: Colors.redAccent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    User? user;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        storeTokenAndData(userCredential);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            AuthServices.customSnackBar(
              content:
                  'The account already exists with a different credential.',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            AuthServices.customSnackBar(
              content: 'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          AuthServices.customSnackBar(
            content: 'Error occurred using Google Sign-In. Try again.',
          ),
        );
      }
    }
    return user;
  }

  Future<void> storeTokenAndData(UserCredential userCredential) async {
    await storage.write(
      key: 'token',
      value: userCredential.credential!.token.toString(),
    );
    await storage.write(
      key: 'userCredential',
      value: userCredential.toString(),
    );
  }

  // Future<String?> getToken() {
  //   return storage.read(key: 'token');
  // }

  Future<void> signOutWithGoogle({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await storage.delete(key: 'token');
      await storage.delete(key: 'userCredential');
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
      // ignore: use_build_context_synchronously
      Navigator.popAndPushNamed(
        context,
        Splash.id,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        AuthServices.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  Future signInLinkEmail(String email) async {
    final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: 'https://teamdynamics.page.link/',
      handleCodeInApp: true,
      iOSBundleId: 'com.google.firebase.teamdynamics',
      androidPackageName: 'com.google.firebase.teamdynamics',
      androidInstallApp: true,
      androidMinimumVersion: '1',
    );
    _firebaseAuth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  Future signingInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      final user = userCredential.user!;
      return user;
    } catch (e) {
      return null;
    }
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (state == AppLifecycleState.resumed) {
  //     final PendingDynamicLinkData data =
  //         await FirebaseDynamicLinks.instance.getInitialLink();
  //     if (data?.link != null) {
  //       handleLink(data?.link);
  //     }
  //     FirebaseDynamicLinks.instance.onLink(
  //         onSuccess: (PendingDynamicLinkData dynamicLink) async {
  //       final Uri deepLink = dynamicLink?.link;
  //       handleLink(deepLink);
  //     }, onError: (OnLinkErrorException e) async {
  //       print('onLinkError');
  //       print(e.message);
  //     });
  //   }
  // }

  // void handleLink(Uri link) async {
  //   if (link != null) {
  //     final FirebaseUser user = (await _auth.signInWithEmailAndLink(
  //       email: _userEmail,
  //       link: link.toString(),
  //     ))
  //         .user;
  //     if (user != null) {
  //       setState(() {
  //         _userID = user.uid;
  //         _success = true;
  //       });
  //     } else {
  //       setState(() {
  //         _success = false;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _success = false;
  //     });
  //   }
  //   setState(() {});
  // }

  Future<User?> createUserWithEmailAndPassword(
      UserData userData, BuildContext context) async {
    User? user;
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userData.email,
        password: userData.password!,
      );
      storeTokenAndData(credential);
      user = credential.user;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'account-exists-with-different-credential') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          AuthServices.customSnackBar(
            content: 'The account already exists with a different credential.',
          ),
        );
      } else if (e.code == 'invalid-credential') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          AuthServices.customSnackBar(
            content: 'Error occurred while accessing credentials. Try again.',
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        AuthServices.customSnackBar(
          content: 'Error occurred using Google Sign-In. Try again.',
        ),
      );
    }
    // Update the username
    await updateUserName(userData.fullName);
    final userSnapshot = await FirestoreDatabase().getUser();
    // if (userSnapshot.exists) {
    //   // ignore: cast_nullable_to_non_nullable
    //   final json = userSnapshot.data() as Map<String, dynamic>;
    //   userData = UserData.fromJson(json: json);
    //   userData.image = await UrlToFile.urlToFile(userData.imageLink!);
    // } else {
    await FirestoreDatabase().createUser(userData);
    // }
    return user;
  }

  // Future<String> createCustomerWithEmailAndPassword(UserData userData) async {
  //   FirebaseApp app = await Firebase.initializeApp(
  //       name: 'New App', options: Firebase.app().options);

  //   try {
  //     String uid = await FirebaseAuth.instance.currentUser!.uid;

  //     UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
  //         .createUserWithEmailAndPassword(
  //             email: userData.e_mail, password: userData.password);
  //     Customer user = Customer(
  //         fullName: userData.fullName, email: userData.email, adminUID: uid);
  //     await FirebaseDatabase(uid: userCredential.user!.uid).setCustomerData(user);
  //     await AuthServices()
  //         .updateUserName(userData.full_name, userCredential.user!);
  //     await app.delete();
  //     return userCredential.user!.uid;
  //   } on FirebaseAuthException catch (e) {
  //     print(e);
  //     await app.delete();
  //     throw e;
  //   }
  // }

  Future reauthenticateUser(String password) async {
    final User? currentUser = await getCurrentUser();
    final String email = currentUser!.email.toString();
    final AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    await FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(credential);
  }

  // Update username.
  Future updateUserName(String name) async {
    // ignore: deprecated_member_use
    final User currentUser = _firebaseAuth.currentUser!;
    // ignore: deprecated_member_use
    await currentUser.updateProfile(displayName: name);
    await currentUser.reload();
  }

  //Update email.
  Future updateEmail(String newEmail) async {
    final User currentUser = _firebaseAuth.currentUser!;
    await currentUser.updateEmail(newEmail);
    await currentUser.reload();
  }

  //Update Password
  Future updatePassword(String newPassword) async {
    final User currentUser = _firebaseAuth.currentUser!;
    await currentUser.updatePassword(newPassword);
    await currentUser.reload();
  }

  // Email & Password Sign In
  Future<String> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user!.uid;
  }

  // Sign Out
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendVerificationEmail() async {
    final User? user = _firebaseAuth.currentUser;

    if (user != null && !user.emailVerified) {
      user.sendEmailVerification();
    }
  }

  // Reset Password
  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // void doUserResetPassword() async {
  //   final ParseUser user = ParseUser(null, null, controllerEmail.text.trim());
  //   final ParseResponse parseResponse = await user.requestPasswordReset();
  //   if (parseResponse.success) {
  //     Message.showSuccess(
  //         context: context,
  //         message: 'Password reset instructions have been sent to email!',
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         });
  //   } else {
  //     Message.showError(context: context, message: parseResponse.error.message);
  //   }
  // }
}
