// ignore_for_file: depend_on_referenced_packages, library_prefixes, always_declare_return_types, sized_box_for_whitespace, unnecessary_null_comparison, use_build_context_synchronously

import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:know_better/components/form_button.dart';
import 'package:know_better/components/form_textfield.dart';
import 'package:know_better/components/gender_button.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/auth_services.dart';
import 'package:know_better/services/cloud_database.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/utilities/styles/styling.dart';
import 'package:know_better/views/user/user_room_dashboard.dart';
import 'package:know_better/views/user_dashboard.dart';

class CreateProfileScreen extends StatefulWidget {
  static String id = 'CreateProfile';
  final String? accessCode;
  final String? email;

  // ignore: prefer_const_constructors_in_immutables
  CreateProfileScreen({
    this.accessCode,
    this.email,
  });

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController skillController = TextEditingController();
  TextEditingController softSkillController = TextEditingController();
  final controller = ScrollController();
  bool isVisible = true;
  UserData userData = UserData();

  String skill = '';
  String softSkill = '';
  List<String> skills = [];
  List<String> softSkills = [];
  final picker = ImagePicker();
  late File _image = File('/assets/icons/Google_logo.png');
  String link = '';
  bool imageSelected = false;
  bool uploadSuccessful = false;
  bool isUploading = false;
  Gender gender = Gender.Male;

  _onStartScroll(ScrollMetrics metrics) {
    setState(() {
      isVisible = false;
    });
  }

  _onUpdateScroll(ScrollMetrics metrics) {
    setState(() {
      isVisible = false;
    });
  }

