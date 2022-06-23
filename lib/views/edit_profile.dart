// ignore_for_file: depend_on_referenced_packages, library_prefixes, always_declare_return_types, sized_box_for_whitespace, duplicate_ignore, unnecessary_null_comparison, use_build_context_synchronously

import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:searchfield/searchfield.dart';
import 'package:know_better/components/form_button.dart';
import 'package:know_better/components/form_textfield.dart';
import 'package:know_better/components/gender_button.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/constants/global_constants.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/utilities/styles/styling.dart';
import 'package:know_better/views/user_dashboard.dart';

class EditProfileScreen extends StatefulWidget {
  static String id = 'EditProfile';
  final UserData userData;
  final bool googleSignIn;

  // ignore: prefer_const_constructors_in_immutables
  EditProfileScreen({
    required this.googleSignIn,
    required this.userData,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController skillController = TextEditingController();
  TextEditingController softSkillController = TextEditingController();
  final controller = ScrollController();
  bool isVisible = true;

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
    nameController.text = widget.userData.fullName;
    emailController.text = widget.userData.email;
    titleController.text = widget.userData.title;
    gender = widget.userData.gender.toString().compareTo('Gender.Male') == 0
        ? Gender.Male
        : (widget.userData.gender.toString().compareTo('Gender.Female') == 0
            ? Gender.Female
            : Gender.Other);
    skills = widget.userData.skills!;
    softSkills = widget.userData.softSkills!;
    if (widget.userData.imageLink!.isNotEmpty) {
      link = widget.userData.imageLink!;
      imageSelected = true;
      _image = widget.userData.image!;
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                  height: SizeConfig.heightMultiplier * 77,
                  // height: isVisible
                  //     ? SizeConfig.heightMultiplier * 75
                  //     : SizeConfig.heightMultiplier * 85,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollStartNotification) {
                        _onStartScroll(scrollNotification.metrics);
                      } else if (scrollNotification
                          is ScrollUpdateNotification) {
                        _onUpdateScroll(scrollNotification.metrics);
                      } else if (scrollNotification is ScrollEndNotification) {
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
                                    horizontal: 15.0,
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
                                      if (skill.isNotEmpty) {
                                        setState(() {
                                          skills.add(skill);
                                          skill = '';
                                          skillController.text = '';
                                        });
                                      }
                                    },
                                    controller: skillController,
                                    decoration: kInputDecoration.copyWith(
                                      hintText: 'Tech Skills',
                                      hintStyle: TextStyle(
                                        fontSize: SizeConfig.textMultiplier * 4,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Inter',
                                      ),
                                      labelStyle: TextStyle(
                                        fontSize: SizeConfig.textMultiplier * 4,
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
                                              if (skill.isNotEmpty) {
                                                setState(() {
                                                  skills.add(skill);
                                                  skill = '';
                                                  skillController.text = '';
                                                });
                                              }
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
                                // ignore: sized_box_for_whitespace
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
                                        fontSize: SizeConfig.textMultiplier * 4,
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
                                                  softSkillController.text = '';
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
                                // ignore: sized_box_for_whitespace
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
                                // SizedBox(
                                //   height: SizeConfig.heightMultiplier * 4,
                                // ),

                                // SizedBox(
                                //   height: SizeConfig.heightMultiplier * 4,
                                // ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isVisible,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: FormButton(
                      label: 'Edit Profile',
                      onPressed: () async {
                        if (imageSelected) {
                          if (_formKey.currentState!.validate()) {
                            // ignore: unnecessary_null_comparison
                            _showLoadingBar(context);
                            if (_image.path != null) {
                              link = await uploadScreenshot();
                            }
                            widget.userData.fullName = nameController.text;
                            widget.userData.gender = gender;
                            widget.userData.title = titleController.text;
                            widget.userData.skills = skills;
                            widget.userData.softSkills = softSkills;
                            widget.userData.imageLink = link;
                            FirestoreDatabase().createUser(widget.userData);
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return UserDashboard();
                                },
                              ),
                            );
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
          '${widget.userData.email}/profile_pictures/${Path.basename(_image.path)}',
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
