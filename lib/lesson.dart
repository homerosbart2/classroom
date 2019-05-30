import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/cupertino.dart';
import 'package:classroom/nav.dart';
import 'package:classroom/interact_route.dart';
import 'widget_passer.dart';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class Lesson extends StatefulWidget{
  final String name, description, lessonId, courseId;
  String authorId;
  final int month, day, year, comments;
  final bool owner, presentation;

  Lesson({
    @required this.lessonId,
    @required this.courseId,
    @required this.name,
    @required this.presentation,
    this.authorId,
    this.description: '',
    this.month: 1,
    this.day: 1,
    this.year: 1999,
    this.comments: 0,
    this.owner: false,
  });

  _LessonState createState() => _LessonState();
}

class _LessonState extends State<Lesson> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  AnimationController _boxResizeOpacityController, _lessonDeleteController;
  Animation<double> _opacityFloat;
  String _date, _description, _comments;
  Animation<Color> _deleteBackgroundColorFloat, _deleteTextColorFloat;
  bool _disabled;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    String day = (widget.day < 10)? '0${widget.day}' : '${widget.day}';
    String month = (widget.month < 10)? '0${widget.month}' : '${widget.month}';
    String year = '${widget.year}';

    _comments = '${widget.comments}';

    _date = '$day/$month/$year';

    _disabled = false;

    _lessonDeleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300)
    );

    _description = widget.description;

    _boxResizeOpacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _opacityFloat = Tween<double>(
      begin: 0, 
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _boxResizeOpacityController,
        curve: Curves.easeInOut,
      ),
    );

    _boxResizeOpacityController.forward();

    FirebaseDatabase.instance.reference().child("lessons").child(widget.lessonId).onChildChanged.listen((data) {
      if(mounted){
        setState(() {
          print("CAPTANDO CAMBIOS");
          print("SNAPSHOT KEY: ${data.snapshot.key}");
          print("SNAPSHOT VALUE: ${data.snapshot.value}");
          String value = (data.snapshot.value).toString();
          switch(data.snapshot.key){
            case "comments":{
              _comments = value;
              break;
            }
            case "description": {
              _description = value;
              break;
            }
            case "date": {
              String date = value.toString();
              _date = date.substring(0,2)+"/"+date.substring(2,4)+"/"+date.substring(4,value.length);
              break;
            }            
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _boxResizeOpacityController.dispose();
    super.dispose();
  }

  //TODO: Llamar para eliminar la leccion.
  void _deleteLesson(){
    _lessonDeleteController.forward();
    if(this.mounted) setState(() {
      _disabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _deleteBackgroundColorFloat = ColorTween(
      begin: Theme.of(context).cardColor,
      end: Colors.grey[200],
    ).animate(
      CurvedAnimation(
        parent: _lessonDeleteController,
        curve: Curves.easeIn,
      )
    );

    _deleteTextColorFloat = ColorTween(
      begin: Theme.of(context).accentColor,
      end: Colors.grey,
    ).animate(
      CurvedAnimation(
        parent: _lessonDeleteController,
        curve: Curves.easeIn,
      )
    );

    return FadeTransition(
      opacity: _opacityFloat,
      child: AnimatedBuilder(
        animation: _deleteBackgroundColorFloat,
        builder: (context, child) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            padding: EdgeInsets.fromLTRB(9, 0, 0, 0),
            decoration: BoxDecoration(
              color: _deleteBackgroundColorFloat.value,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 40, 0),
                  padding: EdgeInsets.only(right: 9),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        width: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 9, bottom: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              widget.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _deleteTextColorFloat.value,
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 3),
                                  child: Icon(
                                    FontAwesomeIcons.solidCommentAlt,
                                    size: 12,
                                    color: _deleteTextColorFloat.value,
                                  ),
                                ),
                                Text(
                                  '${widget.comments}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _deleteTextColorFloat.value,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _description,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: _deleteTextColorFloat.value,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 3, bottom: 9),
                                  child: Text(
                                    _date,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: _deleteTextColorFloat.value
                                    ),
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        child: Tooltip(
                          message: 'Acceder',
                          child: GestureDetector(
                            onTap: (){
                              if(!_disabled){
                                Vibration.vibrate(duration: 20);
                                print('funciona');
                                Navigator.of(context).push(
                                  CupertinoPageRoute(builder: (BuildContext context) {
                                    return Nav(
                                      elevation: 0,
                                      color: Colors.transparent,
                                      actionsColor: Theme.of(context).accentColor,
                                      titleColor: Theme.of(context).accentColor,
                                      addBarActive: true,
                                      drawerActive: false,
                                      notificationsActive: false,
                                      section: 'interact',
                                      title: widget.name,
                                      owner: widget.owner,
                                      idCourse: widget.courseId,
                                      idLesson: widget.lessonId,
                                      body: InteractRoute(
                                        authorId: widget.authorId,
                                        lessonId: widget.lessonId,
                                        presentationPath: '/data/user/0/com.example.classroom/cache/71197f9fec304ff5bca9104c0e29cd77.pdf',
                                        owner: widget.owner,
                                      ),
                                    ); 
                                  })
                                );
                              }
                            },
                            child: Container(
                              width: 40,
                              decoration: BoxDecoration(
                                color: _deleteTextColorFloat.value,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(3),
                                  bottomRight: Radius.circular(3),
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.only(right: 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.externalLinkSquareAlt,
                                      color: Colors.white,
                                      size: 17,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
              ],
            ),
          );
        }
      ),
    );
  }
} 