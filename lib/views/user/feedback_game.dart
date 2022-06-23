// ignore_for_file: constant_identifier_names, cast_nullable_to_non_nullable, use_build_context_synchronously, sized_box_for_whitespace, prefer_if_elements_to_conditional_expressions

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:know_better/components/form_button.dart';
import 'package:know_better/models/room.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/auth_services.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/styles/size_config.dart';

enum Title {
  No,
  Skip,
  Yes,
  Special,
}

List<String> questions = [
  "How much will your work role be impacted with this person's absence (leaving job)?",
  'What role would you like the person to play in your team?',
  'How much do you need to communicate with this person at your work place?',
];

List<List<String>> options = [
  [
    'Heavily Impacted',
    'Some Manageable Impact',
    'No Impact',
    'Removes Friction',
  ],
  [
    'Negative',
    'Not Match',
    'Team Member',
    'Co-Founder',
  ],
  [
    'Distraction',
    'Not Needed',
    'Necessary',
    'Critically Dependant',
  ],
];

class FeedbackGameScreen extends StatefulWidget {
  final RoomsDetail roomsDetail;
  final int runNo;
  final Room room;
  const FeedbackGameScreen({
    required this.room,
    required this.roomsDetail,
    required this.runNo,
  });

  @override
  _FeedbackGameScreenState createState() => _FeedbackGameScreenState();
}

class _FeedbackGameScreenState extends State<FeedbackGameScreen> {
  Map<String, int> mappedCards = {
    'Special': 0,
    'Yes': 0,
    'Skip': 0,
    'No': 0,
  };

  final redCard = Image.asset(
    'assets/images/Red Card.png',
  );
  final blueCard = Image.asset(
    'assets/images/Blue Card.png',
  );
  final greenCard = Image.asset(
    'assets/images/Green Card.png',
  );
  final yellowCard = Image.asset(
    'assets/images/Yellow Card.png',
  );

  Title? selectedTitle;
  UserData currentUserData = UserData();
  UserData userData = UserData();
  String uid1 = '';
  String uid2 = '';
  Color buttonColor = Colors.grey.shade300;

