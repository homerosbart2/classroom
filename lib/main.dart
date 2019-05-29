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
      theme: ThemeData(
        fontFamily: 'Roboto Condensed', 
        primaryColor: Color.fromARGB(255, 255, 96, 64), 
        primaryColorLight: Color.fromARGB(255, 255, 235, 231),
        accentColor: Color.fromARGB(255, 0, 11, 43),
        cardColor: Color.fromARGB(255, 233, 238, 255),
      ),
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Login()
      ),
    );
  }
}