// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, cast_nullable_to_non_nullable, prefer_if_elements_to_conditional_expressions, avoid_positional_boolean_parameters

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:know_better/models/room.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/auth_services.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/views/user/feedback_game.dart';

class UserPhysicalRoom extends StatefulWidget {
  final RoomsDetail roomsDetail;
  final int runNo;
  final Room room;
  const UserPhysicalRoom({
    required this.roomsDetail,
    required this.runNo,
    required this.room,
  });

  @override
  _UserPhysicalRoomState createState() => _UserPhysicalRoomState();
}

class _UserPhysicalRoomState extends State<UserPhysicalRoom> {
  UserData currentUserData = UserData();
  UserData userData = UserData();
  String uid1 = '';
  String uid2 = '';
  // String fullName = 'Darrell Steward';
  // String title = 'UI/UX Designer';
  // String code = '';
  List<String> skills = [];
  List<String> techSkills = [];
  bool isSkillExpanded = false;
  bool isTechSkillExpanded = false;
  int skillLength = 0;
  int techSkillLength = 0;

  Duration duration = Duration();
  Timer? timer;
  int? currentRoomIndex;
  bool countDown = true;
  List<Room> rooms = [];

  @override
  void dispose() {
    // TODO: implement dispose
    timer!.cancel();
    super.dispose();
  }

  void reset() {
    setState(() => duration = widget.roomsDetail.duration);
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  Future<void> addTime() async {
    int seconds = 0;
    final timerRef = RealtimeDatabase()
        .database
        .child(widget.roomsDetail.accessCode)
        .child('/timer');
    final snapshot = await timerRef.get();
    final timerData = Map<String, int>.from(snapshot.value as Map);
    setState(() {
      seconds = timerData['room_duration']!;
    });
    if (seconds <= 0) {
      timer?.cancel();
      setState(() {
        duration = Duration(seconds: seconds);
      });
      if (widget.roomsDetail.roomType == RoomType.Physical) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return FeedbackGameScreen(
                room: widget.room,
                roomsDetail: widget.roomsDetail,
                runNo: widget.runNo,
              );
            },
          ),
        );
      } else {
        // Navigate to Virtual Room.
      }
    }
    // else {
    // timerRef.set({
    //   'countdown': seconds,
    //   'room_duration': widget.roomsDetail.duration.inSeconds,
    // });
    setState(() {
      duration = Duration(seconds: seconds);
    });
    // }
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer?.cancel());
  }

  Future<UserData> getUserData(String uid) async {
    final snapshot =
        await FirestoreDatabase().userDataCollection.doc(uid).get();
    final json = snapshot.data() as Map<String, dynamic>;
    return UserData.fromJson(json: json);
  }

  Future<DocumentSnapshot<Object?>> getData() async {
    final uid = await AuthServices().getCurrentUID();
    if (uid.compareTo(uid1) == 0) {
      currentUserData = await getUserData(uid1);
      return FirestoreDatabase().userDataCollection.doc(uid2).get();
    } else {
      currentUserData = await getUserData(uid2);
      return FirestoreDatabase().userDataCollection.doc(uid1).get();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final json1 = jsonDecode(widget.room.participants[0]);
    uid1 = json1['id'].toString();
    final json2 = jsonDecode(widget.room.participants[1]);
    uid2 = json2['id'].toString();
    reset();
    startTimer();
  }

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Run ${widget.runNo}'),
          leading: IconButton(
            iconSize: 1.0,
            onPressed: () {},
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFF6F6F7),
            ),
          ),
        ),
        body: FutureBuilder(
          future: getData(),
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
                  final jsonData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  userData = UserData.fromJson(json: jsonData);
                  skills = [];
                  techSkills = [];
                  skillLength = 0;
                  techSkillLength = 0;
                  int count = 0;
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
                    if (count >= 5 && techSkillLength < 25) {
                      return skillLength < 15;
                    }
                    return techSkillLength < 25;
                  }).toList();
                  if (techSkillLength >= 25) {
                    techSkills.add('...');
                  }
                  return SafeArea(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: SizeConfig.heightMultiplier * 2,
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
                                      height: SizeConfig.heightMultiplier * 2,
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
                                      height: SizeConfig.heightMultiplier * 3,
                                    ),
                                    CircularPercentIndicator(
                                      radius: SizeConfig.heightMultiplier * 20,
                                      lineWidth:
                                          SizeConfig.imageSizeMultiplier * 3,
                                      // animation: true,
                                      // fillColor: Color.fromRGBO(120, 22, 247, 1.0),
                                      progressColor: const Color.fromRGBO(
                                          120, 22, 247, 1.0),
                                      percent: duration.inSeconds /
                                          widget.roomsDetail.duration.inSeconds,
                                      center: Text(
                                        '${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              SizeConfig.textMultiplier * 7,
                                        ),
                                      ),
                                      // footer: Text(
                                      //   "Sales this week",
                                      //   style: TextStyle(
                                      //       fontWeight: FontWeight.bold,
                                      //       fontSize: 17.0,),
                                      // ),
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
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
              } catch (e) {
                return const SafeArea(
                  child: Center(
                    child: Text('Loading.....'),
                  ),
                );
              }
              return const SafeArea(
                child: Text('............'),
              );
            }
          },
        ),
      ),
    );
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
}
