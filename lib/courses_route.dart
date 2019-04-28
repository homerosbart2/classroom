import 'package:flutter/material.dart';
import 'package:classroom/course.dart';
import 'package:classroom/widget_passer.dart';
import 'dart:convert';
import 'dart:async';
import 'package:classroom/nav.dart';
import 'package:classroom/database_manager.dart';

class CoursesRoute extends StatefulWidget{

  const CoursesRoute();

  @override
  _CoursesRouteState createState() => _CoursesRouteState();
}

class _CoursesRouteState extends State<CoursesRoute> with TickerProviderStateMixin{
  WidgetPasser _coursePasser;
  List<Course> _coursesList;


  @override
  void initState() {
    super.initState();
    _coursesList = List<Course>();
    _coursePasser = Nav.coursePasser;
    if(_coursesList == null){
       DatabaseManager.getCoursesPerUser().then(
          (List<Course> l) => setState(() {_coursesList = l;})
       );
    }
    
    _coursePasser.recieveWidget.listen((newCourse){
      if(newCourse != null){
        Map jsonCourse = json.decode(newCourse);
        if(this.mounted){
          setState(() {
            _coursesList.add(
              Course(
                accessCode: jsonCourse['accessCode'],
                participants: jsonCourse['participants'],
                name: jsonCourse['name'],
                author: jsonCourse['author'],
                lessons: jsonCourse['lessons'],
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
    super.dispose();
    _coursePasser.sendWidget.add(null);
  }

  @override
  Widget build(BuildContext context) {
    return _getGridView();
  }
}