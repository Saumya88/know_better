// ignore_for_file: use_build_context_synchronously, unused_local_variable, sized_box_for_whitespace

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:know_better/components/form_button.dart';
import 'package:know_better/components/tile_widget.dart';
import 'package:know_better/models/room.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/views/user/feedback_change_screen.dart';
import 'package:know_better/views/user/feedback_game.dart';
import 'package:know_better/views/user/user_start_room_screen.dart';
import 'package:know_better/views/user/waiting_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class UserRoomDashboard extends StatefulWidget {
  static String id = 'AdminRoomDashboard';
  final RoomsDetail roomsDetail;
  const UserRoomDashboard({required this.roomsDetail});

  @override
  _UserRoomDashboardState createState() => _UserRoomDashboardState();
}

class _UserRoomDashboardState extends State<UserRoomDashboard> {
  // List<UserData> participants = [];
  List<List<Room>> runs = [];
  // Timer? timer;
  // Timer? timer1;
  bool haveResult = false;
  String networkGraphLink = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // startTimer1();
    // startTimer();
    final participantsRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('participants');
    final currentIndexRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('current_run');
    final runRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('run_detail')
        .child('runs');
    final linkRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('links');
    final allowChangeRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('allow_change');
    // List<String> participantsId = [];
    participantsRef.onValue.listen((event) {
      final data = List<String>.from(event.snapshot.value as List);
      // participantsId = List.generate(data.length, (index) => data[index]);
      // for (var uid in participantsId) {
      //   getUserData(uid);
      // }
      // print(participants);
      // final participantsData = List.generate(
      //     data.length, (index) => UserData.fromJson(json: data[index]));
      // print('data=$data');
      setState(() {
        widget.roomsDetail.participants = data;
      });
    });
    runRef.onValue.listen((event) {
      final List<List<Room>> rns = [];
      // print(event.snapshot.value);
      // if (event.snapshot.value.toString().compareTo('Runs') == 0) {
      //   print('yes');
      // } else {
      //   print('No');
      // }
      final data = event.snapshot.value as List;
      // final data = json['runs'] as List;
      final runsData = List.generate(data.length, (index) {
        final run = data[index] as List<dynamic>;

        // print('run = $run');
        final runsData = List.generate(run.length, (index) {
          final room = List<String>.from(run[index] as List);
          // print('room = $room');
          final users = List.generate(room.length, (index) {
            return room[index];
          });
          return users;
          // return jsonDecode(run[index].toString())
          //     as Map<String, dynamic>;
        });
        return runsData;
      });
      // print('run = $runsData');
      for (final run in runsData) {
        final List<Room> rooms = [];
        for (final room in run) {
          rooms.add(
            Room(
              adminId: widget.roomsDetail.adminID,
              creationTime: widget.roomsDetail.creationTime,
              duration: widget.roomsDetail.duration,
              participants: room,
            ),
          );
        }
        rns.add(rooms);
      }
      setState(() {
        runs = rns;
        widget.roomsDetail.runs = runs;
      });
    });
    currentIndexRef.onChildChanged.listen((event) async {
      final runNum = event.snapshot.value as int;
      final snapshot = await FirestoreDatabase().getUser();
      final json = snapshot.data()! as Map<String, dynamic>;
      final user = UserData.fromJson(json: json).toString();
      if (widget.roomsDetail.runs[runNum - 1]
          .any((element) => element.participants.contains(user))) {
        if (widget.roomsDetail.participants.length % 2 == 0) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return EvenUserStartRoomScreen(
                  roomsDetail: widget.roomsDetail,
                  runNo: runNum,
                );
              },
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return UserStartRoomScreen(
                  roomsDetail: widget.roomsDetail,
                  runNo: runNum,
                );
              },
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'You are not a participant in this Run. Wait for Next Run.'),
            duration: Duration(
              seconds: 10 + widget.roomsDetail.duration.inSeconds,
            ),
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return WaitingScreen(
                roomsDetail: widget.roomsDetail,
                runNo: runNum,
              );
            },
          ),
        );
      }
    });
    linkRef.onValue.listen((event) {
      final links = Map<String, String>.from(event.snapshot.value as Map);
      setState(() {
        networkGraphLink = links['network_graph'].toString();
        haveResult = true;
      });
    });
    allowChangeRef.onValue.listen((event) async {
      final allowChange = Map<String, bool>.from(event.snapshot.value as Map);
      if (allowChange['value']!) {
        final List<Map<String, dynamic>?> feedback = [];
        final feedbackRef = RealtimeDatabase()
            .database
            .child('/${widget.roomsDetail.accessCode}')
            .child('feedback');
        final snap = await feedbackRef.get();
        final data = Map<String, dynamic>.from(snap.value as Map);
        final snapshot = await FirestoreDatabase().getUser();
        final user = snapshot.data()! as Map<String, dynamic>;
        final userData = UserData.fromJson(json: user).toString();
        data.forEach((key, value) {
          final runData = List<Map>.from(value as List);
          // print('runData=$runData');
          final feedbackData = runData.map((val) {
            final Map<String, dynamic> mapData = {};
            // print('from=${val['from'].toString()}');
            if (val['from'].toString().compareTo(userData) == 0) {
              val.forEach((key, value) {
                final k = key as String;
                // print(k);
                if (k.compareTo('value') == 0) {
                  final v = value as String;
                  mapData[k] = int.parse(v);
                  if (int.parse(v) == 0) {
                    mapData['image'] = FeedbackCard(
                      card: Image.asset('assets/images/Red Card.png'),
                    );
                  } else if (int.parse(v) == 1) {
                    mapData['image'] = FeedbackCard(
                      card: Image.asset('assets/images/Yellow Card.png'),
                    );
                  } else if (int.parse(v) == 2) {
                    mapData['image'] = FeedbackCard(
                      card: Image.asset('assets/images/Green Card.png'),
                    );
                  } else {
                    mapData['image'] = FeedbackCard(
                      card: Image.asset('assets/images/Blue Card.png'),
                    );
                  }
                } else {
                  final v = value as String;
                  mapData[k] = jsonDecode(v);
                }
              });
            }
            return mapData;
          });
          for (int i = 0; i < feedbackData.length; i++) {
            if (feedbackData.elementAt(i).isNotEmpty) {
              feedback.add(feedbackData.elementAt(i));
            }
          }
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return FeedbackChangeScreen(
                roomsDetail: widget.roomsDetail,
                feedback: feedback,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // timer!.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  Future<int> showAlertDialog(BuildContext context) async {
    int result = 0;
    final AlertDialog alert = AlertDialog(
      title: const Text('Alert'),
      content: const Text('Do you want to exit from this room?'),
      actions: [
        TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop();
            result = 1;
          },
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop();
            result = 2;
          },
        ),
      ],
    );
    // show the dialog
    if (result == 0) {
      return 0;
    } else {
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.roomsDetail.name),
          leading: IconButton(
            iconSize: 1.0,
            splashRadius: 1.0,
            onPressed: () {},
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFF6F6F7),
            ),
          ),
          actions: runs.isEmpty
              ? [
                  IconButton(
                    onPressed: () async {
                      final res = await showAlertDialog(context);
                      if (res == 2) {
                        final database = FirebaseDatabase(
                          databaseURL:
                              'https://teamdynamics-a9ed1-default-rtdb.asia-southeast1.firebasedatabase.app',
                        ).reference();
                        final participantsRef =
                            database.child('/${widget.roomsDetail.accessCode}');
                        final snapshot = await FirestoreDatabase().getUser();
                        final json = snapshot.data()! as Map<String, dynamic>;
                        final userData =
                            UserData.fromJson(json: json).toString();
                        setState(() {
                          widget.roomsDetail.participants.remove(userData);
                          participantsRef.update({
                            'participants': widget.roomsDetail.participants,
                          });
                        });
                        Navigator.of(context).pop();
                        // Navigator.of(context).pop();
                      }
                      // else {
                      //   Navigator.of(context).pop();
                      // }
                    },
                    icon: const Icon(
                      Icons.exit_to_app_sharp,
                    ),
                  ),
                ]
              : haveResult
                  ? [
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Exit',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: SizeConfig.textMultiplier * 4,
                          ),
                        ),
                      ),
                    ]
                  : [],
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            // height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    // color: Colors.white,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: SizeConfig.heightMultiplier * 2,
                              ),
                              Text(
                                'Participants',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: SizeConfig.textMultiplier * 4.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.heightMultiplier * 1.5,
                              ),
                              const Divider(
                                color: Colors.black26,
                                thickness: 0.3,
                              ),
                              SizedBox(
                                height: SizeConfig.heightMultiplier * 1.5,
                              ),
                              // Column(),
                              Builder(
                                builder: (context) {
                                  if (widget
                                      .roomsDetail.participants.isNotEmpty) {
                                    return Container(
                                      height: SizeConfig.heightMultiplier * 50,
                                      child: ListView.builder(
                                        itemCount: widget
                                            .roomsDetail.participants.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 7.0,
                                            ),
                                            child: TileWidget(
                                              // uid: participants[index],
                                              data: widget.roomsDetail
                                                  .participants[index],
                                              index: index,
                                              // imageLink: widget.roomsDetail
                                              //     .participants[index].imageLink!,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      height: SizeConfig.heightMultiplier * 10,
                                      child: const Text(
                                        'No participant. Share Link to participants to join the room.',
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 3,
                  ),
                  Visibility(
                    visible: runs.isNotEmpty,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Text(
                            'Please Wait for admin to start run',
                            style: TextStyle(
                              color: const Color.fromRGBO(145, 145, 159, 1.0),
                              fontFamily: 'Inter',
                              fontSize: SizeConfig.textMultiplier * 3.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          // SizedBox(
                          //   width: SizeConfig.imageSizeMultiplier * 12,
                          // ),
                          SizedBox(
                            width: SizeConfig.imageSizeMultiplier * 15,
                            child: SpinKitThreeInOut(
                              color: const Color(0xFF44CC88),
                              size: SizeConfig.imageSizeMultiplier * 4,
                              duration: const Duration(
                                milliseconds: 800,
                              ),
                            ),
                          ),
                          // JumpingDotsProgressIndicator(
                          //   fontSize: 30.0,
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: runs.isEmpty,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Text(
                            'Wait for other participants to join',
                            style: TextStyle(
                              color: const Color.fromRGBO(145, 145, 159, 1.0),
                              fontFamily: 'Inter',
                              fontSize: SizeConfig.textMultiplier * 3.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          // SizedBox(
                          //   width: SizeConfig.imageSizeMultiplier * 12,
                          // ),
                          SizedBox(
                            width: SizeConfig.imageSizeMultiplier * 15,
                            child: SpinKitThreeInOut(
                              color: const Color(0xFF44CC88),
                              size: SizeConfig.imageSizeMultiplier * 4,
                              duration: const Duration(
                                milliseconds: 800,
                              ),
                            ),
                          ),
                          // JumpingDotsProgressIndicator(
                          //   fontSize: 30.0,
                          // ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 3,
                  ),
                  Visibility(
                    visible: haveResult,
                    child: FormButton(
                      label: 'Show Results',
                      color: const Color.fromRGBO(68, 204, 136, 1),
                      onPressed: () async {
                        // _showLoadingBar(context);
                        if (await canLaunch(networkGraphLink)) {
                          await launch(
                            networkGraphLink,
                            enableJavaScript: true,
                            forceSafariVC: true,
                            forceWebView: true,
                          );
                        } else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Some Error Occured.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
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
