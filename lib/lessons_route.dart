import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/lesson.dart';
import 'package:classroom/widget_passer.dart';
import 'package:classroom/nav.dart';
import 'package:classroom/database_manager.dart';
import 'dart:convert';

class LessonsRoute extends StatefulWidget{
  final String author, name, accessCode;
  final int participants;
  final bool owner;

  const LessonsRoute({
    @required this.author,
    @required this.name,
    @required this.accessCode,
    this.participants: 1,
    this.owner: false,
  });

  _LessonsRouteState createState() => _LessonsRouteState();
}

class _LessonsRouteState extends State<LessonsRoute>{
  WidgetPasser _lessonPasser;

  List<Lesson> _lessons;

  @override
  void initState() {
    super.initState();

    _lessonPasser = Nav.lessonPasser;

    _lessons = List<Lesson>();
    DatabaseManager.getLessonsPerCourse(widget.accessCode).then(
      (List<String> ls) => setState(() {
        List<String> _lessonsListString = List<String>();
        _lessonsListString = ls;
        DatabaseManager.getLessonsPerCourseByList(_lessonsListString).then(
          (List<Lesson> lc) => setState(() {
            _lessons = lc;
          })
        );         
      })
    );

    _lessonPasser.recieveWidget.listen((newLesson){
      if(newLesson != null){
        Map jsonLesson = json.decode(newLesson);
        if(this.mounted){
          setState(() {
            _lessons.add(
              Lesson(
                name: jsonLesson['name'],
                day: jsonLesson['day'],
                month: jsonLesson['month'],
                year: jsonLesson['year'],
                comments: jsonLesson['comments'],
              )
            );
          });
        }
      }
    });
    
  }

  @override
  void dispose() {
    super.dispose();
    _lessonPasser.sendWidget.add(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:Color.fromARGB(10, 0, 0, 0),
                  width: 3,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          widget.name,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          widget.author,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 6, right: 3),
                          child: Icon(
                            FontAwesomeIcons.solidCircle,
                            size: 5,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        Icon(
                          FontAwesomeIcons.male,
                          size: 16,
                          color: Theme.of(context).accentColor,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            '${widget.participants}',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      widget.accessCode,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),     
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(
                // physics: ScrollPhysics(
                //   parent: BouncingScrollPhysics(),
                // ),
                padding: EdgeInsets.only(top: 10, bottom: 10),
                itemCount: _lessons.length,
                itemBuilder: (context, index){
                  return _lessons.elementAt(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}