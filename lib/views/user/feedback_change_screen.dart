// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:know_better/components/button.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/services/auth_services.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/utilities/styles/size_config.dart';

class FeedbackChangeScreen extends StatefulWidget {
  final RoomsDetail roomsDetail;
  final List<Map<String, dynamic>?> feedback;
  const FeedbackChangeScreen({
    required this.roomsDetail,
    required this.feedback,
  });

  @override
  _FeedbackChangeScreenState createState() => _FeedbackChangeScreenState();
}

class _FeedbackChangeScreenState extends State<FeedbackChangeScreen> {
  List<Map<String, dynamic>?> feedback = [];
  // List<Widget> feedbackList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // feedback = widget.feedback;
    int index = widget.feedback.indexWhere((element) => element!['value'] == 3);
    while (index != -1) {
      feedback.add(widget.feedback[index]);
      index = widget.feedback
          .indexWhere((element) => element!['value'] == 3, index + 1);
    }
    index = widget.feedback.indexWhere((element) => element!['value'] == 2);
    while (index != -1) {
      feedback.add(widget.feedback[index]);
      index = widget.feedback
          .indexWhere((element) => element!['value'] == 2, index + 1);
    }
    index = widget.feedback.indexWhere((element) => element!['value'] == 1);
    while (index != -1) {
      feedback.add(widget.feedback[index]);
      index = widget.feedback
          .indexWhere((element) => element!['value'] == 1, index + 1);
    }
    index = widget.feedback.indexWhere((element) => element!['value'] == 0);
    while (index != -1) {
      feedback.add(widget.feedback[index]);
      index = widget.feedback
          .indexWhere((element) => element!['value'] == 0, index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Feedback',
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: SizeConfig.heightMultiplier * 100,
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: SizeConfig.heightMultiplier * 73,
                child: ReorderableListView(
                  children: feedback.map((item) {
                    if (item!.isNotEmpty) {
                      return Padding(
                        key: Key(item['to']['id'].toString()),
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.heightMultiplier * 0.7,
                        ),
                        child: Container(
                          height: SizeConfig.heightMultiplier * 10,
                          padding: EdgeInsets.all(
                            SizeConfig.imageSizeMultiplier * 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: SizeConfig.imageSizeMultiplier * 2,
                              ),
                              CircleAvatar(
                                radius: SizeConfig.imageSizeMultiplier * 7,
                                backgroundImage: NetworkImage(
                                  item['to']['image'].toString(),
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig.imageSizeMultiplier * 4,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['to']['full_name'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: SizeConfig.textMultiplier * 4,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: SizeConfig.heightMultiplier,
                                  ),
                                  Text(
                                    item['to']['title'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: SizeConfig.textMultiplier * 4,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              SizedBox(
                                width: SizeConfig.imageSizeMultiplier * 11,
                                // height:
                                //     SizeConfig.imageSizeMultiplier * 11.3,
                                child: item['image'] as Widget,
                              ),
                              SizedBox(
                                width: SizeConfig.imageSizeMultiplier * 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Container(
                      key: const Key('1'),
                    );
                  }).toList(),
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex > newIndex) {
                      final from = feedback[oldIndex]!['from'];
                      final to = feedback[oldIndex]!['to'];
                      setState(() {
                        feedback[oldIndex]!['from'] =
                            feedback[newIndex]!['from'];
                        feedback[oldIndex]!['to'] = feedback[newIndex]!['to'];
                        feedback[newIndex]!['from'] = from;
                        feedback[newIndex]!['to'] = to;
                      });
                    } else {
                      final from = feedback[oldIndex]!['from'];
                      final to = feedback[oldIndex]!['to'];
                      setState(() {
                        feedback[oldIndex]!['from'] =
                            feedback[newIndex - 1]!['from'];
                        feedback[oldIndex]!['to'] =
                            feedback[newIndex - 1]!['to'];
                        feedback[newIndex - 1]!['from'] = from;
                        feedback[newIndex - 1]!['to'] = to;
                      });
                    }
                  },
                ),
              ),
              Button(
                label: 'Update',
                onPressed: () async {
                  setState(() {
                    for (final element in feedback) {
                      element!.remove('image');
                    }
                  });
                  final uid = await AuthServices().getCurrentUID();
                  final changedFeedbackRef = RealtimeDatabase()
                      .database
                      .child(widget.roomsDetail.accessCode)
                      .child('changed_feedback');
                  changedFeedbackRef.update({uid: feedback});
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
