// ignore_for_file: use_build_context_synchronously, cast_nullable_to_non_nullable, non_constant_identifier_names, avoid_positional_boolean_parameters

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:know_better/components/form_button.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/auth_services.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/services/dynamic_link.dart';
import 'package:know_better/utilities/function_utilities.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/utilities/styles/styling.dart';
import 'package:know_better/views/admin/admin_room_dashboard.dart';
import 'package:know_better/views/create_activity_room.dart';
import 'package:know_better/views/edit_profile.dart';
import 'package:know_better/views/final_room_dashboard.dart';
import 'package:know_better/views/user/user_room_dashboard.dart';

class UserDashboard extends StatefulWidget {
  static String id = 'UserDashboard';

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with WidgetsBindingObserver {
  UserData userData = UserData();
  String fullName = 'Darrell Steward';
  String title = 'UI/UX Designer';
  String code = '';
  List<String> skills = [];
  List<String> techSkills = [];
  bool isSkillExpanded = false;
  bool isTechSkillExpanded = false;
  int skillLength = 0;
  int techSkillLength = 0;
  TextEditingController codeController = TextEditingController();

  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  Timer? _timerLink;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = Timer(
        const Duration(milliseconds: 1000),
        () {
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
    return FutureBuilder(
      future: FirestoreDatabase().getUser(),
      builder: (
        BuildContext context,
        AsyncSnapshot<DocumentSnapshot<Object?>> snapshot,
      ) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        } else {
          try {
            if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) {
              skills = [];
              techSkills = [];
              skillLength = 0;
              techSkillLength = 0;
              int count = 0;
              final jsonData = snapshot.data!.data() as Map<String, dynamic>;
              userData = UserData.fromJson(json: jsonData);
              final String name = userData.fullName.split(' ')[0];
              userData.skills!.sort(
                (skill1, skill2) => skill1.length.compareTo(skill2.length),
              );
              userData.softSkills!.sort(
                (skill1, skill2) => skill1.length.compareTo(skill2.length),
              );
              skills = userData.softSkills!.takeWhile((skill) {
                skillLength += skill.length;
                count += 1;
                if (count >= 5 && skillLength < 25) {
                  return skillLength < 15;
                }
                return skillLength < 25;
              }).toList();
              if (skillLength >= 25) {
                skills.add('...');
              }
              count = 0;
              techSkills = userData.skills!.takeWhile((skill) {
                techSkillLength += skill.length;
                count += 1;
                if (count >= 5 && skillLength < 25) {
                  return skillLength < 15;
                }
                return techSkillLength < 25;
              }).toList();
              if (techSkillLength >= 25) {
                techSkills.add('...');
              }
              // print('s=$skills');
              // print(skillLength);
              // print('t=$techSkills');
              // print(techSkillLength);
              // print('data=${userData.toJson()}');
              return WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: Scaffold(
                  appBar: AppBar(
                    title: Text('Welcome $name'),
                    leading: IconButton(
                      iconSize: 1.0,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFFF6F6F7),
                      ),
                    ),
                    actions: [
                      popUpMenu(context),
                    ],
                  ),
                  body: SafeArea(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: SizeConfig.heightMultiplier,
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier,
                                    ),
                                    CircleAvatar(
                                      radius:
                                          SizeConfig.imageSizeMultiplier * 16,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage:
                                          NetworkImage(userData.imageLink!),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier * 1.5,
                                    ),
                                    Text(
                                      userData.fullName,
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.textMultiplier * 4.5,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier,
                                    ),
                                    Text(
                                      userData.title,
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.textMultiplier * 3.8,
                                        color: const Color(0xFF91919F),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier * 5,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible:
                                              userData.softSkills!.isNotEmpty,
                                          child: Text(
                                            'Soft Skill',
                                            style: TextStyle(
                                              fontSize:
                                                  SizeConfig.textMultiplier * 4,
                                              color: const Color(0xFF91919F),
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: SizeConfig.heightMultiplier,
                                        ),
                                        // ignore: prefer_if_elements_to_conditional_expressions
                                        isSkillExpanded
                                            ? skillsDisplay(
                                                userData.softSkills!,
                                                false,
                                              )
                                            : Row(
                                                children: skills.map((skill) {
                                                  if (skill.compareTo('...') !=
                                                      0) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 5.0,
                                                      ),
                                                      child: InputChip(
                                                        disabledColor:
                                                            const Color
                                                                .fromRGBO(
                                                          237,
                                                          250,
                                                          244,
                                                          1,
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 3.0,
                                                        ),
                                                        // isEnabled: false,
                                                        label: Text(
                                                          skill,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: SizeConfig
                                                                    .textMultiplier *
                                                                3.2,
                                                            color: Colors
                                                                .green[800],
                                                            fontFamily: 'Inter',
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return InputChip(
                                                      disabledColor:
                                                          const Color.fromRGBO(
                                                        237,
                                                        250,
                                                        244,
                                                        1,
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 3.0,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          isSkillExpanded =
                                                              !isSkillExpanded;
                                                        });
                                                      },
                                                      // isEnabled: false,
                                                      label: Text(
                                                        '...',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: SizeConfig
                                                                  .textMultiplier *
                                                              3.2,
                                                          color:
                                                              Colors.green[800],
                                                          fontFamily: 'Inter',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }).toList(),
                                              ),
                                        SizedBox(
                                          height:
                                              SizeConfig.heightMultiplier * 2,
                                        ),
                                        Visibility(
                                          visible: userData.skills!.isNotEmpty,
                                          child: Text(
                                            'Tech Skill',
                                            style: TextStyle(
                                              fontSize:
                                                  SizeConfig.textMultiplier * 4,
                                              color: const Color(0xFF91919F),
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: SizeConfig.heightMultiplier,
                                        ),
                                        // ignore: prefer_if_elements_to_conditional_expressions
                                        isTechSkillExpanded
                                            ? skillsDisplay(
                                                userData.skills!,
                                                true,
                                              )
                                            : Row(
                                                children:
                                                    techSkills.map((skill) {
                                                  if (skill.compareTo('...') !=
                                                      0) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 5.0,
                                                      ),
                                                      child: InputChip(
                                                        disabledColor:
                                                            const Color
                                                                .fromRGBO(
                                                          237,
                                                          250,
                                                          244,
                                                          1,
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 3.0,
                                                        ),
                                                        // isEnabled: false,
                                                        label: Text(
                                                          skill,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: SizeConfig
                                                                    .textMultiplier *
                                                                3.2,
                                                            color: Colors
                                                                .green[800],
                                                            fontFamily: 'Inter',
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return InputChip(
                                                      disabledColor:
                                                          const Color.fromRGBO(
                                                        237,
                                                        250,
                                                        244,
                                                        1,
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 3.0,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          isTechSkillExpanded =
                                                              !isTechSkillExpanded;
                                                        });
                                                      },
                                                      // isEnabled: false,
                                                      label: Text(
                                                        '...',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: SizeConfig
                                                                  .textMultiplier *
                                                              3.2,
                                                          color:
                                                              Colors.green[800],
                                                          fontFamily: 'Inter',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }).toList(),
                                              ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier * 2.5,
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Access Code',
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 4.5,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier * 2,
                                    ),
                                    TextFormField(
                                      maxLength: 6,
                                      controller: codeController,
                                      onChanged: (String textValue) {
                                        code = textValue;
                                      },
                                      onFieldSubmitted:
                                          (String textValue) async {
                                        if (code.isNotEmpty &&
                                            code.length == 6) {
                                          _showLoadingBar(context);
                                          final data = await RealtimeDatabase()
                                              .getRoom(code);
                                          if (data.exists) {
                                            final roomsDetail =
                                                await RealtimeDatabase()
                                                    .addParticipants(code);
                                            final uid = await AuthServices()
                                                .getCurrentUID();
                                            code = '';
                                            codeController.text = '';
                                            Navigator.of(context).pop();
                                            if (uid.compareTo(
                                                  roomsDetail.adminID,
                                                ) ==
                                                0) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return AdminRoomDashboard(
                                                      roomsDetail: roomsDetail,
                                                    );
                                                  },
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return UserRoomDashboard(
                                                      roomsDetail: roomsDetail,
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          } else {
                                            final roomCollection =
                                                await FirestoreDatabase()
                                                    .roomDataCollection
                                                    .get();
                                            // await roomDataList =
                                            if (roomCollection.docs.any(
                                              (element) =>
                                                  element.id.compareTo(code) ==
                                                  0,
                                            )) {
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return FinalRoomDashboard(
                                                      accessCode: code,
                                                    );
                                                  },
                                                ),
                                              );
                                            } else {
                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Room is not active.'),
                                                ),
                                              );
                                            }
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Enter Room Code'),
                                            ),
                                          );
                                        }
                                      },
                                      style: TextStyle(
                                        fontSize: SizeConfig.textMultiplier * 4,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Inter',
                                        letterSpacing:
                                            SizeConfig.textMultiplier * 1.5,
                                      ),
                                      decoration: kInputDecoration.copyWith(
                                        hintText: 'Code',
                                        hintStyle: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 4,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Inter',
                                          letterSpacing:
                                              SizeConfig.textMultiplier * 0.5,
                                        ),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: 48,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: const Color(0xFFE7DEFF),
                                            ),
                                            child: IconButton(
                                              onPressed: () async {
                                                if (code.isNotEmpty &&
                                                    code.length == 6) {
                                                  _showLoadingBar(context);
                                                  final data =
                                                      await RealtimeDatabase()
                                                          .getRoom(code);
                                                  if (data.exists) {
                                                    final roomsDetail =
                                                        await RealtimeDatabase()
                                                            .addParticipants(
                                                      code,
                                                    );
                                                    final uid =
                                                        await AuthServices()
                                                            .getCurrentUID();
                                                    code = '';
                                                    codeController.text = '';
                                                    Navigator.of(context).pop();
                                                    if (uid.compareTo(
                                                          roomsDetail.adminID,
                                                        ) ==
                                                        0) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return AdminRoomDashboard(
                                                              roomsDetail:
                                                                  roomsDetail,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return UserRoomDashboard(
                                                              roomsDetail:
                                                                  roomsDetail,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    final roomCollection =
                                                        await FirestoreDatabase()
                                                            .roomDataCollection
                                                            .get();
                                                    // await roomDataList =
                                                    if (roomCollection.docs.any(
                                                      (element) =>
                                                          element.id.compareTo(
                                                            code,
                                                          ) ==
                                                          0,
                                                    )) {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return FinalRoomDashboard(
                                                              accessCode: code,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    } else {
                                                      Navigator.of(context)
                                                          .pop();
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Room is not active.',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Enter Room Code',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.arrow_forward,
                                                color: Color(0xFF7816F7),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier * 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.heightMultiplier * 2,
                            ),
                            FormButton(
                              label: 'Create A Room',
                              color: const Color(0xFF44CC88),
                              onPressed: () {
                                Navigator.pushNamed(context, RoomTypeScreen.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          } catch (e) {
            return const Scaffold(
              body: SafeArea(
                child: Center(
                  child: Text('Loading.....'),
                ),
              ),
            );
          }
          return SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: SizeConfig.heightMultiplier * 2,
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: SizeConfig.heightMultiplier * 2,
                            ),
                            const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage('assets/icons/Google_logo.png'),
                            ),
                            SizedBox(
                              height: SizeConfig.heightMultiplier * 2,
                            ),
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.heightMultiplier * 1,
                            ),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.heightMultiplier * 3,
                            ),
                            // skillsDisplay(),
                            SizedBox(
                              height: SizeConfig.heightMultiplier * 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  PopupMenuButton<int> popUpMenu(BuildContext context) {
    return PopupMenuButton(
      color: Colors.grey.shade300,
      itemBuilder: (context) => [
        // PopupMenuItem<int>(
        //   value: 0,
        //   child: Text(
        //     'Create Room',
        //     style: TextStyle(color: Colors.black),
        //   ),
        // ),
        const PopupMenuItem<int>(
          value: 1,
          child: Text(
            'Edit Profile',
            style: TextStyle(color: Colors.black),
          ),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text(
            'Signout',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
      onSelected: (item) => {
        SelectedItem(context, item),
      },
    );
  }

  Future<void> editProfile() async {
    final User? user = await AuthServices().signInWithGoogle(context: context);

    if (user != null) {
      UserData userData = UserData.fromUser(user: user);
      final userSnapshot = await FirestoreDatabase().getUser();
      if (userSnapshot.exists) {
        final json = userSnapshot.data() as Map<String, dynamic>;
        userData = UserData.fromJson(json: json);
        userData.image = await UrlToFile.urlToFile(userData.imageLink!);
      } else {
        await FirestoreDatabase().createUser(userData);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return EditProfileScreen(
              googleSignIn: true,
              userData: userData,
            );
          },
        ),
      );
    }
  }

  void SelectedItem(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushNamed(context, RoomTypeScreen.id);
        break;
      case 1:
        _showLoadingBar(context);
        editProfile();
        break;
      case 2:
        AuthServices().signOutWithGoogle(context: context);
    }
  }

  Widget buildChip(String text) {
    return InputChip(
      disabledColor: const Color.fromRGBO(237, 250, 244, 1),
      padding: const EdgeInsets.symmetric(
        horizontal: 3.0,
      ),
      // isEnabled: false,
      label: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: SizeConfig.textMultiplier * 3.2,
          color: Colors.green[800],
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget skillsDisplay(List<String> skills, bool isTech) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        spacing: 10.0,
        children: List.generate(
          skills.length + 1,
          (int index) {
            // print(skills);
            if (index == skills.length) {
              return InputChip(
                disabledColor: const Color.fromRGBO(237, 250, 244, 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 3.0,
                ),
                onPressed: () {
                  setState(() {
                    if (isTech) {
                      isTechSkillExpanded = !isTechSkillExpanded;
                    } else {
                      isSkillExpanded = !isSkillExpanded;
                    }
                  });
                },
                // isEnabled: false,
                label: Text(
                  '...',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: SizeConfig.textMultiplier * 3.2,
                    color: Colors.green[800],
                    fontFamily: 'Inter',
                  ),
                ),
              );
            }
            return buildChip(skills[index]);
          },
        ),
      ),
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
