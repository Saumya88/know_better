class Room {
  String adminId;
  Duration duration;
  List<String> participants;
  DateTime creationTime;

  Room(
      {required this.adminId,
      required this.creationTime,
      required this.duration,
      required this.participants,});
}
