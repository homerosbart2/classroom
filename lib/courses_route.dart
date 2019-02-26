import 'package:flutter/material.dart';
import 'package:classroom/course.dart';

class CoursesRoute extends StatefulWidget{
  const CoursesRoute();

  @override
  _CoursesRouteState createState() => _CoursesRouteState();
}

class _CoursesRouteState extends State<CoursesRoute>{
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: OrientationBuilder(
        builder: (context, orientation){
          if(orientation == Orientation.portrait){
            return GridView.count(
              padding: EdgeInsets.all(6),
              crossAxisCount: 2,
              childAspectRatio: 1,
              children: <Widget>[
                Course(
                  lessons: 9,
                  name: 'Ciencias de la Computación 7',
                  author: 'Áxel Benavídez',
                ),
                Course(
                  lessons: 4,
                  name: 'Seminario Profesional 1',
                  author: 'Adrián Catalán',
                )
              ],
            );
          }else{
            return GridView.count(
              padding: EdgeInsets.all(6),
              crossAxisCount: 5,
              childAspectRatio: 1,
              children: <Widget>[
                Course(
                  lessons: 9,
                  name: 'Ciencias de la Computación 7',
                  author: 'Áxel Benavídez',
                ),
                Course(
                  lessons: 4,
                  name: 'Seminario Profesional 1',
                  author: 'Adrián Catalán',
                ),
              ],
            );
          }
        },
      ),
    );
  }
}