import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:know_better/services/auth_services.dart';
import 'package:know_better/utilities/styles/size_config.dart';

class TileWidget extends StatefulWidget {
  final String data;
  // final UserData userData;
  // final String imageLink;
  final int index;
  const TileWidget({
    required this.index,
    required this.data,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> {
  String fullName = '';
  String id = '';
  String uid = '';
  String imageLink = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final json = jsonDecode(widget.data) as Map<String, dynamic>;
    fullName = json['full_name'].toString();
    id = json['id'].toString();
    getUserData();
    imageLink = json['image'].toString();
  }

  Future<void> getUserData() async {
    uid = await AuthServices().getCurrentUID();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: SizeConfig.imageSizeMultiplier * 3.5,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(imageLink),
            ),
            SizedBox(
              width: SizeConfig.textMultiplier * 3,
            ),
            Text(
              fullName,
              style: TextStyle(
                color: const Color(0xFF91919F),
                fontSize: SizeConfig.textMultiplier * 4,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Visibility(
          visible: id.compareTo(uid) == 0,
          child: Container(
            width: 43,
            height: 19,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: const Color.fromRGBO(68, 204, 136, 1.0),
            ),
            child: Center(
              child: Text(
                'YOU',
                style: TextStyle(
                  fontSize: SizeConfig.textMultiplier * 3,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
