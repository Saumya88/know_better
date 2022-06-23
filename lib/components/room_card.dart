import 'package:flutter/material.dart';
import 'package:know_better/components/tile_widget.dart';
import 'package:know_better/utilities/styles/size_config.dart';

class RoomCard extends StatelessWidget {
  final int roomNo;
  final String user1;
  final String user2;

  const RoomCard({
    required this.roomNo,
    required this.user1,
    required this.user2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Card(
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 0.3,
            color: Colors.black26,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: SizeConfig.heightMultiplier * 1.5,
              ),
              Row(
                children: [
                  Container(
                    width: 5.0,
                    height: 30.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7816F7),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4.0),
                        bottomRight: Radius.circular(4.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13.0,
                    ),
                    child: Text(
                      'Room $roomNo'.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF7816F7),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.heightMultiplier,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                child: Divider(
                  color: Colors.black26,
                  thickness: 0.3,
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 1.2,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                    ),
                    child: TileWidget(
                      data: user1,
                      index: 0,
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 1.7,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                    ),
                    child: TileWidget(
                      data: user2,
                      index: 1,
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.heightMultiplier * 1.2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
