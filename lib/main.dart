import 'package:flutter/material.dart';
import 'package:classroom/login.dart';

void main() {
  runApp(Classroom());
}

class Classroom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classroom',
      theme: ThemeData(fontFamily: 'Roboto Condensed', primaryColor: Color.fromARGB(255, 255, 96, 64), accentColor: Color.fromARGB(255, 0, 11, 43)),
      home: Login(),
    );
  }
}