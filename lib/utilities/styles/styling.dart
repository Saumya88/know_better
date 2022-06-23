import 'package:flutter/material.dart';

const kInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFF6F6F7),
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFF6F6F7),
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.red,
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFF6F6F7),
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.red,
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);
