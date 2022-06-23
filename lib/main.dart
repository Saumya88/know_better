import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/views/create_activity_room.dart';
import 'package:know_better/views/onboarding_user.dart';
import 'package:know_better/views/static/splash.dart';
import 'package:know_better/views/user_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<FirebaseApp>? _initialization;
  Widget currentPage = Splash();

  @override
  void initState() {
    _initialization = Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: GOOGLE_API_KEY,
          appId: '1:415903891784:android:e9a629fb8b37d6f3ccb37d',
          messagingSenderId: '415903891784',
          projectId: 'know-better-59964'),
    );
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  // ignore: avoid_void_async
  void checkLogin() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token != null) {
      setState(() {
        currentPage = UserDashboard();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return const MaterialApp(
            title: 'Team Dynamics',
            home: Scaffold(
              body: Center(
                child: Text(
                  'App Not initialized',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  SizeConfig().init(constraints, orientation);
                  return MaterialApp(
                    title: 'Team Dynamics',
                    theme: ThemeData(
                      scaffoldBackgroundColor: const Color(0xFFF6F6F7),
                      appBarTheme: AppBarTheme(
                        centerTitle: true,
                        titleTextStyle: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.textMultiplier * 4.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                        backgroundColor: const Color(0xFFF6F6F7),
                        elevation: 0.0,
                        iconTheme: const IconThemeData(color: Colors.black),
                      ),
                    ),
                    // initialRoute: UserOnboarding.id,
                    home: currentPage,
                    //home: FeedbackGameScreen(),
                    routes: {
                      UserOnboarding.id: (context) => const UserOnboarding(),
                      UserDashboard.id: (context) => UserDashboard(),
                      Splash.id: (context) => Splash(),
                      RoomTypeScreen.id: (context) => const RoomTypeScreen(),
                    },
                  );
                },
              );
            },
          );
        }
        return Container(
          height: SizeConfig.heightMultiplier * 100,
          width: SizeConfig.imageSizeMultiplier * 100,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
