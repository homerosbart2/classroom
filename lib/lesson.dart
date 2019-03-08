import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';

class Lesson extends StatefulWidget{
  final String name, description;
  final int month, day;

  const Lesson({
    @required this.name,
    this.description: '',
    this.month: 0,
    this.day: 0,
  });

  _LessonState createState() => _LessonState();
}

class _LessonState extends State<Lesson>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                            '105',
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
                              '7/12/18',
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
    );
  }
} 