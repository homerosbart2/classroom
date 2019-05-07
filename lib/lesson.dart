import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/cupertino.dart';
import 'package:classroom/nav.dart';
import 'package:classroom/interact_route.dart';

class Lesson extends StatefulWidget{
  final String name, description, lessonId;
  final int month, day, year, comments;
  final bool owner;

  const Lesson({
    this.lessonId,
    @required this.name,
    this.description: '',
    this.month: 1,
    this.day: 1,
    this.year: 1999,
    this.comments: 0,
    this.owner: false,
  });

  _LessonState createState() => _LessonState();
}

class _LessonState extends State<Lesson> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  AnimationController _boxResizeOpacityController;
  Animation<double> _sizeFloat, _opacityFloat;
  String _date;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    String day = (widget.day < 10)? '0${widget.day}' : '${widget.day}';
    String month = (widget.month < 10)? '0${widget.month}' : '${widget.month}';
    String year = '${widget.year}';

    _date = '$day/$month/$year';

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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityFloat,
      child: ScaleTransition(
        scale: _sizeFloat,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          padding: EdgeInsets.fromLTRB(9, 0, 0, 0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 3),
                                child: Icon(
                                  FontAwesomeIcons.solidCommentAlt,
                                  size: 12,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              Text(
                                '${widget.comments}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.description,
                      textAlign: TextAlign.justify,
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
                            Vibration.vibrate(duration: 20);
                            print('funciona');
                            Navigator.of(context).push(
                              CupertinoPageRoute(builder: (BuildContext context) {
                                return Nav(
                                  elevation: 0,
                                  color: Colors.transparent,
                                  actionsColor: Theme.of(context).accentColor,
                                  titleColor: Theme.of(context).accentColor,
                                  addBarActive: false,
                                  drawerActive: false,
                                  notificationsActive: false,
                                  section: 'interact',
                                  user: 'Henry Campos',
                                  title: widget.name,
                                  body: InteractRoute(
                                    lessonId: widget.lessonId,
                                    //presentationPath: 'lib/assets/pdf/sample2.pdf',
                                    owner: widget.owner,
                                  ),
                                ); 
                              })
                            );
                          },
                          child: Container(
                            width: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
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
        ),
      ),
    );
  }
} 