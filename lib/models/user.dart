import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:know_better/utilities/constants/global_constants.dart';

class UserData {
  String id;
  String? imageLink;
  File? image;
  String fullName;
  String email;
  String? password;
  String title;
  Gender gender;
  List<String>? skills;
  List<String>? softSkills;

  UserData({
    this.id = '',
    this.imageLink,
    this.image,
    this.gender = Gender.Female,
    this.fullName = '',
    this.email = '',
    this.title = '',
    this.skills,
    this.softSkills,
  });

  UserData.fromUser({required User user})
      : this(
          id: user.uid,
          fullName: user.displayName!,
          email: user.email!,
          gender: Gender.Male,
          imageLink: '',
          title: '',
          skills: [],
          softSkills: [],
        );

  UserData.fromJson({required Map<String, dynamic> json})
      : this(
          id: json['id'].toString(),
          fullName: json['full_name'].toString(),
          email: json['email'].toString(),
          imageLink: json['image'].toString(),
          title: json['title'].toString(),
          gender: json['gender'].toString().compareTo('Male') == 0
              ? Gender.Male
              : Gender.Female,
          skills: List<String>.from(json['skills'] as List<dynamic>),
          softSkills: List<String>.from(json['soft_skills'] as List<dynamic>),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': imageLink,
      'full_name': fullName,
      'gender': gender.toString().split('.')[1],
      'email': email,
      'title': title,
      'skills': FieldValue.arrayUnion(skills!),
      'soft_skills': FieldValue.arrayUnion(softSkills!),
    };
  }

  // Map<String, dynamic> toRoomJson() {
  //   return {
  //     'id': id,
  //     'full_name': fullName,
  //     'image': imageLink,
  //   };
  // }

  @override
  String toString() {
    // ignore: leading_newlines_in_multiline_strings
    return '''{
      "id": "$id",
      "image": "$imageLink",
      "full_name": "$fullName",
      "title": "$title"      
    }''';
  }
}
