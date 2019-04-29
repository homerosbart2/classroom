import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/lesson.dart';

class LessonsRoute extends StatefulWidget{
  final String author, name, accessCode;
  final int participants;

  const LessonsRoute({
    @required this.author,
    @required this.name,
    @required this.accessCode,
    this.participants: 1,
  });

  _LessonsRouteState createState() => _LessonsRouteState();
}

class _LessonsRouteState extends State<LessonsRoute>{
  List<Lesson> _lessons;

  @override
  void initState() {
    super.initState();

    _lessons = List<Lesson>();

    _lessons.add(
      Lesson(
        name: 'Pipes',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      )
    );

    _lessons.add(
      Lesson(
        name: 'Thread',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a augue at eros dignissim fermentum eget non velit. Praesent et rutrum mi. Curabitur malesuada mattis tellus, ac accumsan quam fringilla sit amet.',
      )
    );

    _lessons.add(
      Lesson(
        name: 'Mutex',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a augue at eros dignissim fermentum eget non velit. Praesent et rutrum mi. Curabitur malesuada mattis tellus, ac accumsan quam fringilla sit amet.',
      )
    );

    _lessons.add(
      Lesson(
        name: 'Pipes',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      )
    );

    _lessons.add(
      Lesson(
        name: 'Thread',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a augue at eros dignissim fermentum eget non velit. Praesent et rutrum mi. Curabitur malesuada mattis tellus, ac accumsan quam fringilla sit amet.',
      )
    );

    _lessons.add(
      Lesson(
        name: 'Mutex',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a augue at eros dignissim fermentum eget non velit. Praesent et rutrum mi. Curabitur malesuada mattis tellus, ac accumsan quam fringilla sit amet.',
      )
    );

    _lessons.add(
      Lesson(
        name: 'Pipes',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      )
    );

    _lessons.add(
      Lesson(
        name: 'Thread',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a augue at eros dignissim fermentum eget non velit. Praesent et rutrum mi. Curabitur malesuada mattis tellus, ac accumsan quam fringilla sit amet.',
      )
    );

    _lessons.add(
      Lesson(
        name: 'Mutex',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a augue at eros dignissim fermentum eget non velit. Praesent et rutrum mi. Curabitur malesuada mattis tellus, ac accumsan quam fringilla sit amet.',
      )
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.plusCircle,
                          size: 16,
                          color: Theme.of(context).accentColor,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          widget.accessCode,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 16,
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