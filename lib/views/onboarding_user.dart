// ignore_for_file: sized_box_for_whitespace

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/views/create_profile.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:know_better/components/form_button.dart';
import 'package:know_better/components/google_sign_in_button.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/utilities/welcome_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// These URLs are endpoints that are provided by the authorization
// server. They're usually included in the server's documentation of its
// OAuth2 API.
final authorizationEndpoint =
    Uri.parse('https://accounts.getboarded.tech/oauth2/auth');
final tokenEndpoint =
    Uri.parse('https://accounts.getboarded.tech/oauth2/token');

// The authorization server will issue each client a separate client
// identifier and secret, which allows the server to tell which client
// is accessing it. Some servers may also have an anonymous
// identifier/secret pair that any client may use.
//
// Note that clients whose source code or binary executable is readily
// available may not be able to make sure the client secret is kept a
// secret. This is fine; OAuth2 servers generally won't rely on knowing
// with certainty that a client is who it claims to be.
const identifier = '01bfdb57-8f21-4d09-a4bf-357c1542e2e5';
const secret = 'c12a5e5b-abb2-4a36-88fa-8f9220232414';

// This is a URL on your application's server. The authorization server
// will redirect the resource owner here once they've authorized the
// client. The redirection will include the authorization code in the
// query parameters.
final redirectUrl = Uri.parse('');

/// A file in which the users credentials are stored persistently. If the server
/// issues a refresh token allowing the client to refresh outdated credentials,
/// these may be valid indefinitely, meaning the user never has to
/// re-authenticate.
final credentialsFile = File('~/.myapp/credentials.json');

/// Either load an OAuth2 client from saved credentials or authenticate a new
/// one.
Future<oauth2.Client> createClient() async {
  final exists = await credentialsFile.exists();

  // If the OAuth2 credentials have already been saved from a previous run, we
  // just want to reload them.
  if (exists) {
    final credentials =
        oauth2.Credentials.fromJson(await credentialsFile.readAsString());
    return oauth2.Client(credentials, identifier: identifier, secret: secret);
  }

  // If we don't have OAuth2 credentials yet, we need to get the resource owner
  // to authorize us. We're assuming here that we're a command-line application.
  final grant = oauth2.AuthorizationCodeGrant(
    identifier,
    authorizationEndpoint,
    tokenEndpoint,
    secret: secret,
  );

  // A URL on the authorization server (authorizationEndpoint with some additional
  // query parameters). Scopes and state can optionally be passed into this method.
  final authorizationUrl = grant.getAuthorizationUrl(redirectUrl);
  // var authorizationUrl = Uri

  // Redirect the resource owner to the authorization URL. Once the resource
  // owner has authorized, they'll be redirected to `redirectUrl` with an
  // authorization code. The `redirect` should cause the browser to redirect to
  // another URL which should also have a listener.
  //
  // `redirect` and `listen` are not shown implemented here. See below for the
  // details.
  // await redirect(authorizationUrl);
  // var responseUrl = await listen(redirectUrl);
  if (await canLaunch(authorizationUrl.toString())) {
    await launch(authorizationUrl.toString());
  }

  // ------- 8< -------
  Uri responseUrl = Uri();

//   final linksStream = getLinksStream().listen((Uri uri) {
//    if (uri.toString().startsWith(redirectUrl.to)) {
//      responseUrl = uri;
//    }
//  });

  // Uri responseUrl = Uri();
  WebView(
    javascriptMode: JavascriptMode.unrestricted,
    initialUrl: authorizationUrl.toString(),
    navigationDelegate: (navReq) {
      if (navReq.url.startsWith(redirectUrl.toString())) {
        responseUrl = Uri.parse(navReq.url);
        return NavigationDecision.prevent;
      }
      return NavigationDecision.navigate;
    },
    // ------- 8< -------
  );

  // Once the user is redirected to `redirectUrl`, pass the query parameters to
  // the AuthorizationCodeGrant. It will validate them and extract the
  // authorization code to create a new Client.
  return grant.handleAuthorizationResponse(responseUrl.queryParameters);
}

class UserOnboarding extends StatefulWidget {
  static String id = 'UserOnboarding';
  final String? email;
  final String? accessCode;

  const UserOnboarding({this.accessCode, this.email});

  @override
  _UserOnboardingState createState() => _UserOnboardingState();
}

class _UserOnboardingState extends State<UserOnboarding> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        // child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: SizeConfig.heightMultiplier * 5,
            ),
            Container(
              height: SizeConfig.heightMultiplier * 70,
              width: SizeConfig.imageSizeMultiplier * 100,
              child: WelcomeScreen(),
            ),
            // CustomPaint(
            //   size: Size(400, 400),
            //   painter:
            // ),
            // Container(
            //   width: SizeConfig.imageSizeMultiplier * 100,
            //   height: SizeConfig.heightMultiplier * 70,
            //   child: SvgPicture.asset('assets/images/welcom.svg'),
            // ),
            // Container(
            //   height: SizeConfig.heightMultiplier * 70,
            //   width: double.infinity,
            //   // decoration: BoxDecoration(
            //   //   image:
            //   //       // SizeConfig.heightMultiplier /
            //   //       //             SizeConfig.imageSizeMultiplier >
            //   //       //         2.0
            //   //       DecorationImage(
            //   //     image:
            //   //         AssetImage('assets/images/user_onboarding_large.png'),
            //   //     fit: BoxFit.fitHeight,
            //   //   ),
            //   //   // : DecorationImage(
            //   //   //     image: AssetImage(
            //   //   //         'assets/images/user_onboarding_small.png'),
            //   //   //     fit: BoxFit.fitHeight,
            //   //   //   ),
            //   // ),
            //   child: (SizeConfig.heightMultiplier * 70) /
            //               (SizeConfig.imageSizeMultiplier * 100) <=
            //           2.0
            //       ? Image.asset(
            //           'assets/images/user_onboarding_small.png',
            //           fit: BoxFit.fill,
            //         )
            //       : Image.asset(
            //           'assets/images/user_onboarding_large.png',
            //           fit: BoxFit.fill,
            //         ),
            // ),
            // SizedBox(
            //   height: SizeConfig.heightMultiplier * 2,
            // ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  FormButton(
                    label: 'Create Profile With GetBoarded',
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return CreateProfileScreen();
                        },
                      ));
                    },
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier,
                  ),
                  FormButton(
                    label: 'Log In',
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return CreateProfileScreen(
                            email: widget.email,
                            accessCode: widget.accessCode,
                          );
                        },
                      ));
                    },
                  ),
                  // GoogleSignInButton(
                  //   email: widget.email,
                  //   accessCode: widget.accessCode,
                  // ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier,
                  ),
                ],
              ),
            )
          ],
        ),
        // ),
      ),
    );
  }
}