  _onEndScroll(ScrollMetrics metrics) {
    setState(() {
      isVisible = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.addListener(() {
      if (controller.position.atEdge) {
        if (controller.position.pixels > 0) {
          setState(() {
            isVisible = true;
          });
        }
      } else {
        setState(() {
          isVisible = false;
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
          title: const Text('Create Profile'),
          leading: IconButton(
            iconSize: 1.0,
            onPressed: () {},
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFF6F6F7),
            ),
          ),
        ),
        // backgroundColor: Color(0xFFE5E5E5),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: SizeConfig.heightMultiplier * 100,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: SizeConfig.heightMultiplier * 82,
                    // height: isVisible
                    //     ? SizeConfig.heightMultiplier * 75
                    //     : SizeConfig.heightMultiplier * 85,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollStartNotification) {
                          _onStartScroll(scrollNotification.metrics);
                        } else if (scrollNotification
                            is ScrollUpdateNotification) {
                          _onUpdateScroll(scrollNotification.metrics);
                        } else if (scrollNotification
                            is ScrollEndNotification) {
                          _onEndScroll(scrollNotification.metrics);
                        }
                        return true;
                      },
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: SizeConfig.heightMultiplier * 4,
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  profilePicture(),
                                  SizedBox(
                                    height: SizeConfig.heightMultiplier * 3,
                                  ),
                                  FormTextField(
                                    hintText: 'Full Name',
                                    controller: nameController,
                                    validator: (String? textValue) {
                                      if (textValue!.isEmpty) {
                                        return 'Enter Full Name';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: SizeConfig.heightMultiplier * 4,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        // horizontal: 15.0,
                                        ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                  ),
                                  SizedBox(
                                    height: SizeConfig.heightMultiplier * 3,
                                  ),
                                  FormTextField(
                                    hintText: 'Email Address',
                                    controller: emailController,
                                    readOnly: true,
                                    validator: (String? textValue) {
                                      if (textValue!.isEmpty) {
                                        return 'Enter Email Address';
                                      } else if (!EmailValidator.validate(
                                        textValue,
                                      )) {
                                        return 'Enter a valid Email Address';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: SizeConfig.heightMultiplier * 2,
                                  ),
                                  FormTextField(
                                    hintText: 'Password',
                                    isPassword: true,
                                    controller: passwordController,
                                    validator: (String? textValue) {
                                      if (textValue!.isEmpty) {
                                        return 'Enter Password';
                                      } else if (textValue.length < 6) {
                                        return 'Password should have more than 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: SizeConfig.heightMultiplier * 2,
                                  ),
                                  FormTextField(
                                    controller: titleController,
                                    hintText: 'Enter Title',
                                    validator: (String? textValue) {
                                      if (textValue!.isEmpty) {
                                        return 'Enter Title';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: SizeConfig.heightMultiplier * 2,
                                  ),
                                  Material(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    child: TextFormField(
                                      onChanged: (String textValue) {
                                        skill = textValue;
                                      },
                                      onFieldSubmitted: (String textValue) {
                                        if (skill.isNotEmpty &&
                                            !skills.contains(skill)) {
                                          setState(() {
                                            skills.add(skill);
                                            skill = '';
                                          });
                                        }
                                        setState(() {
                                          skillController.text = '';
                                        });
                                      },
                                      controller: skillController,
                                      decoration: kInputDecoration.copyWith(
                                        hintText: 'Tech Skills',
                                        hintStyle: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 4,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Inter',
                                        ),
                                        labelStyle: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 4,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Inter',
                                        ),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: Container(
                                            width: 48,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: const Color(0xFFE7DEFF),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                color: Color(0xFF7816F7),
                                              ),
                                              onPressed: () {
                                                if (skill.isNotEmpty &&
                                                    !skills.contains(skill)) {
                                                  setState(() {
                                                    skills.add(skill);
                                                    skill = '';
                                                  });
                                                }
                                                setState(() {
                                                  skillController.text = '';
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
                                  SizedBox(
                                    height: SizeConfig.heightMultiplier * 2,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: List.generate(
                                        skills.length,
                                        (int index) {
                                          // print(skills);
                                          return buildSkillChip(index);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: SizeConfig.heightMultiplier * 2,
                                  ),
                                  Material(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    child: SearchField(
                                      controller: softSkillController,
                                      hint: 'Soft Skills',
                                      searchStyle: TextStyle(
                                        fontSize: SizeConfig.textMultiplier * 4,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Inter',
                                      ),
                                      suggestions: fixedSoftSkills,
                                      onTap: (String? textValue) {
                                        softSkill = textValue!;
                                        if (softSkill.isNotEmpty &&
                                            !softSkills.contains(softSkill)) {
                                          setState(() {
                                            softSkills.add(softSkill);
                                            softSkill = '';
                                          });
                                        }
                                        setState(() {
                                          softSkillController.text = '';
                                        });
                                      },
                                      searchInputDecoration:
                                          kInputDecoration.copyWith(
                                        hintText: 'Soft Skills',
                                        hintStyle: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 4,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Inter',
                                        ),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: Container(
                                            width: 48,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: const Color(0xFFE7DEFF),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                color: Color(0xFF7816F7),
                                              ),
                                              onPressed: () {
                                                if (softSkill.isNotEmpty &&
                                                    !softSkills
                                                        .contains(softSkill)) {
                                                  setState(() {
                                                    softSkills.add(softSkill);
                                                    softSkill = '';
                                                    softSkillController.text =
                                                        '';
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: SizeConfig.heightMultiplier * 2,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: List.generate(
                                        softSkills.length,
                                        (int index) {
                                          // print(skills);
                                          return buildSoftSkillChip(index);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Visibility(
                    visible: isVisible,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: FormButton(
                        label: 'Create Profile',
                        onPressed: () async {
                          if (imageSelected) {
                            if (_formKey.currentState!.validate()) {
                              _showLoadingBar(context);
                              if (_image.path != null) {
                                link = await uploadScreenshot();
                              }
                              userData.fullName = nameController.text;
                              userData.gender = gender;
                              userData.title = titleController.text;
                              userData.skills = skills;
                              userData.softSkills = softSkills;
                              userData.imageLink = link;
                              FirestoreDatabase().createUser(userData);
                              final SharedPreferences sharedPreferences =
                                  await SharedPreferences.getInstance();
                              sharedPreferences.setString(
                                'UID',
                                userData.id,
                              );
                              if (widget.accessCode == null) {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return UserDashboard();
                                    },
                                  ),
                                );
                              } else {
                                if (widget.email == null) {
                                  final roomsDetail = await RealtimeDatabase()
                                      .addParticipants(widget.accessCode!);
                                  // print('link=${roomsDetail.link}');
                                  Navigator.of(context).pop(context);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return UserDashboard();
                                      },
                                    ),
                                  );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return UserRoomDashboard(
                                          roomsDetail: roomsDetail,
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  if (emailController.text
                                          .compareTo(widget.email!) ==
                                      0) {
                                    final roomsDetail = await RealtimeDatabase()
                                        .addParticipants(widget.accessCode!);
                                    // print('link=${roomsDetail.link}');
                                    Navigator.of(context).pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return UserDashboard();
                                        },
                                      ),
                                    );
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return UserRoomDashboard(
                                            roomsDetail: roomsDetail,
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).pop(context);
                                    Navigator.of(context).pop(context);
                                    Navigator.of(context).pop(context);
                                    await AuthServices()
                                        .signOutWithGoogle(context: context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Login with the email mentioned in your mail.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Select Image',
                                ),
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
      ),
    );
  }

  Widget buildSkillChip(int index) {
    return InputChip(
      padding: const EdgeInsets.symmetric(
        horizontal: 3.0,
      ),
      // isEnabled: false,
      label: Text(
        skills[index],
      ),
      deleteIcon: Center(
        child: Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFFBABABA),
          ),
          child: const Icon(
            Icons.close,
            size: 13.0,
          ),
        ),
      ),
      onDeleted: () {
        setState(() {
          skills.removeAt(index);
        });
      },
    );
  }

  Widget buildSoftSkillChip(int index) {
    return InputChip(
      padding: const EdgeInsets.symmetric(
        horizontal: 3.0,
      ),
      // isEnabled: false,
      label: Text(
        softSkills[index],
        style: TextStyle(
          fontSize: SizeConfig.textMultiplier * 3.5,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
      ),
      deleteIcon: Center(
        child: Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFFBABABA),
          ),
          child: const Icon(
            Icons.close,
            size: 13.0,
          ),
        ),
      ),
      onDeleted: () {
        setState(() {
          softSkills.removeAt(index);
        });
      },
    );
  }

  Widget profilePicture() {
    if (imageSelected) {
      return CircleAvatar(
        radius: SizeConfig.imageSizeMultiplier * 13,
        backgroundColor: Colors.white,
        backgroundImage: FileImage(_image),
        child: Container(
          alignment: Alignment.center,
          child: IconButton(
            icon: const Icon(
              Icons.add_a_photo_outlined,
              color: Colors.black,
            ),
            onPressed: () async {
              await chooseImage();
            },
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: SizeConfig.imageSizeMultiplier * 13,
        backgroundColor: Colors.grey,
        child: Container(
          alignment: Alignment.center,
          child: IconButton(
            icon: const Icon(
              Icons.add_a_photo,
              color: Colors.black,
            ),
            onPressed: () async {
              await chooseImage();
            },
          ),
        ),
      );
    }
  }

  Future chooseImage() async {
    // ignore: deprecated_member_use
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    // print(pickedFile!.path);
    if (pickedFile == null) {
      retrieveLostData();
    } else {
      setState(() {
        _image = File(pickedFile.path);
        imageSelected = true;
      });
    }
  }

  Future<void> retrieveLostData() async {
    // ignore: deprecated_member_use
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      // ignore: avoid_print
      print('cancelled');
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = File(response.file!.path);
        imageSelected = true;
      });
    } else {
      // ignore: avoid_print
      print(response.file);
    }
  }

  Future<String> uploadScreenshot() async {
    final ref = firebase_storage.FirebaseStorage.instance.ref().child(
          '${userData.email}/profile_pictures/${Path.basename(_image.path)}',
        );
    await ref.putFile(_image).whenComplete(() async {
      await ref.getDownloadURL().then((value) {
        setState(() {
          isUploading = false;
          link = value;
          uploadSuccessful = true;
        });
        // print('link=$link');
      }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          isUploading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uploading is taking too much time.'),
            ),
          );
          // print('Upload Timeout');
        },
      );
    });
    return link;
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
