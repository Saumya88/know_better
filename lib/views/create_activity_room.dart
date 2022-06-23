// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:random_string/random_string.dart';
import 'package:know_better/components/button.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/auth_services.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/services/dynamic_link.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/utilities/styles/styling.dart';
import 'package:know_better/utilities/styles/user.dart';
import 'package:know_better/utilities/styles/video_calling.dart';
import 'package:know_better/views/admin/admin_room_dashboard.dart';

class RoomTypeScreen extends StatefulWidget {
  static String id = 'RoomTypeScreen';
  const RoomTypeScreen();

  @override
  State<RoomTypeScreen> createState() => _RoomTypeScreenState();
}

class _RoomTypeScreenState extends State<RoomTypeScreen> {
  bool isVirtual = false;
  bool isPhysical = false;
  RoomsDetail roomsDetail = RoomsDetail(
    accessCode: '',
    name: '',
    description: '',
    runs: [],
    participants: [],
    activityType: ActivityType.TeamBuildUp,
    creationTime: DateTime.now(),
    link: '',
    adminAsParticipant: true,
    active: true,
    // ignore: prefer_const_constructors
    duration: Duration(),
    adminID: '',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity Room'),
      ),
      body: SafeArea(
        child: Container(
          width: SizeConfig.imageSizeMultiplier * 100,
          height: SizeConfig.heightMultiplier * 100,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: SizeConfig.heightMultiplier * 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(
                        SizeConfig.heightMultiplier * 1.78,
                        SizeConfig.heightMultiplier * 10.41,
                        SizeConfig.heightMultiplier * 1.78,
                        SizeConfig.heightMultiplier * 0.29,
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'Select Interaction Mode',
                              style: TextStyle(
                                fontSize: SizeConfig.heightMultiplier * 3.27,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.heightMultiplier * 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RoomTypeButton(
                                value: RoomType.Virtual,
                                icon: VirtualRoom.video_calling,
                                isSelected: isVirtual,
                                onTap: () {
                                  if (roomsDetail.roomType == null) {
                                    setState(() {
                                      roomsDetail.roomType = RoomType.Virtual;
                                      isVirtual = true;
                                      isPhysical = false;
                                    });
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return RoomNameScreen(
                                            roomsDetail: roomsDetail,
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      roomsDetail.roomType = RoomType.Virtual;
                                      isVirtual = true;
                                      isPhysical = false;
                                    });
                                  }
                                },
                              ),
                              RoomTypeButton(
                                value: RoomType.Physical,
                                icon: PhysicalRoom.users,
                                isSelected: isPhysical,
                                onTap: () {
                                  if (roomsDetail.roomType == null) {
                                    setState(() {
                                      roomsDetail.roomType = RoomType.Physical;
                                      isVirtual = false;
                                      isPhysical = true;
                                    });
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return RoomNameScreen(
                                            roomsDetail: roomsDetail,
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      roomsDetail.roomType = RoomType.Physical;
                                      isVirtual = false;
                                      isPhysical = true;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.heightMultiplier * 5,
                          ),

                          // Button(
                          //   label: 'Next',
                          //   onPressed: () {
                          //     if (!isPhysical && !isVirtual) {
                          //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //         content: Text('Select Room Type'),
                          //       ));
                          //     } else {
                          //       roomsDetail.roomType =
                          //           isVirtual ? RoomType.Virtual : RoomType.Physical;
                          //       Navigator.of(context).push(MaterialPageRoute(
                          //         builder: (context) {
                          //           return RoomNameScreen(
                          //             roomsDetail: roomsDetail,
                          //           );
                          //         },
                          //       ));
                          //     }
                          //   },
                          //   color: kGreenButtonColor,
                          //   textColor: Colors.white,
                          // ),
                        ],
                      ),
                    ),
                  ),
                  // Spacer(),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: SizeConfig.imageSizeMultiplier * 15,
                          width: SizeConfig.imageSizeMultiplier * 15,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(192, 192, 192, 1.0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 29.0,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          height: SizeConfig.imageSizeMultiplier * 15,
                          width: SizeConfig.imageSizeMultiplier * 15,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(68, 204, 136, 1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            // padding: EdgeInsets.only(
                            //   left: 8.0,
                            // ),
                            onPressed: () {
                              if (!isPhysical && !isVirtual) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Select Room Type'),
                                  ),
                                );
                              } else {
                                roomsDetail.roomType = isVirtual
                                    ? RoomType.Virtual
                                    : RoomType.Physical;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return RoomNameScreen(
                                        roomsDetail: roomsDetail,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_forward,
                              size: 29.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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

class RoomTypeButton extends StatefulWidget {
  final IconData? icon;
  final RoomType value;
  final Function()? onTap;
  final bool isSelected;
  const RoomTypeButton({
    required this.value,
    required this.icon,
    this.isSelected = true,
    this.onTap,
  });

  @override
  State<RoomTypeButton> createState() => _RoomTypeButtonState();
}

class _RoomTypeButtonState extends State<RoomTypeButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.imageSizeMultiplier * 37,
      height: SizeConfig.heightMultiplier * 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: widget.isSelected
            ? const Color.fromRGBO(68, 204, 136, 1.0)
            : const Color.fromRGBO(68, 204, 136, 0.2),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: SizeConfig.imageSizeMultiplier * 10,
              height: SizeConfig.heightMultiplier * 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: widget.isSelected
                    ? const Color.fromRGBO(255, 255, 255, 0.2)
                    : const Color.fromRGBO(255, 255, 255, 0.8),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? Colors.white
                      : const Color.fromRGBO(68, 204, 136, 1.0),
                ),
              ),
            ),
            Text(
              widget.value.toString().split('.')[1],
              style: TextStyle(
                fontSize: SizeConfig.textMultiplier * 4.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
                color: widget.isSelected
                    ? Colors.white
                    : const Color.fromRGBO(68, 204, 136, 1.0),
              ),
            ),
            SizedBox(
              width: SizeConfig.imageSizeMultiplier * 0.7,
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class RoomNameScreen extends StatelessWidget {
  final RoomsDetail roomsDetail;
  RoomNameScreen({
    required this.roomsDetail,
  });
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity Room'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: SizeConfig.heightMultiplier * 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(
                      SizeConfig.heightMultiplier * 1.78,
                      SizeConfig.heightMultiplier * 10.41,
                      SizeConfig.heightMultiplier * 1.78,
                      SizeConfig.heightMultiplier * 0.29,
                    ),
                    child: Column(
                      children: [
                        const Center(
                          child: Text(
                            'Activity Room Name',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.heightMultiplier * 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 50),
                          child: Material(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            child: TextFormField(
                              decoration: kInputDecoration.copyWith(
                                fillColor: const Color(0xFFF6F6F7),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    if (controller.text.isNotEmpty) {
                                      roomsDetail.name = controller.text;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return RoomDurationScreen(
                                              roomsDetail: roomsDetail,
                                            );
                                          },
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Enter Room Name'),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    color: Color(0xFF7816F7),
                                  ),
                                ),
                                hintText: 'Enter Room Name',
                              ),
                              onFieldSubmitted: (String? value) {
                                if (controller.text.isNotEmpty) {
                                  roomsDetail.name = controller.text;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return RoomDurationScreen(
                                          roomsDetail: roomsDetail,
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Enter Room Name'),
                                    ),
                                  );
                                }
                              },
                              controller: controller,
                            ),
                          ),
                        ),
                        // Button(
                        //   label: 'Next',
                        //   onPressed: () {
                        //     if (controller.text.isNotEmpty) {
                        //       roomsDetail.name = controller.text;
                        //       Navigator.of(context).push(MaterialPageRoute(
                        //         builder: (context) {
                        //           return RoomDurationScreen(
                        //             roomsDetail: roomsDetail,
                        //           );
                        //         },
                        //       ));
                        //     } else {
                        //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //         content: Text('Enter Room Name'),
                        //       ));
                        //     }
                        //   },
                        //   color: kGreenButtonColor,
                        //   textColor: Colors.white,
                        // ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.heightMultiplier * 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: SizeConfig.imageSizeMultiplier * 15,
                        width: SizeConfig.imageSizeMultiplier * 15,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(68, 204, 136, 1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          // padding: EdgeInsets.only(
                          //   right: 8.0,
                          // ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 29.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        height: SizeConfig.imageSizeMultiplier * 15,
                        width: SizeConfig.imageSizeMultiplier * 15,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(68, 204, 136, 1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          // padding: EdgeInsets.only(
                          //   left: 8.0,
                          // ),
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              roomsDetail.name = controller.text;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return RoomDurationScreen(
                                      roomsDetail: roomsDetail,
                                    );
                                  },
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Enter Room Name'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 29.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Create Activity Room'),
  //     ),
  //     body: SafeArea(
  //       child: Container(
  //         width: double.infinity,
  //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         child: SingleChildScrollView(
  //           child: Container(
  //             width: double.infinity,
  //             // height: SizeConfig.heightMultiplier * 40,
  //             margin: EdgeInsets.fromLTRB(12, 100, 12, 2),
  //             child: Column(
  //               children: [
  //                 Center(
  //                   child: Text(
  //                     'Activity Room Name',
  //                     style: const TextStyle(
  //                         fontSize: 22, fontWeight: FontWeight.w500),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: SizeConfig.heightMultiplier * 10,
  //                 ),
  //                 Padding(
  //                   padding: EdgeInsets.fromLTRB(15, 0, 15, 50),
  //                   child: TextFormField(
  //                     decoration: InputDecoration(
  //                       suffixIcon: IconButton(
  //                           onPressed: () {
  //                             if (controller.text.isNotEmpty) {
  //                               roomsDetail.name = controller.text;
  //                               Navigator.of(context).push(MaterialPageRoute(
  //                                 builder: (context) {
  //                                   return RoomDurationScreen(
  //                                     roomsDetail: roomsDetail,
  //                                   );
  //                                 },
  //                               ));
  //                             } else {
  //                               ScaffoldMessenger.of(context)
  //                                   .showSnackBar(SnackBar(
  //                                 content: Text('Enter Room Name'),
  //                               ));
  //                             }
  //                           },
  //                           icon: Icon(
  //                             Icons.arrow_forward,
  //                             color: Color(0xFF7816F7),
  //                           )),
  //                       enabledBorder: UnderlineInputBorder(
  //                         borderSide: BorderSide(color: Colors.black),
  //                       ),
  //                       focusedBorder: UnderlineInputBorder(
  //                         borderSide: BorderSide(color: Colors.black),
  //                       ),
  //                       border: UnderlineInputBorder(
  //                         borderSide: BorderSide(color: Colors.black),
  //                       ),
  //                       hintText: 'Enter Room Name',
  //                     ),
  //                     onFieldSubmitted: (String? value) {
  //                       if (controller.text.isNotEmpty) {
  //                         roomsDetail.name = controller.text;
  //                         Navigator.of(context).push(MaterialPageRoute(
  //                           builder: (context) {
  //                             return RoomDurationScreen(
  //                               roomsDetail: roomsDetail,
  //                             );
  //                           },
  //                         ));
  //                       } else {
  //                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                           content: Text('Enter Room Name'),
  //                         ));
  //                       }
  //                     },
  //                     controller: controller,
  //                   ),
  //                 ),
  //                 // Button(
  //                 //   label: 'Next',
  //                 //   onPressed: () {
  //                 //     if (controller.text.isNotEmpty) {
  //                 //       roomsDetail.name = controller.text;
  //                 //       Navigator.of(context).push(MaterialPageRoute(
  //                 //         builder: (context) {
  //                 //           return RoomDurationScreen(
  //                 //             roomsDetail: roomsDetail,
  //                 //           );
  //                 //         },
  //                 //       ));
  //                 //     } else {
  //                 //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                 //         content: Text('Enter Room Name'),
  //                 //       ));
  //                 //     }
  //                 //   },
  //                 //   color: kGreenButtonColor,
  //                 //   textColor: Colors.white,
  //                 // ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

// ignore: must_be_immutable
class RoomDescriptionScreen extends StatelessWidget {
  final RoomsDetail roomsDetail;
  RoomDescriptionScreen({
    required this.roomsDetail,
  });
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity Room'),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: SizeConfig.heightMultiplier * 40,
              margin: const EdgeInsets.fromLTRB(12, 100, 12, 2),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Activity Room Description',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 50),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(),
                        border: UnderlineInputBorder(),
                        hintText: 'Enter Room Description',
                      ),
                      controller: controller,
                    ),
                  ),
                  Button(
                    label: 'Next',
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        roomsDetail.description = controller.text;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return RoomDurationScreen(
                                roomsDetail: roomsDetail,
                              );
                            },
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter Room Description'),
                          ),
                        );
                      }
                    },
                    color: kGreenButtonColor,
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

