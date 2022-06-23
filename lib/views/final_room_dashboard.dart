// ignore_for_file: sized_box_for_whitespace

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:know_better/components/form_button.dart';
import 'package:know_better/components/tile_widget.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class FinalRoomDashboard extends StatefulWidget {
  static String id = 'FinalRoomDashboard';
  final String accessCode;
  // final RoomsDetail roomsDetail;
  const FinalRoomDashboard({required this.accessCode});
  // FinalRoomDashboard();

  @override
  _FinalRoomDashboardState createState() => _FinalRoomDashboardState();
}

class _FinalRoomDashboardState extends State<FinalRoomDashboard> {
  List<String> participants = [];
  // List<List<Room>> runs = [];
  // int completedRun = 0;
  // int runLength = 0;
  // int num = 0;
  // bool isRoomGenerated = false;
  // bool isFeedbackChanged = false;
  // bool adminChanged = false;
  // bool isPublished = false;
  // bool haveLink = false;
  String url = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<DocumentSnapshot> getData() async {
    final participantsSnapshot = await FirestoreDatabase()
        .roomDataCollection
        .doc(widget.accessCode)
        .collection('participants')
        .doc('participant_list')
        .get();
    final participantsList = List<Map<String, dynamic>>.from(
      participantsSnapshot.data()!['participants'] as List,
    );
    participants = participantsList.map((json) {
      return UserData(
        id: json['id'].toString(),
        fullName: json['full_name'].toString(),
        imageLink: json['image'].toString(),
        title: json['title'].toString(),
      ).toString();
    }).toList();
    final linksSnapshot = await FirestoreDatabase()
        .roomDataCollection
        .doc(widget.accessCode)
        .collection('links')
        .doc('network_graph')
        .get();
    url = linksSnapshot.data()!['link'] as String;
    return FirestoreDatabase().roomDataCollection.doc(widget.accessCode).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        } else {
          try {
            if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) {
              final detail =
                  Map<String, dynamic>.from(snapshot.data!.data()! as Map);
              final RoomsDetail roomsDetail = RoomsDetail(
                accessCode: widget.accessCode,
                name: detail['name'] as String,
                description: detail['description'] as String,
                runs: [],
                participants: participants,
                roomType: (detail['room_type'] as String)
                            .compareTo('RoomType.Physical') ==
                        0
                    ? RoomType.Physical
                    : RoomType.Virtual,
                activityType: (detail['activity_type'] as String)
                            .compareTo('ActivityType.Criticality') ==
                        0
                    ? ActivityType.Criticality
                    : (detail['activity_type'] as String)
                                .compareTo('ActivityType.TeamBuildUp') ==
                            0
                        ? ActivityType.TeamBuildUp
                        : ActivityType.CommunicationMatrix,
                creationTime: DateTime.parse(detail['creation_time'] as String),
                link: detail['link'] as String,
                adminAsParticipant: detail['admin_as_participants'] as bool,
                active: bool.fromEnvironment(detail['active'].toString()),
                duration: parseTime(detail['duration'] as String),
                adminID: detail['admin_id'] as String,
              );
              // final roomsDetail = RoomsDetail(accessCode: widget.accessCode, name: name, description: description, runs: runs, participants: participants, activityType: activityType, creationTime: creationTime, link: link, adminAsParticipant: adminAsParticipant, active: active, duration: duration, adminID: adminID)
              return Scaffold(
                appBar: AppBar(
                  title: Text(roomsDetail.name),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: SizeConfig.heightMultiplier * 2,
                                      ),
                                      Text(
                                        'Participants',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 4.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.heightMultiplier * 1.5,
                                      ),
                                      const Divider(
                                        color: Colors.black26,
                                        thickness: 0.3,
                                      ),
                                      SizedBox(
                                        height:
                                            SizeConfig.heightMultiplier * 1.5,
                                      ),
                                      // Column(),
                                      Builder(
                                        builder: (context) {
                                          if (participants.isNotEmpty) {
                                            return Container(
                                              height:
                                                  SizeConfig.heightMultiplier *
                                                      37,
                                              child: ListView.builder(
                                                itemCount: participants.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 7.0,
                                                    ),
                                                    child: TileWidget(
                                                      data: participants[index],
                                                      index: index,
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            return Container(
                                              height:
                                                  SizeConfig.heightMultiplier *
                                                      20,
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
                          FormButton(
                            label: 'Show Insights',
                            color: const Color.fromRGBO(68, 204, 136, 1),
                            onPressed: () async {
                              if (await canLaunch(url)) {
                                Navigator.of(context).pop();
                                await launch(
                                  url,
                                  enableJavaScript: true,
                                  forceSafariVC: true,
                                  forceWebView: true,
                                );
                              } else {
                                // Navigator.of(context).pop();
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
                        ],
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
          return const Scaffold();
        }
      },
    );
  }
}
