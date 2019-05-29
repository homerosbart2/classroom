import 'package:flutter/material.dart';
import 'package:classroom/course.dart';
import 'package:classroom/widget_passer.dart';
import 'dart:convert';
import 'package:classroom/nav.dart';
import 'package:classroom/database_manager.dart';
import 'package:classroom/auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_utils/qr_utils.dart';

class CoursesRoute extends StatefulWidget{
  static WidgetPasser activateQRPasser = WidgetPasser();

  const CoursesRoute();

  @override
  _CoursesRouteState createState() => _CoursesRouteState();
}

class _CoursesRouteState extends State<CoursesRoute> with TickerProviderStateMixin{
  WidgetPasser _coursePasser;
  List<Course> _coursesList;
  DatabaseReference mDatabase = FirebaseDatabase.instance.reference();
  String _contentQR;

  void _scanQR() async{
    try{
      _contentQR = await QrUtils.scanQR;
    }catch(e){
      print(e);
    }
    if(_contentQR != null){
      DatabaseManager.addCourseByAccessCode(_contentQR, Auth.uid).then((Map text){
        if(text != null){  
          String textCourse = json.encode(text);
          print(textCourse);
          _coursePasser.sendWidget.add(textCourse);           
        }else{
          print("NO ENCONTRADO");
          //TODO: dialogo de curso no encontrado
        }              
      });  
    }
  }

  @override
  void initState() {
    super.initState();
    _coursesList = List<Course>();
    _coursePasser = Nav.coursePasser;
    if(_coursesList.isEmpty){
      DatabaseManager.getCoursesPerUser().then(
        (List<String> ls) => setState(() {
          List<String> _coursesListString = List<String>();
          _coursesListString = ls;
          DatabaseManager.getCoursesPerUserByList(_coursesListString, Auth.uid).then(
            (List<Course> lc) => setState(() {
              _coursesList = lc;
            })
          );         
        })
      );
    }

    CoursesRoute.activateQRPasser.recieveWidget.listen((value){
      if(value == 'QR'){
        _scanQR();
      }
    });

    _coursePasser.recieveWidget.listen((newCourse){
      if(newCourse != null){
        Map jsonCourse = json.decode(newCourse);
        if (this.mounted){
          setState(() {
            _coursesList.add(
              Course(
                courseId: jsonCourse['accessCode'],
                participants: jsonCourse['participants'],
                name: jsonCourse['name'],
                author: jsonCourse['author'],
                authorId: jsonCourse['authorId'],
                lessons: jsonCourse['lessons'],
                owner: jsonCourse['owner'],
              )
            );
          });
        }
      }
    });
  }
  

  Widget _getGridView(){
    final List<Course> _actualCoursesList = List.from(_coursesList);
    return OrientationBuilder(
      builder: (context, orientation){
        if(orientation == Orientation.portrait){
          return GridView.count(
            padding: EdgeInsets.all(6),
            crossAxisCount: 2,
            childAspectRatio: 1,
            children: _actualCoursesList,
          );
        }else{
          return GridView.count(
            padding: EdgeInsets.all(6),
            crossAxisCount: 4,
            childAspectRatio: 1,
            children: _actualCoursesList,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    CoursesRoute.activateQRPasser.sendWidget.add(null);
    _coursePasser.sendWidget.add(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _getGridView();
  }
}