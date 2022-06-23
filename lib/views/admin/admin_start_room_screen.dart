// ignore_for_file: sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:know_better/models/room.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/utilities/styles/user.dart';
import 'package:know_better/utilities/styles/video_calling.dart';
import 'package:know_better/views/admin/admin_physical_room.dart';
import 'package:know_better/views/user/user_start_room_screen.dart';

class AdminStartRoomScreen extends StatefulWidget {
  final RoomsDetail roomsDetail;
  final int runNo;

  const AdminStartRoomScreen({
    required this.runNo,
    required this.roomsDetail,
  });

  @override
  _AdminStartRoomScreenState createState() => _AdminStartRoomScreenState();
}

class _AdminStartRoomScreenState extends State<AdminStartRoomScreen> {
  static const countdownDuration = Duration(seconds: 10);
  // ignore: prefer_const_constructors
  Duration duration = Duration();
  Timer? timer;
  int? currentRoomIndex;
  bool countDown = true;
  List<Room?> rooms = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentRoomIndex = widget.runNo - 1;
    // findRooms();
    reset();
    startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer!.cancel();
    super.dispose();
  }

  void reset() {
    setState(() => duration = countdownDuration);
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    int seconds = 0;
    final timerRef = RealtimeDatabase()
        .database
        .child(widget.roomsDetail.accessCode)
        .child('/timer');
    // final snapshot = await timerRef.get();
    // final timerData = Map<String, int>.from(snapshot.value as Map);
    if (duration.inSeconds >= 0) {
      setState(() {
        seconds = duration.inSeconds - 1;
      });
    }
    if (seconds < 0) {
      timer?.cancel();
      if (widget.roomsDetail.roomType == RoomType.Physical) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return AdminPhysicalRoom(
                roomsDetail: widget.roomsDetail,
                runNo: widget.runNo,
                room: rooms[currentRoomIndex!]!,
              );
            },
          ),
        );
      } else {
        // Navigate to Virtual Room.
      }
    } else {
      timerRef.set({
        'countdown': seconds,
        'room_duration': widget.roomsDetail.duration.inSeconds,
      });
      setState(() {
        duration = Duration(seconds: seconds);
      });
    }
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer?.cancel());
  }

  Widget showTimer() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Center(
      child: Text(
        seconds,
        style: GoogleFonts.orbitron(
          fontWeight: FontWeight.w400,
          fontSize: SizeConfig.textMultiplier * 10,
          color: const Color(0xFF44CC88),
        ),
      ),
    );
  }

  Future<int> findRooms() async {
    final List<Room?> rms = [];
    // final uid = await AuthServices().getCurrentUID();
    final snapshot = await FirestoreDatabase().getUser();
    final json = snapshot.data()! as Map<String, dynamic>;
    final userData = UserData.fromJson(json: json).toString();
    // final userName = user.displayName;
    for (var i = 0; i < widget.roomsDetail.runs.length; i++) {
      if (widget.roomsDetail.runs[i]
          .any((element) => element.participants.contains(userData))) {
        rms.add(
          widget.roomsDetail.runs[i][widget.roomsDetail.runs[i].indexWhere(
              (element) => element.participants.contains(userData))],
        );
        // print(room.participants);
      } else {
        rms.add(null);
      }
    }
    rooms = rms;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Start Room'),
          leading: IconButton(
            iconSize: 1.0,
            onPressed: () {},
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFF6F6F7),
            ),
          ),
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: findRooms(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data1 =
                    jsonDecode(rooms[currentRoomIndex!]!.participants[0])
                        as Map<String, dynamic>;
                final data2 =
                    jsonDecode(rooms[currentRoomIndex!]!.participants[1])
                        as Map<String, dynamic>;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // color: Colors.white,
                          padding: const EdgeInsets.all(25.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: SizeConfig.heightMultiplier * 15,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.green[50]!,
                                      Colors.white,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: showTimer(),
                              ),
                              SizedBox(
                                height: SizeConfig.heightMultiplier * 2,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: SizeConfig.imageSizeMultiplier * 33,
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius:
                                              SizeConfig.imageSizeMultiplier *
                                                  10,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: NetworkImage(
                                            data1['image'].toString(),
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.heightMultiplier * 1.8,
                                        ),
                                        Text(
                                          data1['full_name'].toString(),
                                          softWrap: false,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.textMultiplier * 4,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          data1['title'].toString(),
                                          softWrap: false,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.textMultiplier * 3.3,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF91919F),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: SizeConfig.imageSizeMultiplier * 4,
                                    // child: Divider(
                                    //   thickness: 1.0,
                                    //   color: Color.fromRGBO(68, 204, 136, 1.0),
                                    // ),
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: SizeConfig.heightMultiplier * 4,
                                      ),
                                      Icon(
                                        widget.roomsDetail.roomType ==
                                                RoomType.Virtual
                                            ? VirtualRoom.video_calling
                                            : PhysicalRoom.users,
                                        color: const Color.fromRGBO(
                                            68, 204, 136, 1.0),
                                        size:
                                            SizeConfig.imageSizeMultiplier * 5,
                                      ),
                                      SizedBox(
                                        height: SizeConfig.heightMultiplier * 6,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: SizeConfig.imageSizeMultiplier * 3,
                                    // child: Divider(
                                    //   thickness: 1.0,
                                    //   color: Color.fromRGBO(68, 204, 136, 1.0),
                                    // ),
                                  ),
                                  Container(
                                    width: SizeConfig.imageSizeMultiplier * 33,
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius:
                                              SizeConfig.imageSizeMultiplier *
                                                  10,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: NetworkImage(
                                            data2['image'].toString(),
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              SizeConfig.heightMultiplier * 1.8,
                                        ),
                                        Text(
                                          data2['full_name'].toString(),
                                          softWrap: false,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.textMultiplier * 4,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          data2['title'].toString(),
                                          softWrap: false,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.textMultiplier * 3.3,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF91919F),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: SizeConfig.heightMultiplier * 2,
                            ),
                            Text(
                              'My Queue',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 4.5,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.heightMultiplier * 1.5,
                            ),
                            Column(
                              children: rooms.length - currentRoomIndex! - 1 ==
                                      0
                                  ? [
                                      Center(
                                        child: Text(
                                          'No Runs Left.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.textMultiplier * 4.5,
                                          ),
                                        ),
                                      ),
                                    ]
                                  : List.generate(
                                      rooms.length - currentRoomIndex! - 1,
                                      (index) {
                                      // if (rooms[currentRoomIndex! + index + 1] !=
                                      //     null) {
                                      if (rooms[
                                              currentRoomIndex! + index + 1] !=
                                          null) {
                                        return RoomCard(
                                          title:
                                              'Run ${currentRoomIndex! + index + 2}',
                                          roomNo: currentRoomIndex! + index + 2,
                                          user1: rooms[currentRoomIndex! +
                                                  index +
                                                  1]!
                                              .participants[0],
                                          user2: rooms[currentRoomIndex! +
                                                  index +
                                                  1]!
                                              .participants[1],
                                        );
                                      }
                                      return Container();
                                      // } else {
                                      //   return Container();
                                      // }
                                    }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
