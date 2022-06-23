import 'package:know_better/models/room.dart';
import 'package:know_better/utilities/constants/global_constants.dart';

class RoomsDetail {
  String name;
  String description;
  String accessCode;
  List<List<Room>> runs;
  List<String> participants;
  RoomType? roomType;
  ActivityType activityType;
  DateTime creationTime;
  String link;
  bool adminAsParticipant;
  bool active;
  Duration duration;
  String adminID;

  RoomsDetail({
    required this.accessCode,
    required this.name,
    required this.description,
    required this.runs,
    required this.participants,
    this.roomType,
    required this.activityType,
    required this.creationTime,
    required this.link,
    required this.adminAsParticipant,
    required this.active,
    required this.duration,
    required this.adminID,
  });

  Map<String, dynamic> toJson() {
    return {
      'access_code': accessCode,
      'name': name,
      'description': description,
      'room_type': roomType.toString(),
      'link': link,
      'admin_as_participants': adminAsParticipant,
      'active': active,
      'admin_id': adminID,
    };
  }
}
