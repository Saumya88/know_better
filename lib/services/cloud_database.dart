import 'dart:convert';

import 'package:duration/duration.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:know_better/models/rooms_detail.dart';
import 'package:know_better/models/user.dart';
import 'package:know_better/services/cloud_firestore.dart';
import 'package:know_better/utilities/constants/global_constants.dart';

class RealtimeDatabase {
  final database = FirebaseDatabase(
    databaseURL:
        'https://know-better-59964-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).reference();

  Future<void> createRoom(RoomsDetail roomsDetail) async {
    final roomsDetailRef =
        database.child('/${roomsDetail.accessCode}/rooms_detail');
    final participantsRef =
        database.child('/${roomsDetail.accessCode}/participants');
    final timerRef = database.child('/${roomsDetail.accessCode}/timer');
    final runsRef = database
        .child('/${roomsDetail.accessCode}')
        .child('run_detail')
        .child('runs');
    final feedbackRef =
        database.child('/${roomsDetail.accessCode}').child('feedback');
    final allowChangeRef =
        database.child('/${roomsDetail.accessCode}').child('allow_change');
    await roomsDetailRef.set({
      'access_code': roomsDetail.accessCode,
      'name': roomsDetail.name,
      'description': roomsDetail.description,
      'room_type': roomsDetail.roomType.toString(),
      'activity_type': roomsDetail.activityType.toString(),
      'link': roomsDetail.link,
      'admin_as_participants': roomsDetail.adminAsParticipant,
      'active': roomsDetail.active,
      'creation_time': roomsDetail.creationTime.toString(),
      'duration': roomsDetail.duration.toString(),
      'admin_id': roomsDetail.adminID,
    });
    final participantsData = List.generate(
      roomsDetail.participants.length,
      (index) => roomsDetail.participants[index],
    );
    await participantsRef.set(participantsData);
    await runsRef.set('Runs');
    await feedbackRef.set({'value': 0});
    await timerRef.set({'seconds': 0});
    await allowChangeRef.set({'value': false});
  }

  Map<String, int> mapCards(int length) {
    final Map<String, int> cardsMapping = {};
    if (length % 8 == 0) {
      final num = length ~/ 8;
      cardsMapping['Skip'] = 4 * num;
      cardsMapping['Yes'] = 2 * num;
      cardsMapping['Special'] = num;
      cardsMapping['No'] = num;
    } else if (length % 8 == 1 || length % 8 == 2) {
      final num = length ~/ 8;
      final rem = length % 8;
      cardsMapping['Skip'] = 4 * num + rem;
      cardsMapping['Yes'] = 2 * num;
      cardsMapping['Special'] = num;
      cardsMapping['No'] = num;
    } else if (length % 8 == 3 || length % 8 == 4) {
      final num = length ~/ 8;
      final rem = (length % 8) - 2;
      cardsMapping['Skip'] = 4 * num + 2;
      cardsMapping['Yes'] = 2 * num + rem;
      cardsMapping['Special'] = num;
      cardsMapping['No'] = num;
    } else if (length % 8 == 6 || length % 8 == 7) {
      final num = length ~/ 8;
      final rem = (length % 8) - 3;
      cardsMapping['Skip'] = 4 * num + rem;
      cardsMapping['Yes'] = 2 * num + 2;
      cardsMapping['Special'] = num + 1;
      cardsMapping['No'] = num;
    } else {
      final num = length ~/ 8;
      cardsMapping['Skip'] = 4 * num + 2;
      cardsMapping['Yes'] = 2 * num + 2;
      cardsMapping['Special'] = num + 1;
      cardsMapping['No'] = num;
    }
    return cardsMapping;
  }

  Future<void> updateRuns(RoomsDetail roomsDetail) async {
    final runsRef = database
        .child('/${roomsDetail.accessCode}')
        .child('run_detail')
        .child('runs');
    final participantsRef =
        database.child('/${roomsDetail.accessCode}').child('participants');
    final data = await participantsRef.get();
    final participantsData = List<String>.from(data.value as List);
    final participants = List.generate(
      participantsData.length,
      (index) => participantsData[index].split(':')[1].split('"')[1],
    );
    // final runs = roomsDetail.runs.map((rooms) {
    //   return rooms.map((room) {
    //     return room.participants;
    //   });
    // });
    final cardsRef =
        database.child('/${roomsDetail.accessCode}').child('cards');
    final cards = mapCards(roomsDetail.participants.length - 1);
    for (final element in participants) {
      cardsRef.update({element: cards});
    }
    final runs = List.generate(roomsDetail.runs.length, (index) {
      final rooms = roomsDetail.runs[index];
      return List.generate(rooms.length, (index) {
        final room = rooms[index];
        return room.participants;
        // return {
        //   index.toString(): room.participants,
        // };
      });
    });
    await runsRef.set(runs);
  }

  Future<DataSnapshot> getRoom(String accessCode) {
    final roomRef = database.child('/$accessCode');
    return roomRef.get();
  }

  bool checkDuplicate(
    List<String> participants,
    String userData,
    String accessCode,
  ) {
    final List<String> id = [];
    final participantsRef = database.child('/$accessCode');
    final user = jsonDecode(userData);
    for (final element in participants) {
      final data = jsonDecode(element);
      id.add(data['id'].toString());
    }
    if (id.contains(user['id'].toString())) {
      final index = id.indexOf(user['id'].toString());
      participants.removeAt(index);
      participants.add(userData);
      participantsRef.update({
        'participants': participants,
      });
    }
    return id.contains(user['id'].toString());
  }

  Future<RoomsDetail> addParticipant(String userData, String accessCode) async {
    // Function for admin adding user to room
    final participantsRef = database.child('/$accessCode');
    final data = await participantsRef.get();
    List<String> participants =
        List<String>.from(data.value['participants'] as List);
    if (participants.contains('None')) {
      participants = [userData];
      participantsRef.update({
        'participants': participants,
      });
    } else {
      if (!participants.contains(userData)) {
        participants.add(userData);
        participantsRef.update({
          'participants': participants,
        });
      }
    }
    final detail = Map<String, dynamic>.from(data.value['rooms_detail'] as Map);
    final RoomsDetail roomsDetail = RoomsDetail(
      accessCode: accessCode,
      name: detail['name'] as String,
      description: detail['description'] as String,
      runs: [],
      participants: participants,
      roomType:
          (detail['room_type'] as String).compareTo('RoomType.Physical') == 0
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
      active: detail['active'] as bool,
      duration: parseTime(detail['duration'] as String),
      adminID: detail['admin_id'] as String,
    );
    return roomsDetail;
    // participantsRef.update({});
  }

  Future<RoomsDetail> addParticipants(String accessCode) async {
    // Function for user being added by themself.
    final participantsRef = database.child('/$accessCode');
    final data = await participantsRef.get();
    List<String> participants =
        List<String>.from(data.value['participants'] as List);
    final snapshot = await FirestoreDatabase().getUser();
    final json = snapshot.data()! as Map<String, dynamic>;
    final userData = UserData.fromJson(json: json).toString();
    if (participants.contains('None')) {
      participants = [userData];
      participantsRef.update({
        'participants': participants,
      });
    } else {
      if (!checkDuplicate(participants, userData, accessCode)) {
        participants.add(userData);
        participantsRef.update({
          'participants': participants,
        });
      } else {
        participants.remove(userData);
        participants.add(userData);
        participantsRef.update({
          'participants': participants,
        });
      }
    }
    final detail = Map<String, dynamic>.from(data.value['rooms_detail'] as Map);
    final RoomsDetail roomsDetail = RoomsDetail(
      accessCode: accessCode,
      name: detail['name'] as String,
      description: detail['description'] as String,
      runs: [],
      participants: participants,
      roomType:
          (detail['room_type'] as String).compareTo('RoomType.Physical') == 0
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
    return roomsDetail;
    // participantsRef.update({});
  }

  void startRun(RoomsDetail roomsDetail, int runNo) {
    final currentIndexRef = database
        .child('/${roomsDetail.accessCode}')
        .child('current_run')
        .child('value');
    final timerRef = database.child('/${roomsDetail.accessCode}/timer');
    currentIndexRef.set(runNo);
    timerRef.set({
      'countdown': 10,
      'room_duration': roomsDetail.duration.inSeconds,
    });
  }
}
