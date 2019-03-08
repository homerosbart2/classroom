import 'package:flutter/material.dart';
import 'package:classroom/course.dart';
import 'package:classroom/widget_passer.dart';
import 'dart:convert';
import 'package:classroom/nav.dart';

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

    _coursePasser = Nav.coursePasser;

    _coursesList = List<Course>();

    _coursesList.add(
      Course(
        accessCode: '45H3FS',
        participants: 23,
        lessons: 9,
        name: 'Ciencias de la Computación 7',
        author: 'Áxel Benavídez',
      )
    );

    _coursesList.add(
      Course(
        accessCode: '45H3FS',
        participants: 45,
        lessons: 5,
        name: 'Seminario Profesional 1',
        author: 'Adrián Catalán',
      )
    );

    _coursePasser.recieveWidget.listen((newCourse){
      if(newCourse != null){
        Map jsonCourse = json.decode(newCourse);
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