  Future<UserData> getUserData(String uid) async {
    final cardsRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('cards')
        .child(uid);
    final data = await cardsRef.get();
    mappedCards = Map<String, int>.from(data.value as Map);
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
    final messageRef = RealtimeDatabase()
        .database
        .child('/${widget.roomsDetail.accessCode}')
        .child('message');
    messageRef.onChildChanged.listen((event) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submit feedback. Admin is waiting...'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(246, 246, 246, 1),
        appBar: AppBar(
          title: const Text(
            'Feedback',
          ),
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
                  return SafeArea(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(height: SizeConfig.heightMultiplier * 4),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 1),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier * 4,
                                    ),
                                    Text(
                                      'Rate ${userData.fullName}',
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.textMultiplier * 4.5,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier * 2,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          questions[widget
                                              .roomsDetail.activityType.index],
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize:
                                                SizeConfig.textMultiplier * 4,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        SizedBox(
                                          height: SizeConfig.heightMultiplier,
                                        ),
                                        Visibility(
                                          visible: mappedCards['Special']! > 0,
                                          child: ListTile(
                                            title: Row(
                                              children: [
                                                // SizedBox(width: 20),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    right: SizeConfig
                                                        .textMultiplier,
                                                  ),
                                                  height: SizeConfig
                                                          .imageSizeMultiplier *
                                                      2.5,
                                                  width: SizeConfig
                                                          .imageSizeMultiplier *
                                                      2.5,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(0xFF7816F7),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(2.0),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      SizeConfig.textMultiplier,
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Special',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    options[widget.roomsDetail
                                                        .activityType.index][3],
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF2B2B2B),
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3.3,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            leading: Radio(
                                              value: Title.Special,
                                              groupValue: selectedTitle,
                                              onChanged: (Title? value) {
                                                setState(() {
                                                  selectedTitle = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: mappedCards['Yes']! > 0,
                                          child: ListTile(
                                            title: Row(
                                              children: [
                                                // SizedBox(width: 20),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    right: SizeConfig
                                                        .textMultiplier,
                                                  ),
                                                  height: SizeConfig
                                                          .imageSizeMultiplier *
                                                      2.5,
                                                  width: SizeConfig
                                                          .imageSizeMultiplier *
                                                      2.5,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(2.0),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      SizeConfig.textMultiplier,
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    options[widget.roomsDetail
                                                        .activityType.index][2],
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF2B2B2B),
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3.3,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            leading: Radio(
                                              value: Title.Yes,
                                              groupValue: selectedTitle,
                                              onChanged: (Title? value) {
                                                setState(() {
                                                  selectedTitle = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: mappedCards['Skip']! > 0,
                                          child: ListTile(
                                            title: Row(
                                              children: [
                                                // SizedBox(width: 20),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    right: SizeConfig
                                                        .textMultiplier,
                                                  ),
                                                  height: SizeConfig
                                                          .imageSizeMultiplier *
                                                      2.5,
                                                  width: SizeConfig
                                                          .imageSizeMultiplier *
                                                      2.5,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(2.0),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      SizeConfig.textMultiplier,
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Skip',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    options[widget.roomsDetail
                                                        .activityType.index][1],
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF2B2B2B),
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3.3,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            leading: Radio(
                                              value: Title.Skip,
                                              groupValue: selectedTitle,
                                              onChanged: (Title? value) {
                                                setState(() {
                                                  selectedTitle = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: mappedCards['No']! > 0,
                                          child: ListTile(
                                            title: Row(
                                              children: [
                                                // SizedBox(width: 20),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    right: SizeConfig
                                                        .textMultiplier,
                                                  ),
                                                  height: SizeConfig
                                                          .imageSizeMultiplier *
                                                      2.5,
                                                  width: SizeConfig
                                                          .imageSizeMultiplier *
                                                      2.5,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(2.0),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      SizeConfig.textMultiplier,
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'No',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    options[widget.roomsDetail
                                                        .activityType.index][0],
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF2B2B2B),
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3.3,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            leading: Radio(
                                              value: Title.No,
                                              groupValue: selectedTitle,
                                              onChanged: (Title? value) {
                                                setState(() {
                                                  selectedTitle = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: SizeConfig.heightMultiplier * 15,
                                    ),
                                    FormButton(
                                      label: 'Submit',
                                      onPressed: () async {
                                        if (selectedTitle != null) {
                                          mappedCards[selectedTitle
                                              .toString()
                                              .split('.')[1]] = mappedCards[
                                                  selectedTitle
                                                      .toString()
                                                      .split('.')[1]]! -
                                              1;
                                          await RealtimeDatabase()
                                              .database
                                              .child(
                                                '/${widget.roomsDetail.accessCode}',
                                              )
                                              .child('cards')
                                              .child(currentUserData.id)
                                              .set(mappedCards);
                                          List feedback = [];
                                          final feedbackData = {
                                            'from': currentUserData.toString(),
                                            'to': userData.toString(),
                                            'value':
                                                selectedTitle!.index.toString(),
                                          };
                                          final feedbackRef = RealtimeDatabase()
                                              .database
                                              .child(
                                                '/${widget.roomsDetail.accessCode}',
                                              )
                                              .child('feedback');
                                          final snapshot =
                                              await feedbackRef.get();
                                          final data =
                                              Map<String, dynamic>.from(
                                            snapshot.value as Map,
                                          );
                                          if (data['value'] == 0) {
                                            feedback = [feedbackData];
                                            feedbackRef.set({
                                              'run ${widget.runNo}': feedback
                                            });
                                          } else {
                                            if (data.length == widget.runNo) {
                                              final value =
                                                  data['run ${widget.runNo}']
                                                      as List;
                                              feedback = List.generate(
                                                  value.length, (index) {
                                                final feed =
                                                    Map<String, String>.from(
                                                  value[index] as Map,
                                                );
                                                return feed;
                                              });
                                              feedback.add(feedbackData);
                                              feedbackRef.update({
                                                'run ${widget.runNo}': feedback
                                              });
                                            } else {
                                              feedback = [feedbackData];
                                              feedbackRef.update({
                                                'run ${widget.runNo}': feedback
                                              });
                                            }
                                          }
                                          int count = 0;
                                          final uid = await AuthServices()
                                              .getCurrentUID();
                                          if (widget.roomsDetail.adminID
                                                  .compareTo(uid) ==
                                              0) {
                                            Navigator.popUntil(context,
                                                (route) {
                                              return count++ >= 4;
                                            });
                                          } else {
                                            Navigator.popUntil(context,
                                                (route) {
                                              return count++ >= 3;
                                            });
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('Select any Option'),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          height:
                                              SizeConfig.heightMultiplier * 4,
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height:
                                              SizeConfig.heightMultiplier * 15,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: SizeConfig
                                                        .imageSizeMultiplier *
                                                    2,
                                              ),
                                              Column(
                                                children: [
                                                  mappedCards['Special']! > 0
                                                      ? SizedBox(
                                                          width: SizeConfig
                                                                  .imageSizeMultiplier *
                                                              13,
                                                          child: FeedbackCard(
                                                            card: blueCard,
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          width: SizeConfig
                                                                  .imageSizeMultiplier *
                                                              13,
                                                          child: FeedbackCard(
                                                            card: Image.asset(
                                                              'assets/images/Blue Card BW.png',
                                                            ),
                                                          ),
                                                        ),
                                                  Text(
                                                    "Special x${mappedCards['Special']}",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: SizeConfig
                                                        .imageSizeMultiplier *
                                                    2,
                                              ),
                                              Column(
                                                children: [
                                                  mappedCards['Yes']! > 0
                                                      ? SizedBox(
                                                          width: SizeConfig
                                                                  .imageSizeMultiplier *
                                                              13,
                                                          child: FeedbackCard(
                                                            card: greenCard,
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          width: SizeConfig
                                                                  .imageSizeMultiplier *
                                                              13,
                                                          child: FeedbackCard(
                                                            card: Image.asset(
                                                              'assets/images/Green Card BW.png',
                                                            ),
                                                          ),
                                                        ),
                                                  Text(
                                                    "Yes x${mappedCards['Yes']}",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Column(
                                                children: [
                                                  mappedCards['Skip']! > 0
                                                      ? SizedBox(
                                                          width: SizeConfig
                                                                  .imageSizeMultiplier *
                                                              13,
                                                          child: FeedbackCard(
                                                            card: yellowCard,
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          width: SizeConfig
                                                                  .imageSizeMultiplier *
                                                              13,
                                                          child: FeedbackCard(
                                                            card: Image.asset(
                                                              'assets/images/Yellow Card BW.png',
                                                            ),
                                                          ),
                                                        ),
                                                  Text(
                                                    "Skip x${mappedCards['Skip']}",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: SizeConfig
                                                        .imageSizeMultiplier *
                                                    2,
                                              ),
                                              Column(
                                                children: [
                                                  mappedCards['No']! > 0
                                                      ? SizedBox(
                                                          width: SizeConfig
                                                                  .imageSizeMultiplier *
                                                              13,
                                                          child: FeedbackCard(
                                                            card: blueCard,
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          width: SizeConfig
                                                                  .imageSizeMultiplier *
                                                              13,
                                                          child: FeedbackCard(
                                                            card: Image.asset(
                                                              'assets/images/Red Card BW.png',
                                                            ),
                                                          ),
                                                        ),
                                                  Text(
                                                    "No x${mappedCards['No']}",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: SizeConfig
                                                              .textMultiplier *
                                                          3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: SizeConfig
                                                        .imageSizeMultiplier *
                                                    2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
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
}

class FeedbackCard extends StatelessWidget {
  final Image card;
  const FeedbackCard({
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: const Border(
          top: BorderSide(
            width: 3.0,
            color: Colors.white,
          ),
          bottom: BorderSide(
            width: 3.0,
            color: Colors.white,
          ),
          left: BorderSide(
            width: 3.0,
            color: Colors.white,
          ),
          right: BorderSide(
            width: 3.0,
            color: Colors.white,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: card,
      ),
    );
  }
}
