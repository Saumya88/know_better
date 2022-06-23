// ignore_for_file: sized_box_for_whitespace

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:know_better/services/dynamic_link.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/views/onboarding_user.dart';
import 'package:know_better/views/static/splash_controller.dart';

class Splash extends StatefulWidget {
  static const String id = 'SplashScreen';

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with WidgetsBindingObserver {
  int currentindex = 0;

  final _controller = SplashController();

  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  Timer? _timerLink;

  PageController pageController = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = Timer(
        const Duration(milliseconds: 1000),
        () {
          // print('splash');
          _dynamicLinkService.retrieveDynamicLink(context);
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller.pageController,
              onPageChanged: _controller.selectedPageIndex,
              itemCount: _controller.onboardingPages.length,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: SizeConfig.heightMultiplier * 5.95,
                        ),
                        Text(
                          'Team Dynamics',
                          style: TextStyle(
                            fontSize: SizeConfig.textMultiplier * 8,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'PlayfairDisplay',
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.heightMultiplier * 12.5,
                        ),
                        Container(
                          width: SizeConfig.imageSizeMultiplier * 45,
                          height: SizeConfig.heightMultiplier * 25,
                          child: Image.asset(
                            _controller.onboardingPages[index].imageAsset
                                .toString(),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.heightMultiplier * 4,
                        ),
                        Text(
                          _controller.onboardingPages[index].title.toString(),
                          style: TextStyle(
                            fontSize: SizeConfig.textMultiplier * 7,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: SizeConfig.heightMultiplier * 1.5),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.heightMultiplier * 5,
                          ),
                          child: Text(
                            _controller.onboardingPages[index].description
                                .toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: SizeConfig.textMultiplier * 4,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(145, 145, 159, 1),
                              fontFamily: 'Inter',
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: SizeConfig.heightMultiplier * 19,
              left: MediaQuery.of(context).size.width / 2.5,
              child: Row(
                children: List.generate(
                  _controller.onboardingPages.length,
                  (index) => Obx(() {
                    return GestureDetector(
                      onTap: () {
                        pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.linear,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        width: _controller.selectedPageIndex.value == index
                            ? SizeConfig.heightMultiplier * 1.791
                            : SizeConfig.heightMultiplier * 1.791,
                        height: _controller.selectedPageIndex.value == index
                            ? SizeConfig.heightMultiplier * 1.791
                            : SizeConfig.heightMultiplier * 1.791,
                        decoration: BoxDecoration(
                          color: _controller.selectedPageIndex.value == index
                              ? const Color.fromRGBO(68, 204, 136, 1)
                              : const Color.fromRGBO(229, 242, 237, 1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('')),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Positioned(
              bottom: SizeConfig.heightMultiplier * 3,
              left: MediaQuery.of(context).size.width / 4.2,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return const UserOnboarding();
                        },
                      ),
                    );
                  },
                  child: Container(
                    //margin: EdgeInsets.all(2),
                    width: MediaQuery.of(context).size.width / 2,
                    height: SizeConfig.heightMultiplier * 8,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: kPurpleColor,
                    ),
                    child: Center(
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: SizeConfig.textMultiplier * 5,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
