import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:know_better/utilities/styles/size_config.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.imageSizeMultiplier * 100,
      height: SizeConfig.heightMultiplier * 70,
      child: Stack(
        children: <Widget>[
          // Positioned(
          //   top: 0.0,
          //   left: 0.0,
          //   child: Container(
          //     width: SizeConfig.imageSizeMultiplier * 100,
          //     height: SizeConfig.heightMultiplier * 70,
          //     child: CustomPaint(
          //       painter: CurvePainter(),
          //     ),
          //   ),
          // ),
          Positioned(
            top: SizeConfig.heightMultiplier * 42.7,
            left: SizeConfig.imageSizeMultiplier * 12.15,
            child: Transform.rotate(
              angle: -3.382115337180968e-8 * (math.pi / 180),
              child: Container(
                width: SizeConfig.heightMultiplier * 7.5,
                height: SizeConfig.heightMultiplier * 7.5,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(249, 245, 255, 1),
                  border: Border.all(
                    color: const Color.fromRGBO(231, 213, 255, 1),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(SizeConfig.heightMultiplier * 7.5,
                        SizeConfig.heightMultiplier * 7.5),
                  ),
                ),
                child: Transform.rotate(
                  angle: -3.382115337180968e-8 * (math.pi / 180),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Ellipse3.png'),
                        fit: BoxFit.fitWidth,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(SizeConfig.heightMultiplier * 7.5,
                            SizeConfig.heightMultiplier * 7.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: SizeConfig.heightMultiplier * 54.16,
            left: SizeConfig.imageSizeMultiplier * 62.45,
            child: Transform.rotate(
              angle: -3.382115337180968e-8 * (math.pi / 180),
              child: Container(
                width: SizeConfig.heightMultiplier * 8,
                height: SizeConfig.heightMultiplier * 8,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(249, 245, 255, 1),
                  border: Border.all(
                    color: const Color.fromRGBO(231, 213, 255, 1),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(SizeConfig.heightMultiplier * 8,
                        SizeConfig.heightMultiplier * 8),
                  ),
                ),
                child: Transform.rotate(
                  angle: -3.382115337180968e-8 * (math.pi / 180),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Ellipse4.png'),
                        fit: BoxFit.fitWidth,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(SizeConfig.heightMultiplier * 8,
                            SizeConfig.heightMultiplier * 8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: SizeConfig.heightMultiplier * 56.1,
            left: SizeConfig.imageSizeMultiplier * 14.68,
            child: Transform.rotate(
              angle: -3.382115337180968e-8 * (math.pi / 180),
              child: Container(
                width: SizeConfig.heightMultiplier * 7,
                height: SizeConfig.heightMultiplier * 7,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(249, 245, 255, 1),
                  border: Border.all(
                    color: const Color.fromRGBO(231, 213, 255, 1),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(SizeConfig.heightMultiplier * 7,
                        SizeConfig.heightMultiplier * 7),
                  ),
                ),
                child: Transform.rotate(
                  angle: -3.382115337180968e-8 * (math.pi / 180),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Ellipse5.png'),
                        fit: BoxFit.fitWidth,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(SizeConfig.heightMultiplier * 7,
                            SizeConfig.heightMultiplier * 7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: SizeConfig.heightMultiplier * 44.27,
            left: SizeConfig.imageSizeMultiplier * 77.49,
            child: Transform.rotate(
              angle: -3.382115337180968e-8 * (math.pi / 180),
              child: Container(
                width: SizeConfig.heightMultiplier * 8.5,
                height: SizeConfig.heightMultiplier * 8.5,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(249, 245, 255, 1),
                  border: Border.all(
                    color: const Color.fromRGBO(231, 213, 255, 1),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(SizeConfig.heightMultiplier * 8.5,
                        SizeConfig.heightMultiplier * 8.5),
                  ),
                ),
                child: Transform.rotate(
                  angle: -3.382115337180968e-8 * (math.pi / 180),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Ellipse6.png'),
                        fit: BoxFit.fitWidth,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(SizeConfig.heightMultiplier * 8.5,
                            SizeConfig.heightMultiplier * 8.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: SizeConfig.heightMultiplier * 48.11,
            left: SizeConfig.imageSizeMultiplier * 39.13,
            child: Transform.rotate(
              angle: -3.382115337180968e-8 * (math.pi / 180),
              child: Container(
                width: SizeConfig.heightMultiplier * 6.8,
                height: SizeConfig.heightMultiplier * 6.8,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(249, 245, 255, 1),
                  border: Border.all(
                    color: const Color.fromRGBO(231, 213, 255, 1),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(SizeConfig.heightMultiplier * 6.8,
                        SizeConfig.heightMultiplier * 6.8),
                  ),
                ),
                child: Transform.rotate(
                  angle: -3.382115337180968e-8 * (math.pi / 180),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Ellipse7.png'),
                        fit: BoxFit.fitWidth,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(SizeConfig.heightMultiplier * 6.8,
                            SizeConfig.heightMultiplier * 6.8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 125,
            left: 41.9803771972656,
            child: Container(
              width: 283,
              height: 178,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Text(
                      'Welcome To',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color.fromRGBO(144, 144, 159, 1),
                        fontFamily: 'Inter',
                        fontSize: 18,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                        height: 1,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color.fromRGBO(33, 35, 37, 1),
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 55,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                        Text(
                          'Dynamics',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color.fromRGBO(33, 35, 37, 1),
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 55,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    var curve1 = Path();
    curve1.moveTo(size.width * 0.5, 0);
    // curve1.lineTo(size.width, size.height * 0.4);
    curve1.quadraticBezierTo(
        size.width * 0.6, size.height * 0.3, size.width, size.height * 0.4);
    canvas.drawPath(curve1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
