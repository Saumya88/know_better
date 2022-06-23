import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:know_better/components/room_card.dart';
import 'package:know_better/models/room.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/utilities/styles/size_config.dart';

class AdminWaitingScreen extends StatefulWidget {
  final RoomsDetail roomsDetail;
  final int runNo;
  const AdminWaitingScreen({
    required this.roomsDetail,
    required this.runNo,
  });

  @override
  _AdminWaitingScreenState createState() => _AdminWaitingScreenState();
}

class _AdminWaitingScreenState extends State<AdminWaitingScreen> {
  Duration countdownDuration = const Duration(seconds: 10);
  // ignore: prefer_const_constructors
  Duration duration = Duration();
  Timer? timer1;
  Timer? timer2;
  int? currentRoomIndex;
  bool countDown = true;
  List<Room> rooms = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    duration = widget.roomsDetail.duration;
    // countdownDuration = widget.roomsDetail.duration;
    currentRoomIndex = widget.runNo - 1;
    // findRooms();
    // reset1();
    startTimer1();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer1!.cancel();
    timer2!.cancel();
    super.dispose();
  }

  // void reset() {
  //   setState(() => duration = countdownDuration);
  // }

  // void reset1() {
  //   setState(() => duration = countdownDuration);
  // }

  void startTimer() {
    timer1 = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void startTimer1() {
    // _showLoadingBar(context);
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text('Wait for 10 seconds, starting rooms.'),
    // ));
    timer2 = Timer.periodic(const Duration(seconds: 1), (_) => addTime1());
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
      timer1?.cancel();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      timerRef.set({
        'countdown': 0,
        'room_duration': seconds,
      });
      setState(() {
        duration = Duration(seconds: seconds);
      });
    }
  }

  void addTime1() {
    int seconds = 0;
    final timerRef = RealtimeDatabase()
        .database
        .child(widget.roomsDetail.accessCode)
        .child('/timer');
    // final snapshot = await timerRef.get();
    // final timerData = Map<String, int>.from(snapshot.value as Map);
    if (countdownDuration.inSeconds >= 0) {
      setState(() {
        seconds = countdownDuration.inSeconds - 1;
      });
    }
    if (seconds < 0) {
      timer2?.cancel();
      startTimer();
      // Navigator.of(context).pop();
    } else {
      timerRef.set({
        'countdown': seconds,
        'room_duration': widget.roomsDetail.duration.inSeconds,
      });
      setState(() {
        countdownDuration = Duration(seconds: seconds);
      });
    }
  }

  // void stopTimer({bool resets = true}) {
  //   if (resets) {
  //     reset();
  //   }
  //   setState(() => timer1?.cancel());
  // }

  Widget showTimer() {
    // String twoDigits(int n) => n.toString().padLeft(2, '0');
    // final seconds = twoDigits(duration.inSeconds.remainder(60));
    final seconds = duration.inSeconds.toString();
    return Center(
      child: Text(
        seconds,
        style: GoogleFonts.orbitron(
          fontWeight: FontWeight.w600,
          fontSize: SizeConfig.textMultiplier * 13,
          color: const Color(0xFF44CC88),
        ),
      ),
    );
  }

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
            splashRadius: 1.0,
            onPressed: () {},
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFF6F6F7),
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: SizeConfig.heightMultiplier * 2,
                        ),
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
                        Text(
                          'Current Run',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: SizeConfig.textMultiplier * 5.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.heightMultiplier * 1.5,
                        ),
                        Column(
                          children: List.generate(
                              widget.roomsDetail.runs[widget.runNo - 1].length,
                              (index) {
                            return RoomCard(
                              roomNo: index + 1,
                              user1: widget
                                  .roomsDetail
                                  .runs[widget.runNo - 1][index]
                                  .participants[0],
                              user2: widget
                                  .roomsDetail
                                  .runs[widget.runNo - 1][index]
                                  .participants[1],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
