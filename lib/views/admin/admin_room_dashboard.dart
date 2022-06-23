// ignore_for_file: use_build_context_synchronously, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:know_better/components/form_button.dart';
import 'package:know_better/components/tile_widget.dart';
import 'package:know_better/models/room.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/views/admin/add_user_screen.dart';
import 'package:know_better/views/admin/run_dashboard.dart';
import 'package:know_better/views/user/feedback_change_screen.dart';
import 'package:know_better/views/user/feedback_game.dart';
import 'package:know_better/views/user_dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminRoomDashboard extends StatefulWidget {
  static String id = 'AdminRoomDashboard';
  final RoomsDetail roomsDetail;
  const AdminRoomDashboard({required this.roomsDetail});

  @override
  _AdminRoomDashboardState createState() => _AdminRoomDashboardState();
}

class _AdminRoomDashboardState extends State<AdminRoomDashboard> {
  // List<UserData> participants = [];
  List<List<Room>> runs = [];
  int completedRun = 0;
  int runLength = 0;
  int num = 0;
  bool isRoomGenerated = false;
  bool isFeedbackChanged = false;
  bool adminChanged = false;
  bool isPublished = false;
  bool haveLink = false;
  String url = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final participantsRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('participants');
    final feedbackRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('feedback');
    final changedFeedbackRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('changed_feedback');
    participantsRef.onValue.listen((event) {
      final data = List<String>.from(event.snapshot.value as List);
      setState(() {
        widget.roomsDetail.participants = data;
        runLength = data.length % 2 == 0 ? data.length : data.length - 1;
      });
    });
    changedFeedbackRef.onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      if (data.length == widget.roomsDetail.participants.length) {
        setState(() {
          isFeedbackChanged = true;
        });
      }
    });
    feedbackRef.onValue.listen((event) async {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      if (data['value'] != 0) {
        setState(() {
          completedRun = data.length;
        });
        final runFeedback = List<Map>.from(data['run $completedRun'] as List);
        setState(() {
          runLength = runFeedback.length;
        });
      }
    });
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return AddUserScreen(
                              roomsDetail: widget.roomsDetail,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                ]
              : isPublished
                  ? [
                      TextButton(
                        onPressed: () async {
                          final roomRef = RealtimeDatabase()
                              .database
                              .child('/${widget.roomsDetail.accessCode}');
                          await roomRef.remove();
                          int count = 0;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) {
                                return UserDashboard();
                              },
                            ),
                            (route) => count++ >= 6,
                          );
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
                    color: Colors.white,
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
                                  if (!widget.roomsDetail.participants
                                      .contains('None')) {
                                    return Container(
                                      height: SizeConfig.heightMultiplier * 37,
                                      child: ListView.builder(
                                        itemCount: widget
                                            .roomsDetail.participants.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 7.0,
                                            ),
                                            child: TileWidget(
                                              data: widget.roomsDetail
                                                  .participants[index],
                                              index: index,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      height: SizeConfig.heightMultiplier * 20,
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
                        Visibility(
                          visible: !isRoomGenerated &&
                              !widget.roomsDetail.participants.contains('None'),
                          child: FormButton(
                            label: 'Generate Duo Room',
                            onPressed: () async {
                              // timer!.cancel();
                              _showLoadingBar(context);
                              final List<List<Room>> rns = [];
                              if (widget.roomsDetail.participants.length >= 2) {
                                final res = await getData();
                                if (res.statusCode == 200 ||
                                    res.statusCode == 201) {
                                  final data = jsonDecode(res.body);
                                  final noOfRuns = data['No of runs'] as int;
                                  final runsData =
                                      List.generate(noOfRuns, (index) {
                                    final run = data['Run ${index + 1}']
                                        as List<dynamic>;
                                    final runsData =
                                        List.generate(run.length, (index) {
                                      final room =
                                          List<String>.from(run[index] as List);
                                      final users =
                                          List.generate(room.length, (index) {
                                        return room[index];
                                      });
                                      return users;
                                    });
                                    return runsData;
                                  });
                                  for (final run in runsData) {
                                    final List<Room> rooms = [];
                                    for (final room in run) {
                                      rooms.add(
                                        Room(
                                          adminId: widget.roomsDetail.adminID,
                                          creationTime:
                                              widget.roomsDetail.creationTime,
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
                                  setState(() {
                                    isRoomGenerated = true;
                                  });
                                  RealtimeDatabase()
                                      .updateRuns(widget.roomsDetail);
                                  RealtimeDatabase()
                                      .startRun(widget.roomsDetail, 0);
                                  RealtimeDatabase()
                                      .database
                                      .child(
                                        '/${widget.roomsDetail.accessCode}',
                                      )
                                      .child('rooms_detail')
                                      .child('active')
                                      .set('false');
                                  // print(runs);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error : ${res.statusCode}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      duration:
                                          const Duration(milliseconds: 800),
                                    ),
                                  );
                                }
                                // }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No. of Participants should be greater than 4',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    duration: Duration(milliseconds: 800),
                                  ),
                                );
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Visibility(
                        visible:
                            !(completedRun == runs.length && completedRun != 0),
                        child: Column(
                          children:
                              List.generate((runs.length + 1) ~/ 2, (index) {
                            if (runs.isNotEmpty) {
                              if (index == ((runs.length + 1) ~/ 2) - 1) {
                                return Column(
                                  children: [
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    Row(
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        RunWidget(
                                          visible: (2 * (index + 1) - 1) >
                                              completedRun,
                                          roomsDetail: widget.roomsDetail,
                                          number: 2 * (index + 1) - 1,
                                          check: runLength ==
                                              ((widget.roomsDetail.participants
                                                              .length %
                                                          2 ==
                                                      0)
                                                  ? widget.roomsDetail
                                                      .participants.length
                                                  : widget.roomsDetail
                                                          .participants.length -
                                                      1),
                                          validate: () {
                                            return (2 * (index + 1) - 1) >
                                                (completedRun + 1);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RunWidget(
                                        visible: (2 * (index + 1) - 1) >
                                            completedRun,
                                        roomsDetail: widget.roomsDetail,
                                        number: 2 * (index + 1) - 1,
                                        check: runLength ==
                                            ((widget.roomsDetail.participants
                                                            .length %
                                                        2 ==
                                                    0)
                                                ? widget.roomsDetail
                                                    .participants.length
                                                : widget.roomsDetail
                                                        .participants.length -
                                                    1),
                                        validate: () {
                                          return (2 * (index + 1) - 1) >
                                              (completedRun + 1);
                                        },
                                      ),
                                      const SizedBox(
                                        width: 20.0,
                                      ),
                                      RunWidget(
                                        visible:
                                            (2 * (index + 1)) > completedRun,
                                        roomsDetail: widget.roomsDetail,
                                        number: 2 * (index + 1),
                                        check: runLength ==
                                            ((widget.roomsDetail.participants
                                                            .length %
                                                        2 ==
                                                    0)
                                                ? widget.roomsDetail
                                                    .participants.length
                                                : widget.roomsDetail
                                                        .participants.length -
                                                    1),
                                        validate: () {
                                          return (2 * (index + 1)) >
                                              (completedRun + 1);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return Container();
                          }),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.heightMultiplier * 3,
                      ),
                      Visibility(
                        visible:
                            completedRun == runs.length && completedRun != 0,
                        child: Container(
                          width: double.infinity,
                          height: SizeConfig.heightMultiplier * 5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: const Center(
                            child: Text(
                              'All Runs are completed.',
                              style: TextStyle(
                                color: Color.fromRGBO(145, 145, 159, 1.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.heightMultiplier * 3,
                      ),
                      Visibility(
                        visible: completedRun == runs.length &&
                            completedRun != 0 &&
                            runLength ==
                                ((widget.roomsDetail.participants.length % 2 ==
                                        0)
                                    ? widget.roomsDetail.participants.length
                                    : widget.roomsDetail.participants.length -
                                        1) &&
                            !isFeedbackChanged,
                        child: FormButton(
                          color: const Color.fromRGBO(68, 204, 136, 1),
                          label: 'Allow Edit Feedback',
                          onPressed: () async {
                            // print('isPublished=$isPublished');
                            // print('changedFeedback=$isFeedbackChanged');
                            // print('haveLink=$haveLink');
                            if (adminChanged) {
                              num++;
                              RealtimeDatabase()
                                  .database
                                  .child(widget.roomsDetail.accessCode)
                                  .child('message')
                                  .set({'value': num});
                            } else {
                              final List<Map<String, dynamic>?> feedback = [];
                              final allowChangeRef = RealtimeDatabase()
                                  .database
                                  .child('/${widget.roomsDetail.accessCode}')
                                  .child('allow_change');
                              final feedbackRef = RealtimeDatabase()
                                  .database
                                  .child('/${widget.roomsDetail.accessCode}')
                                  .child('feedback');
                              final snap = await feedbackRef.get();
                              final data =
                                  Map<String, dynamic>.from(snap.value as Map);
                              final snapshot =
                                  await FirestoreDatabase().getUser();
                              final user =
                                  snapshot.data()! as Map<String, dynamic>;
                              final userData =
                                  UserData.fromJson(json: user).toString();
                              data.forEach((key, value) {
                                final runData = List<Map>.from(value as List);
                                // print('runData=$runData');
                                final feedbackData = runData.map((val) {
                                  final Map<String, dynamic> mapData = {};
                                  // print('from=${val['from'].toString()}');
                                  if (val['from']
                                          .toString()
                                          .compareTo(userData) ==
                                      0) {
                                    val.forEach((key, value) {
                                      final k = key as String;
                                      // print(k);
                                      if (k.compareTo('value') == 0) {
                                        final v = value as String;
                                        mapData[k] = int.parse(v);
                                        if (int.parse(v) == 0) {
                                          mapData['image'] = FeedbackCard(
                                            card: Image.asset(
                                              'assets/images/Red Card.png',
                                            ),
                                          );
                                        } else if (int.parse(v) == 1) {
                                          mapData['image'] = FeedbackCard(
                                            card: Image.asset(
                                              'assets/images/Yellow Card.png',
                                            ),
                                          );
                                        } else if (int.parse(v) == 2) {
                                          mapData['image'] = FeedbackCard(
                                            card: Image.asset(
                                              'assets/images/Green Card.png',
                                            ),
                                          );
                                        } else {
                                          mapData['image'] = FeedbackCard(
                                            card: Image.asset(
                                              'assets/images/Blue Card.png',
                                            ),
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
                              await allowChangeRef.set({'value': true});
                              if (widget.roomsDetail.adminAsParticipant) {
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
                              setState(() {
                                adminChanged = true;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.heightMultiplier * 3,
                      ),
                      Visibility(
                        visible: completedRun == runs.length &&
                            completedRun != 0 &&
                            !isPublished &&
                            isFeedbackChanged &&
                            !haveLink,
                        child: FormButton(
                          label: 'Generate Insights',
                          color: const Color.fromRGBO(68, 204, 136, 1),
                          onPressed: () async {
                            _showLoadingBar(context);
                            await FirestoreDatabase()
                                .roomDataCollection
                                .doc(widget.roomsDetail.accessCode)
                                .set({
                              'access_code': widget.roomsDetail.accessCode,
                              'name': widget.roomsDetail.name,
                              'description': widget.roomsDetail.description,
                              'room_type':
                                  widget.roomsDetail.roomType.toString(),
                              'activity_type':
                                  widget.roomsDetail.activityType.toString(),
                              'link': widget.roomsDetail.link,
                              'admin_as_participants':
                                  widget.roomsDetail.adminAsParticipant,
                              'active': widget.roomsDetail.active,
                              'creation_time':
                                  widget.roomsDetail.creationTime.toString(),
                              'duration':
                                  widget.roomsDetail.duration.toString(),
                              'admin_id': widget.roomsDetail.adminID,
                            });
                            final feedbackRef = RealtimeDatabase()
                                .database
                                .child('/${widget.roomsDetail.accessCode}')
                                .child('feedback');
                            final feedbackSnap = await feedbackRef.get();
                            final feedbackData = Map<String, dynamic>.from(
                              feedbackSnap.value as Map,
                            );
                            feedbackData.forEach((key, value) async {
                              final runData = List<Map>.from(value as List);
                              final feedbackData = runData.map((val) {
                                final Map<String, dynamic> mapData = {};
                                val.forEach((key, value) {
                                  final k = key as String;
                                  // print(k);
                                  if (k.compareTo('value') == 0) {
                                    final v = value as String;
                                    mapData[k] = int.parse(v);
                                  } else {
                                    final v = value as String;
                                    mapData[k] = jsonDecode(v);
                                  }
                                });
                                return mapData;
                              });
                              await FirestoreDatabase()
                                  .roomDataCollection
                                  .doc(widget.roomsDetail.accessCode)
                                  .collection('feedback')
                                  .doc(key)
                                  .set({key: feedbackData.toList()});
                            });
                            final changedFeedbackRef = RealtimeDatabase()
                                .database
                                .child('/${widget.roomsDetail.accessCode}')
                                .child('changed_feedback');
                            final changedFeedbackSnap =
                                await changedFeedbackRef.get();
                            final changedFeedbackData =
                                Map<String, dynamic>.from(
                              changedFeedbackSnap.value as Map,
                            );
                            changedFeedbackData.forEach((key, value) async {
                              final runData = List<Map>.from(value as List);
                              final feedbackData = runData.map((val) {
                                final Map<String, dynamic> mapData = {};
                                val.forEach((key, value) {
                                  final k = key as String;
                                  // print(k);
                                  if (k.compareTo('value') == 0) {
                                    // final v = value as String;
                                    mapData[k] = value;
                                  } else {
                                    // final v = value as String;
                                    mapData[k] = value;
                                  }
                                });
                                return mapData;
                              });
                              await FirestoreDatabase()
                                  .roomDataCollection
                                  .doc(widget.roomsDetail.accessCode)
                                  .collection('changed_feedback')
                                  .doc(key)
                                  .set({key: feedbackData.toList()});
                            });
                            final participantsRef = RealtimeDatabase()
                                .database
                                .child('/${widget.roomsDetail.accessCode}')
                                .child('participants');
                            final participantSnap = await participantsRef.get();
                            final participantsData = List<String>.from(
                              participantSnap.value as List,
                            );
                            final participantsList =
                                participantsData.map((participant) {
                              return Map<String, dynamic>.from(
                                jsonDecode(participant) as Map,
                              );
                            });
                            await FirestoreDatabase()
                                .roomDataCollection
                                .doc(widget.roomsDetail.accessCode)
                                .collection('participants')
                                .doc('participant_list')
                                .set({
                              'participants': participantsList.toList()
                            });
                            final runDetailRef = RealtimeDatabase()
                                .database
                                .child('/${widget.roomsDetail.accessCode}')
                                .child('run_detail')
                                .child('runs');
                            final runDetailSnap = await runDetailRef.get();
                            final runDetailData = runDetailSnap.value as List;
                            final runDetail = runDetailData.map((item) {
                              final runs = item as List;
                              return runs.map((item) {
                                final rooms = List<String>.from(item as List);
                                return rooms;
                              }).toList();
                            }).toList();
                            for (int i = 0; i < runDetail.length; i++) {
                              for (int j = 0; j < runDetail[i].length; j++) {
                                await FirestoreDatabase()
                                    .roomDataCollection
                                    .doc(widget.roomsDetail.accessCode)
                                    .collection('run_detail')
                                    .doc('run ${i + 1}')
                                    .set(
                                  {'room ${j + 1}': runDetailData[i][j]},
                                );
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Data Saved.',
                                ),
                              ),
                            );
                            final List<Map<String, dynamic>> feedback = [];
                            final List<String> participants = [];
                            final snap = await changedFeedbackRef.get();
                            final data =
                                Map<String, dynamic>.from(snap.value as Map);
                            // final finalData = jsonDecode(snap.value.toString());
                            data.forEach((key, value) {
                              final runData = List<Map>.from(value as List);
                              final feedbackData = runData.map((val) {
                                final Map<String, dynamic> mapData = {};
                                val.forEach((key, value) {
                                  final k = key as String;
                                  if (k.compareTo('value') == 0) {
                                    mapData[k] = value;
                                  } else {
                                    final v =
                                        Map<String, dynamic>.from(value as Map);
                                    mapData[k] = v['full_name'].toString();
                                  }
                                });
                                return mapData;
                              });
                              feedback.addAll(feedbackData);
                            });
                            for (final user
                                in widget.roomsDetail.participants) {
                              final userData = Map<String, String>.from(
                                jsonDecode(user) as Map,
                              );
                              final userName = userData['full_name']!;
                              participants.add(userName);
                            }
                            final res = await http.post(
                              Uri.parse(
                                'https://teamdynamics.getboarded.tech/network_graph',
                              ),
                              headers: {
                                'Content-Type': 'application/json',
                              },
                              body: jsonEncode({
                                'room_id': widget.roomsDetail.accessCode,
                                'activity': widget.roomsDetail.activityType
                                    .toString()
                                    .split('.')[1],
                                'participants': participants,
                                'feedback': feedback,
                              }),
                            );
                            if (res.statusCode == 200 ||
                                res.statusCode == 201) {
                              final data = jsonDecode(res.body);
                              setState(() {
                                url = 'https://${data['url'].toString()}';
                              });
                              setState(() {
                                haveLink = true;
                              });
                              await FirestoreDatabase()
                                  .roomDataCollection
                                  .doc(widget.roomsDetail.accessCode)
                                  .collection('links')
                                  .doc('network_graph')
                                  .set({'link': url});
                              Navigator.of(context).pop();
                              // await launch(url);
                              // if (await canLaunch(url)) {
                              //   await launch(
                              //     url,
                              //     enableJavaScript: true,
                              //     forceSafariVC: true,
                              //     forceWebView: true,
                              //   );
                              // }
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
                      Visibility(
                        visible: completedRun == runs.length &&
                            completedRun != 0 &&
                            !isPublished &&
                            isFeedbackChanged &&
                            haveLink,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: SizeConfig.imageSizeMultiplier * 45,
                              child: FormButton(
                                label: 'Show Insights',
                                color: const Color.fromRGBO(68, 204, 136, 1),
                                onPressed: () async {
                                  _showLoadingBar(context);
                                  if (await canLaunch(url)) {
                                    Navigator.of(context).pop();
                                    await launch(
                                      url,
                                      enableJavaScript: true,
                                      forceSafariVC: true,
                                      forceWebView: true,
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Result is published to all users.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              width: SizeConfig.imageSizeMultiplier * 45,
                              child: FormButton(
                                label: 'Publish Results',
                                color: const Color.fromRGBO(68, 204, 136, 1),
                                onPressed: () async {
                                  _showLoadingBar(context);
                                  final linkRef = RealtimeDatabase()
                                      .database
                                      .child(
                                        '/${widget.roomsDetail.accessCode}',
                                      )
                                      .child('links');
                                  await linkRef.set({
                                    'network_graph': url,
                                  });
                                  setState(() {
                                    isPublished = true;
                                  });
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Result is published to all users.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: isPublished,
                        child: FormButton(
                          label: 'Show Insights',
                          color: const Color.fromRGBO(68, 204, 136, 1),
                          onPressed: () async {
                            _showLoadingBar(context);
                            if (await canLaunch(url)) {
                              Navigator.of(context).pop();
                              await launch(
                                url,
                                enableJavaScript: true,
                                forceSafariVC: true,
                                forceWebView: true,
                              );
                            } else {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Result is published to all users.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.heightMultiplier * 3,
                      ),
                    ],
                  ),
                ],
              ),
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

  Future<http.Response> getData() async {
    return http.post(
      Uri.parse('https://teamdynamics.getboarded.tech/unique_duo_groups'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, List<String>>{
        'participants': widget.roomsDetail.participants,
      }),
    );
  }
}

// ignore: must_be_immutable
class RunWidget extends StatelessWidget {
  final bool Function() validate;
  final bool visible;
  final RoomsDetail roomsDetail;
  final int number;
  final bool check;
  int num = 0;
  // final List<List<Room>> runs;
  RunWidget({
    required this.visible,
    required this.roomsDetail,
    required this.number,
    required this.validate,
    required this.check,
    // required this.runs,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // print(runs);
        if (visible) {
          if (check) {
            if (!validate()) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return RunDashboard(
                      roomsDetail: roomsDetail,
                      runNo: number,
                      // rooms: runs[number - 1],
                    );
                  },
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Previous Runs yet not completed.'),
                ),
              );
            }
          } else {
            num++;
            RealtimeDatabase()
                .database
                .child(roomsDetail.accessCode)
                .child('message')
                .set({'value': num});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'All feedbacks of previous Runs are not submitted yet.'),
                action: SnackBarAction(
                  label: 'Skip',
                  textColor: Colors.red,
                  onPressed: () {},
                ),
              ),
            );
          }
        }
      },
      child: Container(
        // height: SizeConfig.heightMultiplier * 2,
        padding: const EdgeInsets.all(15.0),
        width: MediaQuery.of(context).size.width / 2.3,
        decoration: BoxDecoration(
          color: visible ? Colors.white : const Color(0xFFF6F6F7),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          'Run $number',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: SizeConfig.textMultiplier * 4,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
