// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:know_better/components/button.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/views/admin/admin_start_room_screen.dart';
import 'package:know_better/views/admin/admin_waiting_screen.dart';
import 'package:know_better/views/user/user_start_room_screen.dart';

class RunDashboard extends StatefulWidget {
  final RoomsDetail roomsDetail;
  final int runNo;
  // final List<Room> rooms;

  const RunDashboard({
    required this.roomsDetail,
    required this.runNo,
    // required this.rooms,
  });

  @override
  _RunDashboardState createState() => _RunDashboardState();
}

class _RunDashboardState extends State<RunDashboard> {
  int completedRun = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final feedbackRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('feedback');
    feedbackRef.onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      if (data['value'] != 0) {
        setState(() {
          completedRun = data.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Run ${widget.runNo}'),
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
                      // SizedBox(
                      //   height: SizeConfig.heightMultiplier * 2,
                      // ),
                      // Text(
                      //   'Run ${widget.runNo}',
                      //   textAlign: TextAlign.left,
                      //   style: TextStyle(
                      //     fontSize: SizeConfig.textMultiplier * 4.5,
                      //     fontWeight: FontWeight.w600,
                      //     fontFamily: 'Inter',
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: SizeConfig.heightMultiplier * 1.5,
                      // ),
                      Column(
                        children: List.generate(
                            widget.roomsDetail.runs[widget.runNo - 1].length,
                            (index) {
                          return RoomCard(
                            title: 'Room ${index + 1}',
                            roomNo: index + 1,
                            user1: widget.roomsDetail
                                .runs[widget.runNo - 1][index].participants[0],
                            user2: widget.roomsDetail
                                .runs[widget.runNo - 1][index].participants[1],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.heightMultiplier * 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Button(
                      label: 'Start Run',
                      color: completedRun == widget.runNo
                          ? Colors.white
                          : const Color(0xFF7861F7),
                      textColor: completedRun == widget.runNo
                          ? Colors.black
                          : Colors.white,
                      onPressed: () async {
                        _showLoadingBar(context);
                        if (completedRun != widget.runNo) {
                          RealtimeDatabase()
                              .startRun(widget.roomsDetail, widget.runNo);
                          if (widget.roomsDetail.adminAsParticipant) {
                            final snapshot =
                                await FirestoreDatabase().getUser();
                            final json =
                                snapshot.data()! as Map<String, dynamic>;
                            final user =
                                UserData.fromJson(json: json).toString();
                            if (widget.roomsDetail.runs[widget.runNo - 1].any(
                              (element) => element.participants.contains(user),
                            )) {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AdminStartRoomScreen(
                                      roomsDetail: widget.roomsDetail,
                                      runNo: widget.runNo,
                                    );
                                  },
                                ),
                              );
                            } else {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'You are not a participant in this Run. Wait for Next Run.',
                                  ),
                                  duration: Duration(
                                    seconds: 10 +
                                        widget.roomsDetail.duration.inSeconds,
                                  ),
                                ),
                              );
                              // ScaffoldMessenger.of(context)
                              //     .showSnackBar(SnackBar(
                              //   content: Text(
                              //       'Starting rooms. Wait for few seconds.'),
                              //   duration: Duration(seconds: 8),
                              // ));
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AdminWaitingScreen(
                                      roomsDetail: widget.roomsDetail,
                                      runNo: widget.runNo,
                                    );
                                  },
                                ),
                              );
                            }
                          } else {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return AdminWaitingScreen(
                                    roomsDetail: widget.roomsDetail,
                                    runNo: widget.runNo,
                                  );
                                },
                              ),
                            );
                          }
                        } else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Run is completed'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
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
