import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:classroom/nav.dart';
import 'package:classroom/lessons_route.dart';
import 'package:vibration/vibration.dart';

class Course extends StatefulWidget{
  final String name, author, accessCode, authorId;
  final Color color;
  final int lessons, participants;
  final bool owner;

  const Course({
    @required this.name,
    @required this.author,
    @required this.authorId, 
    @required this.lessons,
    @required this.participants,
    @required this.accessCode,
    this.color,
    this.owner: false,
  });

  @override
  _CourseState createState() => _CourseState();
}

class _CourseState extends State<Course> with SingleTickerProviderStateMixin{
  Color _color;
  AnimationController _boxResizeOpacityController;
  Animation<double> _sizeFloat, _opacityFloat;

  @override
  void initState() {
    super.initState();
    if(widget.color == null){
      _color = Colors.redAccent[100];
    }else{
      _color = widget.color;
    }

    _boxResizeOpacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _sizeFloat = Tween<double>(
      begin: 0.75, 
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _boxResizeOpacityController,
        curve: Curves.easeInOut,
      ),
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
  }

  Decoration _getCourseDecoration(BuildContext context){
    if(widget.owner){
      return BoxDecoration(
        border: Border.all(
          color: _color,
          width: 1,
        ),
        color: _color,
        borderRadius: BorderRadius.circular(3),
      );
    }else{
      return BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColorLight,
          width: 1,
        ),
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(3),
      );
    }
  }

  Widget _getCourseAuthor(){
    if(widget.owner){
      return Container();
    }else{
      return Text(
        widget.author,
        style: TextStyle(
          color: Theme.of(context).accentColor,
        ),
      );
    }
  }

  Widget _getProprietaryLabel(){
    if(false){
      return Text(
        'P',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }else{
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Vibration.vibrate(duration: 20);
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (BuildContext context) {
            return Nav(
              preferredSize: 65,
              section: 'lessons',
              user: 'Henry Campos',
              title: 'CLASES',
              subtitle: widget.name,
              body: LessonsRoute(
                name: widget.name,
                accessCode: widget.accessCode,
                author: widget.author,
                participants: widget.participants,
                owner: widget.owner,
              ),
            );
          }),
        );
      },
      splashColor: Colors.redAccent[100],
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: FadeTransition(
          opacity: _opacityFloat,
          child: ScaleTransition(
            scale: _sizeFloat,
            child: Container(
              margin: EdgeInsets.all(6),
              padding: EdgeInsets.all(6),
              decoration: _getCourseDecoration(context),
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      _getCourseAuthor(),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        alignment: Alignment(0, 0),
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.lessons} clases',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      decoration: BoxDecoration(
                        /* border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).accentColor,
                            width: 6,
                          ),
                        ), */
                        //borderRadius: BorderRadius.circular(30),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _getProprietaryLabel(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
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
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}