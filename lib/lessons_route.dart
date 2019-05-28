import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/lesson.dart';
import 'package:classroom/widget_passer.dart';
import 'package:classroom/nav.dart';
import 'package:classroom/database_manager.dart';
import 'package:classroom/auth.dart';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class LessonsRoute extends StatefulWidget{
  final String author, name, accessCode, authorId;
  final int participants;
  final bool owner;

  const LessonsRoute({
    @required this.authorId,
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
  ScrollController _scrollController;

  List<Lesson> _lessons;

  @override
  void initState() {
    super.initState();

    _lessonPasser = Nav.lessonPasser;

    _scrollController = ScrollController();

    _lessons = List<Lesson>();
    // DatabaseManager.getLessonsPerCourse(widget.accessCode).then(
    //   (List<String> ls) => setState(() {
    //     List<String> _lessonsListString = List<String>();
    //     _lessonsListString = ls;
    //     DatabaseManager.getLessonsPerCourseByList(_lessonsListString, Auth.uid).then(
    //       (List<Lesson> lc) => setState(() {
    //         for(var lesson in lc){
    //           lesson.authorId = widget.authorId;
    //           _lessons.add(lesson);
    //         }
    //       })
    //     );         
    //   })
    // );

    FirebaseDatabase.instance.reference().child("lessonsPerCourse").child(widget.accessCode).onChildAdded.listen((data) {
      setState(() {
        List<String> lista = new List<String>();
        String newCourse = data.snapshot.value["lesson"];
        print("curso: $newCourse");
        lista.add(newCourse);
        DatabaseManager.getLessonsPerCourseByList(lista, Auth.uid).then(
          (List<Lesson> lc){
            if(this.mounted){
              setState(() {
                for(var lesson in lc){
                  lesson.authorId = widget.authorId;
                  Map text = {
                    //TODO: obtener los comentarios de la lección.
                    'lessonId': lesson.lessonId,
                    'name' : lesson.name,
                    'day' : lesson.day,
                    'month' : lesson.month, 
                    'year': lesson.year,
                    'comments': lesson.comments,
                    'owner': widget.owner,
                    'authorId': widget.authorId,
                  };
                  String textLesson = json.encode(text);
                  Nav.lessonPasser.sendWidget.add(textLesson);
                }
              });
            }
          }
        );        
      });
    });


    _lessonPasser.recieveWidget.listen((newLesson){
      if(newLesson != null){
        Map jsonLesson = json.decode(newLesson);
        if(this.mounted){
          setState(() {
            _lessons.add(
              Lesson(
                presentation: jsonLesson['presentation'],
                lessonId: jsonLesson['lessonId'],
                name: jsonLesson['name'],
                day: jsonLesson['day'],
                month: jsonLesson['month'],
                year: jsonLesson['year'],
                comments: jsonLesson['comments'],
                owner: widget.owner,
                authorId: widget.authorId,
              )
            );
          });
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(
              milliseconds: 500,
            ),  
            curve: Curves.ease,
          );
        }
      }
    });
    
  }

  @override
  void dispose() {
    super.dispose();
    _lessonPasser.sendWidget.add(null);
  }

  Widget _getCourseAuthor(BuildContext context){
    if(widget.owner) return Container();
    else return Row(
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
            size: 3,
            color: Theme.of(context).accentColor,
          ),
        ),
      ],
    );
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
                        _getCourseAuthor(context),
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
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(
                controller: _scrollController,
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
          Container(
            height: 65,
            decoration: BoxDecoration(
              //color: Colors.white,
              border: Border(
                top: BorderSide(
                  color:Color.fromARGB(10, 0, 0, 0),
                  width: 3,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Agrega nuevos miembros:',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    Text(
                      widget.accessCode,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}