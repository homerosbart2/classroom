import 'package:flutter/material.dart';

class Course extends StatefulWidget{
  final String name, author;
  final Color color;
  final int lessons;

  const Course({
    @required this.name,
    @required this.author,
    @required this.lessons,
    this.color,
  });

  @override
  _CourseState createState() => _CourseState();
}

class _CourseState extends State<Course>{
  Color _color;

  @override
  void initState() {
    super.initState();
    if(widget.color == null){
      _color = Colors.redAccent[100];
    }else{
      _color = widget.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: (){
        print('Esto sirve ggg.');
      },
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: Container(
          margin: EdgeInsets.all(6),
          padding: EdgeInsets.all(6),
          color: _color,
          child: Column(
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
              Text(
                widget.author,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                alignment: Alignment(0, 0),
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
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
        ),
      ),
    );
  }
}