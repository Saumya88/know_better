// ignore_for_file: use_build_context_synchronously

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:know_better/services/auth_services.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/views/onboarding_user.dart';
import 'package:know_better/views/user/user_room_dashboard.dart';

class DynamicLinkService {
  Future<Uri> createDynamicLinkForRoom(String accessCode) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://teamdynamics.page.link',
      link: Uri.parse(
        'https://teamdynamics.getboarded.tech/?access_code=$accessCode',
      ),
      androidParameters: AndroidParameters(
        packageName: 'com.example.know_better',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',
      //   appStoreId: 'your_app_store_id',
      // ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
    );

    final dynamicUrl = await parameters.buildShortLink();
    return dynamicUrl.shortUrl;
    // return shortUrl;
  }

  Future<Uri> createDynamicLink(String accessCode, String email) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://teamdynamics.page.link',
      link: Uri.parse(
        'https://teamdynamics.getboarded.tech/?access_code=$accessCode&email=$email',
      ),
      androidParameters: AndroidParameters(
        packageName: 'com.example.know_better',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',
      //   appStoreId: 'your_app_store_id',
      // ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
    );

    final dynamicUrl = await parameters.buildShortLink();
    return dynamicUrl.shortUrl;
    // return shortUrl;
  }

  Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
          final Uri? deepLink = dynamicLink?.link;

          if (deepLink != null) {
            final user = await AuthServices().getCurrentUser();
            if (user != null) {
              if (deepLink.queryParameters.containsKey('email')) {
                final String email = deepLink.queryParameters['email']!;
                if (user.email!.compareTo(email) == 0) {
                  if (deepLink.queryParameters.containsKey('access_code')) {
                    final String accessCode =
                        deepLink.queryParameters['access_code']!;
                    final data = await RealtimeDatabase().getRoom(accessCode);
                    if (data.exists) {
                      final roomsDetail =
                          await RealtimeDatabase().addParticipants(accessCode);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return UserRoomDashboard(roomsDetail: roomsDetail);
                          },
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room is not active.'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Some Error Occured.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Join with email id mentioned in your mail.'),
                    ),
                  );
                }
              } else {
                if (deepLink.queryParameters.containsKey('access_code')) {
                  final String accessCode =
                      deepLink.queryParameters['access_code']!;
                  final data = await RealtimeDatabase().getRoom(accessCode);
                  if (data.exists) {
                    final roomsDetail =
                        await RealtimeDatabase().addParticipants(accessCode);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return UserRoomDashboard(roomsDetail: roomsDetail);
                        },
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Room is not active.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Some Error Occured.'),
                    ),
                  );
                }
              }
            } else {
              if (deepLink.queryParameters.containsKey('access_code')) {
                final String accessCode =
                    deepLink.queryParameters['access_code']!;
                final data = await RealtimeDatabase().getRoom(accessCode);
                if (data.exists) {
                  if (deepLink.queryParameters.containsKey('email')) {
                    final String email = deepLink.queryParameters['email']!;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return UserOnboarding(
                            accessCode: accessCode,
                            email: email,
                          );
                        },
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login to join Room'),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return UserOnboarding(
                            accessCode: accessCode,
                          );
                        },
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login to join Room'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Room is not active.'),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Some Error Occured.'),
                  ),
                );
              }
            }
          }
        },
        onError: (OnLinkErrorException e) async {},
      );
    } catch (e) {
      return;
    }
  }
}
