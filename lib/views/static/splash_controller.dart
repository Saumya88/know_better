// ignore_for_file: always_declare_return_types, type_annotate_public_apis

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:get/utils.dart';
import 'package:know_better/models/splash_info.dart';

class SplashController extends GetxController {
  RxInt selectedPageIndex = 0.obs;
  bool get isLastPage => selectedPageIndex.value == onboardingPages.length - 1;
  PageController pageController = PageController();

  forwardAction() {
    if (isLastPage) {
      //go to home page
    } else {
      pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease);
    }
  }

  List<SplashInfo> onboardingPages = [
    SplashInfo(
      'assets/images/Hand_of_person_using_mobile_phone_for_video_call-ai 1.png',
      'Create Profile',
      'Sign in and create your Professional Profile with your Title and Skills you know',
    ),
    SplashInfo(
      'assets/images/HR manager talking with candidate at job interview-ai 1.png',
      'Join Activity Room',
      'Join your organization activity room or create a new room for your organiztion',
    ),
    SplashInfo(
      'assets/images/Employees brainstorming during coffee break-ai 1.png',
      'Interact with others',
      '1-on-1 interaction with all other employees in virtual or physical mode.',
    ),
    SplashInfo(
      'assets/images/Cartoon metaphor of customer review, quality feedback-ai 1.png',
      'Rate your Interaction',
      'Provide feedback and rate your interaction with each of your colleague.',
    ),
  ];
}
