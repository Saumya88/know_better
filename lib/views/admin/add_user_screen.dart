// ignore_for_file: prefer_single_quotes, use_build_context_synchronously

import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:know_better/components/form_button.dart';
import 'package:know_better/components/form_textfield.dart';
import 'package:know_better/components/gender_button.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/services/auth_services.dart';
import 'package:know_better/services/dynamic_link.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/utilities/styles/size_config.dart';

class AddUserScreen extends StatefulWidget {
  final RoomsDetail roomsDetail;

  const AddUserScreen({required this.roomsDetail});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameConttroller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  Gender gender = Gender.Male;
  String link = '';
  FirebaseApp? app;

  Future initialize() async {
    app = await Firebase.initializeApp(
      name: 'Secondary',
      options: Firebase.app().options,
    );
  }

  Future delete() async {
    await app!.delete();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        FormTextField(
                          controller: nameConttroller,
                          hintText: 'Enter Name',
                          validator: (String? textValue) {
                            if (textValue!.isEmpty) {
                              return 'Enter name of the User.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: SizeConfig.heightMultiplier * 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GenderButton(
                              value: Gender.Male,
                              isSelected: gender == Gender.Male,
                              icon: Icons.male,
                              onTap: () {
                                setState(() {
                                  gender = Gender.Male;
                                });
                              },
                            ),
                            GenderButton(
                              value: Gender.Female,
                              isSelected: gender == Gender.Female,
                              icon: Icons.female,
                              onTap: () {
                                setState(() {
                                  gender = Gender.Female;
                                });
                              },
                            ),
                            GenderButton(
                              value: Gender.Other,
                              icon: Icons.circle_outlined,
                              isSelected: gender == Gender.Other,
                              onTap: () {
                                setState(() {
                                  gender = Gender.Other;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: SizeConfig.heightMultiplier * 3,
                        ),
                        FormTextField(
                          controller: emailController,
                          // onChanged: (String textValue) {
                          //   roomDesc = textValue;
                          // },
                          hintText: 'Enter Email',
                          validator: (String? textValue) {
                            if (textValue!.isEmpty) {
                              return 'Enter email of the User.';
                            } else if (!EmailValidator.validate(textValue)) {
                              return 'Enter a valid Email Address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: SizeConfig.heightMultiplier * 3,
                        ),
                        FormButton(
                          label: 'Add User',
                          color: const Color(0xFF44CC88),
                          onPressed: () async {
                            _showLoadingBar(context);
                            // Navigator.pushNamed(context, CreateProfile.id);
                            if (_formKey.currentState!.validate()) {
                              try {
                                // final firebaseAuth =
                                //     FirebaseAuth.instanceFor(app: app!);
                                // // final userCredential =
                                // //     await firebaseAuth.signInAnonymously();
                                // final userCredential = await firebaseAuth
                                //     .createUserWithEmailAndPassword(
                                //   email: emailController.text,
                                //   password: '123456',
                                // )
                                //     .then((value) async {
                                //   final user = firebaseAuth.currentUser!;
                                //   print('user = $user');
                                //   await user
                                //       .updateDisplayName(nameConttroller.text);
                                //   await user.reload();
                                // });
                                // final user = firebaseAuth.currentUser!;
                                // await user.reload();
                                // print(user.uid);
                                // // print(user);
                                // print('user = $user');
                                // UserData userData =
                                //     UserData.fromUser(user: user);
                                // userData.gender = gender;
                                // userData.imageLink =
                                //     'https://firebasestorage.googleapis.com/v0/b/teamdynamics-a9ed1.appspot.com/o/images%2Fperson.jpg?alt=media&token=0e144ef7-2649-49b5-a708-83a81bcb905d';
                                // await FirestoreDatabase().createUser(userData);
                                final adminData =
                                    await AuthServices().getCurrentUser();
                                final url = await DynamicLinkService()
                                    .createDynamicLink(
                                  widget.roomsDetail.accessCode,
                                  emailController.text,
                                );
                                link = url.toString();
                                final res = await http.post(
                                  Uri.parse(
                                    'https://teamdynamics.getboarded.tech/send_invite',
                                  ),
                                  headers: {
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode({
                                    "email": emailController.text,
                                    "name": nameConttroller.text,
                                    "access_code":
                                        widget.roomsDetail.accessCode,
                                    "admin": adminData!.displayName,
                                    "room_name": widget.roomsDetail.name,
                                    "activity": widget.roomsDetail.activityType
                                        .toString()
                                        .split('.')[1],
                                    "room_link": link
                                  }),
                                );
                                if (res.statusCode == 200 ||
                                    res.statusCode == 201) {
                                  // final roomsDetail = await RealtimeDatabase()
                                  //     .addParticipant(userData.toString(),
                                  //         widget.roomsDetail.accessCode);
                                  // print(
                                  //     'len=${widget.roomsDetail.participants.length}');
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Invitation Sent.'),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Error in adding user'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error in adding user'),
                                  ),
                                );
                              }
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
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