class RoomDurationScreen extends StatefulWidget {
  final RoomsDetail roomsDetail;
  const RoomDurationScreen({
    required this.roomsDetail,
  });

  @override
  State<RoomDurationScreen> createState() => _RoomDurationScreenState();
}

class _RoomDurationScreenState extends State<RoomDurationScreen> {
  // ignore: prefer_const_constructors
  Duration duration = Duration();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity Room'),
      ),
      body: SafeArea(
        child: Container(
          width: SizeConfig.imageSizeMultiplier * 100,
          height: SizeConfig.heightMultiplier * 100,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: SizeConfig.heightMultiplier * 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(
                        SizeConfig.heightMultiplier * 1.78,
                        SizeConfig.heightMultiplier * 3.41,
                        SizeConfig.heightMultiplier * 1.78,
                        SizeConfig.heightMultiplier * 0.29,
                      ),
                      child: Column(
                        children: [
                          const Center(
                            child: Text(
                              'Select Time Duration',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.heightMultiplier * 2,
                          ),
                          const Center(
                            child: Text(
                              'Select time duration for each room',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.heightMultiplier * 5,
                          ),
                          DurationPicker(
                            height: SizeConfig.heightMultiplier * 32,
                            width: SizeConfig.heightMultiplier * 32,
                            duration: duration,
                            onChange: (value) {
                              setState(() {
                                duration = value;
                              });
                            },
                          ),
                          SizedBox(
                            height: SizeConfig.heightMultiplier * 5,
                          ),
                          // Button(
                          //   label: 'Next',
                          //   onPressed: () {
                          //     if (duration.inMinutes > 0) {
                          //       widget.roomsDetail.duration = duration;
                          //       Navigator.of(context).push(
                          //         MaterialPageRoute(builder: (context) {
                          //           return RoomActivityScreen(
                          //               roomsDetail: widget.roomsDetail);
                          //         }),
                          //       );
                          //     } else {
                          //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          //         content: Text('Select time duration for each room'),
                          //       ));
                          //     }
                          //   },
                          //   color: kGreenButtonColor,
                          //   textColor: Colors.white,
                          // ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: SizeConfig.imageSizeMultiplier * 15,
                          width: SizeConfig.imageSizeMultiplier * 15,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(68, 204, 136, 1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            // padding: EdgeInsets.only(
                            //   right: 8.0,
                            // ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 29.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          height: SizeConfig.imageSizeMultiplier * 15,
                          width: SizeConfig.imageSizeMultiplier * 15,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(68, 204, 136, 1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            // padding: EdgeInsets.only(
                            //   left: 8.0,
                            // ),
                            onPressed: () {
                              if (duration.inMinutes > 0) {
                                widget.roomsDetail.duration = duration;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return RoomActivityScreen(
                                        roomsDetail: widget.roomsDetail,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Select time duration for each room',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_forward,
                              size: 29.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Create Activity Room'),
  //     ),
  //     body: SafeArea(
  //       child: Container(
  //         width: double.infinity,
  //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         child: SingleChildScrollView(
  //           child: Container(
  //             width: double.infinity,
  //             height: SizeConfig.heightMultiplier * 70,
  //             margin: const EdgeInsets.fromLTRB(12, 50, 12, 2),
  //             child: Column(
  //               children: [
  //                 const Center(
  //                   child: Text(
  //                     'Select Time Duration',
  //                     style: TextStyle(
  //                       fontSize: 22,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: SizeConfig.heightMultiplier * 5,
  //                 ),
  //                 const Center(
  //                   child: Text(
  //                     'Select time duration for each room',
  //                     style:
  //                         TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: SizeConfig.heightMultiplier * 5,
  //                 ),
  //                 DurationPicker(
  //                   height: 250.0,
  //                   width: 250.0,
  //                   duration: duration,
  //                   onChange: (value) {
  //                     setState(() {
  //                       duration = value;
  //                     });
  //                   },
  //                 ),
  //                 SizedBox(
  //                   height: SizeConfig.heightMultiplier * 5,
  //                 ),
  //                 Button(
  //                   label: 'Next',
  //                   onPressed: () {
  //                     if (duration.inMinutes > 0) {
  //                       widget.roomsDetail.duration = duration;
  //                       Navigator.of(context).push(
  //                         MaterialPageRoute(builder: (context) {
  //                           return RoomActivityScreen(
  //                               roomsDetail: widget.roomsDetail);
  //                         }),
  //                       );
  //                     } else {
  //                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                         content: Text('Select time duration for each room'),
  //                       ));
  //                     }
  //                   },
  //                   color: kGreenButtonColor,
  //                   textColor: Colors.white,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

class RoomActivityScreen extends StatefulWidget {
  final RoomsDetail roomsDetail;
  const RoomActivityScreen({
    required this.roomsDetail,
  });

  @override
  _RoomActivityScreenState createState() => _RoomActivityScreenState();
}

class _RoomActivityScreenState extends State<RoomActivityScreen> {
  bool isCriticalityOpen = false;
  bool isTeamBuildUpOpen = false;
  bool isCommunicationMatrix = false;
  bool joinAsParticipant = false;
  ActivityType? activityType;
  String accessCode = '';
  String link = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Acticity Room'),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              // height: SizeConfig.heightMultiplier * 65,
              margin: EdgeInsets.fromLTRB(
                SizeConfig.heightMultiplier * 1.78,
                SizeConfig.heightMultiplier * 10.41,
                SizeConfig.heightMultiplier * 1.78,
                SizeConfig.heightMultiplier * 0.29,
              ),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Select Activity',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 5,
                  ),
                  Button(
                    label: 'Criticality',
                    color: isCriticalityOpen
                        ? const Color(0xFF7816F7)
                        : const Color.fromRGBO(236, 236, 236, 1),
                    textColor: isCriticalityOpen ? Colors.white : Colors.black,
                    onPressed: () {
                      setState(() {
                        isCriticalityOpen = !isCriticalityOpen;
                        isTeamBuildUpOpen = false;
                        isCommunicationMatrix = false;
                        activityType = ActivityType.Criticality;
                      });
                    },
                  ),
                  Visibility(
                    visible: isCriticalityOpen,
                    maintainAnimation: true,
                    maintainState: true,
                    child: ModalWidget(
                      "How much will your work role be impacted with this person's absence (leaving job)?",
                      'Removes Friction',
                      'No Impact',
                      'Some Manageable Impact',
                      'Heavily Impacted',
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 2,
                  ),
                  Button(
                    label: 'Team Build Up',
                    color: isTeamBuildUpOpen
                        ? const Color(0xFF7816F7)
                        : const Color.fromRGBO(236, 236, 236, 1),
                    textColor: isTeamBuildUpOpen ? Colors.white : Colors.black,
                    onPressed: () {
                      setState(() {
                        isTeamBuildUpOpen = !isTeamBuildUpOpen;
                        isCriticalityOpen = false;
                        isCommunicationMatrix = false;
                        activityType = ActivityType.TeamBuildUp;
                      });
                    },
                  ),
                  Visibility(
                    visible: isTeamBuildUpOpen,
                    maintainAnimation: true,
                    maintainState: true,
                    child: ModalWidget(
                      'What role would you like the person to play in your team?',
                      'Co-Founder',
                      'Team Member',
                      'Not Match',
                      'Negative',
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 2,
                  ),
                  Button(
                    label: 'Communication Matrix',
                    color: isCommunicationMatrix
                        ? const Color(0xFF7816F7)
                        : const Color.fromRGBO(236, 236, 236, 1),
                    textColor:
                        isCommunicationMatrix ? Colors.white : Colors.black,
                    onPressed: () {
                      setState(() {
                        isCommunicationMatrix = !isCommunicationMatrix;
                        isCriticalityOpen = false;
                        isTeamBuildUpOpen = false;
                        activityType = ActivityType.CommunicationMatrix;
                      });
                    },
                  ),
                  Visibility(
                    visible: isCommunicationMatrix,
                    maintainAnimation: true,
                    maintainState: true,
                    child: ModalWidget(
                      'How much do you need to communicate with this person at your work place',
                      'Critically Dependant',
                      'Necessary',
                      'Not Needed',
                      'Distraction',
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 15,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: const Color(0xFF7816F7),
                        side: const BorderSide(
                          color: Color(0xFF7816F7),
                          width: 2.0,
                        ),
                        value: joinAsParticipant,
                        onChanged: (value) {
                          setState(() {
                            joinAsParticipant = value!;
                          });
                        },
                      ),
                      const Text('Join as participant')
                    ],
                  ),
                  Button(
                    label: 'Create Room',
                    onPressed: () async {
                      _showLoadingBar(context);
                      if (!isCriticalityOpen &&
                          !isTeamBuildUpOpen &&
                          !isCommunicationMatrix) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Select any option'),
                          ),
                        );
                      } else {
                        widget.roomsDetail.activityType = activityType!;
                        widget.roomsDetail.adminAsParticipant =
                            joinAsParticipant;
                        final snapshot =
                            await RealtimeDatabase().database.get();
                        final roomData =
                            Map<String, dynamic>.from(snapshot.value as Map);
                        final roomCodes = List<String>.from(roomData.keys);
                        final roomSnap =
                            await FirestoreDatabase().roomDataCollection.get();
                        final roomsListSnaps = roomSnap.docs;
                        for (final element in roomsListSnaps) {
                          roomCodes.add(element.id);
                        }
                        accessCode = randomNumeric(6);
                        while (roomCodes.contains(accessCode)) {
                          accessCode = randomNumeric(6);
                        }
                        widget.roomsDetail.accessCode = accessCode;
                        final url =
                            await DynamicLinkService().createDynamicLinkForRoom(
                          widget.roomsDetail.accessCode,
                        );
                        widget.roomsDetail.link = url.toString();
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return RoomFinalScreen(
                                roomsDetail: widget.roomsDetail,
                              );
                            },
                          ),
                        );
                      }
                    },
                    color: kGreenButtonColor,
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
}

// ignore: must_be_immutable
class ModalWidget extends StatelessWidget {
  String? question;
  String? specialCardText;
  String? yesCardText;
  String? skipCardText;
  String? noCardText;
  ModalWidget(
    this.question,
    this.specialCardText,
    this.yesCardText,
    this.skipCardText,
    this.noCardText,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        12.0,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 5.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F7),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          const SizedBox(height: 25),
          Center(
            child: Text(
              question!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 300,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 3),
                            height: 12,
                            width: 12,
                            decoration: const BoxDecoration(
                              color: kPurpleColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(2.0),
                              ),
                            ),
                          ),
                          const Text(
                            'Special',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        specialCardText!,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 3),
                            height: 12,
                            width: 12,
                            decoration: const BoxDecoration(
                              color: kGreenButtonColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(2.0),
                              ),
                            ),
                          ),
                          const Text(
                            'Yes',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        yesCardText!,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 3),
                            height: 12,
                            width: 12,
                            decoration: const BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.all(
                                Radius.circular(2.0),
                              ),
                            ),
                          ),
                          const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        skipCardText!,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 3),
                            height: 12,
                            width: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.all(
                                Radius.circular(2.0),
                              ),
                            ),
                          ),
                          const Text(
                            'No',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        noCardText!,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoomFinalScreen extends StatefulWidget {
  final RoomsDetail roomsDetail;
  const RoomFinalScreen({
    required this.roomsDetail,
  });

  @override
  State<RoomFinalScreen> createState() => _RoomFinalScreenState();
}

class _RoomFinalScreenState extends State<RoomFinalScreen> {
  TextEditingController linkController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    linkController.text = widget.roomsDetail.link;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity Room'),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              // height: SizeConfig.heightMultiplier * 65,
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity Room Detail',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 3,
                  ),
                  Table(
                    children: [
                      buildTableRow('Name', widget.roomsDetail.name),
                      // buildTableRow('Description', roomsDetail.description),
                      // buildTableRow(
                      //     'Creation Time', roomsDetail.creationTime.toString()),
                      buildTableRow(
                        'Duration',
                        '${widget.roomsDetail.duration.toString().split(":")[1]} Min ${widget.roomsDetail.duration.toString().split(":")[2].split(".")[0]} Sec',
                      ),
                      buildTableRow(
                        'Admin as Participant',
                        widget.roomsDetail.adminAsParticipant ? 'Yes' : 'No',
                      ),
                      buildTableRow(
                        'AccessCode',
                        widget.roomsDetail.accessCode,
                      ),
                      buildTableRow('link', widget.roomsDetail.link),
                      buildTableRow(
                        'Room Type',
                        widget.roomsDetail.roomType.toString().split('.')[1],
                      ),
                      buildTableRow(
                        'Activity Type',
                        widget.roomsDetail.activityType
                            .toString()
                            .split('.')[1],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 4,
                  ),
                  const Divider(
                    thickness: 1.0,
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 4,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100.0,
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.725,
                          child: TextFormField(
                            controller: linkController,
                            readOnly: true,
                            decoration: kInputDecoration.copyWith(
                              hintText: 'Link',
                              // suffix: Padding(
                              //   padding: EdgeInsets.symmetric(
                              //     horizontal: 2.0,
                              //   ),
                              //   child: Container(
                              //     width: 48,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(10.0),
                              //       color: const Color(0xFFE7DEFF),
                              //     ),
                              //     child: IconButton(
                              //       icon: Icon(
                              //         Icons.share,
                              //       ),
                              //       onPressed: () {},
                              //     ),
                              //   ),
                              // ),
                              suffixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  width: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: const Color(0xFFE7DEFF),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.copy_outlined,
                                      color: Color(0xFF7816F7),
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: linkController.text,
                                        ),
                                      ).then((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Link Copied to Clipboard',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            duration:
                                                Duration(milliseconds: 800),
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: Container(
                            width: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: const Color(0xFFE7DEFF),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.share,
                                color: Color(0xFF7816F7),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Shared',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 2,
                  ),
                  // FormButton(
                  //   label: 'Share Link via Email',
                  //   onPressed: () {},
                  // ),
                  // SizedBox(
                  //   height: SizeConfig.heightMultiplier * 5,
                  // ),
                  Button(
                    label: 'Join Room',
                    color: kGreenButtonColor,
                    onPressed: () async {
                      if (widget.roomsDetail.active) {
                        final snapshot = await FirestoreDatabase().getUser();
                        final json = snapshot.data()! as Map<String, dynamic>;
                        final user = UserData.fromJson(json: json);
                        widget.roomsDetail.participants =
                            widget.roomsDetail.adminAsParticipant
                                ? [
                                    user.toString(),
                                    // UserData(
                                    //   id: 'oYYkdnR47FUVHZB0gnMRwSL03Fj2',
                                    //   fullName: 'Saumya Singh',
                                    //   imageLink:
                                    //       'https://firebasestorage.googleapis.com/v0/b/teamdynamics-a9ed1.appspot.com/o/images%2Fflutter_intro.png?alt=media&token=9e2c381e-8f6a-485b-8ba2-09d39caf3688',
                                    // ).toString(),
                                    // UserData(
                                    //   id: '4xTCaxgOZbfaRfyi4gdenTb14R33',
                                    //   fullName: 'Vipul Kumar Maurya',
                                    //   imageLink:
                                    //       'https://firebasestorage.googleapis.com/v0/b/teamdynamics-a9ed1.appspot.com/o/images%2Fflutter_intro.png?alt=media&token=9e2c381e-8f6a-485b-8ba2-09d39caf3688',
                                    // ).toString(),
                                    // UserData(
                                    //   id: 'njs9TLA8eiTgDqFmQ8gdKFaJx822',
                                    //   fullName: 'Vedansh Singh',
                                    //   imageLink:
                                    //       'https://firebasestorage.googleapis.com/v0/b/teamdynamics-a9ed1.appspot.com/o/images%2Fflutter_intro.png?alt=media&token=9e2c381e-8f6a-485b-8ba2-09d39caf3688',
                                    // ).toString(),
                                  ]
                                : [
                                    'None',
                                  ];
                        widget.roomsDetail.creationTime = DateTime.now();
                        final uid = await AuthServices().getCurrentUID();
                        widget.roomsDetail.adminID = uid;
                        RealtimeDatabase().createRoom(widget.roomsDetail);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AdminRoomDashboard(
                                roomsDetail: widget.roomsDetail,
                              );
                            },
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
      ),
    );
  }

  TableRow buildTableRow(String key, String value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
