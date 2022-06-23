import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/auth_services.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/function_utilities.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/views/create_profile.dart';

class GoogleSignInButton extends StatefulWidget {
  final String? accessCode;
  final String? email;

  const GoogleSignInButton({this.accessCode, this.email});

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  // ignore: unused_field
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      // child: _isSigningIn
      //     ? const CircularProgressIndicator(
      //         valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
      //       )
      child: TextButton(
        onPressed: () async {
          _showLoadingBar(context);

          final User? user =
              await AuthServices().signInWithGoogle(context: context);

          // UserData(
          //   id: user!.uid,
          //   fullName: user.displayName!,
          //   email: user.email!,
          //   title: '',
          //   skills: [],
          // );

          setState(() {
            _isSigningIn = false;
          });

          if (user != null) {
            // ignore: use_build_context_synchronously
            UserData userData = UserData.fromUser(user: user);
            // FirestoreDatabase().createUser(userData);
            final userSnapshot = await FirestoreDatabase().getUser();
            if (userSnapshot.exists) {
              // ignore: cast_nullable_to_non_nullable
              final json = userSnapshot.data() as Map<String, dynamic>;
              userData = UserData.fromJson(json: json);
              userData.image = await UrlToFile.urlToFile(userData.imageLink!);
            } else {
              await FirestoreDatabase().createUser(userData);
            }

            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return CreateProfileScreen(
                    accessCode: widget.accessCode,
                    email: widget.email,
                  );
                },
              ),
            );
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: SizeConfig.heightMultiplier * 8,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: SizeConfig.heightMultiplier * 4,
                width: SizeConfig.heightMultiplier * 4,
                child: Image.asset('assets/icons/Google_logo.png'),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                'Create profile with Google',
                style: TextStyle(
                  fontSize: SizeConfig.textMultiplier * 4.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      // OutlinedButton(
      //     style: ButtonStyle(
      //       backgroundColor: MaterialStateProperty.all(Colors.white),
      //       shape: MaterialStateProperty.all(
      //         RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(40),
      //         ),
      //       ),
      //     ),
      //     onPressed: () async {
      //       setState(() {
      //         _isSigningIn = true;
      //       });

      //       User? user =
      //           await AuthServices().signInWithGoogle(context: context);

      //       setState(() {
      //         _isSigningIn = false;
      //       });

      //       if (user != null) {
      //         Navigator.of(context).pushReplacement(
      //           MaterialPageRoute(
      //             builder: (context) => CreateProfile(),
      //           ),
      //         );
      //       }
      //     },
      //     child: Padding(
      //       padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      //       child: Row(
      //         mainAxisSize: MainAxisSize.min,
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: <Widget>[
      //           Image(
      //             image: AssetImage("assets/google_logo.png"),
      //             height: 35.0,
      //           ),
      //           Padding(
      //             padding: const EdgeInsets.only(left: 10),
      //             child: Text(
      //               'Sign in with Google',
      //               style: TextStyle(
      //                 fontSize: 20,
      //                 color: Colors.black54,
      //                 fontWeight: FontWeight.w600,
      //               ),
      //             ),
      //           )
      //         ],
      //       ),
      //     ),
      //   ),
    );
  }

  void _showLoadingBar(context) {
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.imageSizeMultiplier * 16,
            vertical: SizeConfig.heightMultiplier * 32,
          ),
          child: const SpinKitFadingCircle(color: Colors.white, size: 100),
        );
      },
    );
  }
}
