import 'package:flutter/material.dart';
import 'dart:async';
import 'package:classroom/question.dart';
import 'package:classroom/presentation.dart';
import 'package:classroom/chatbar.dart';

class InteractRoute extends StatefulWidget{
  static AnimationController questionPositionController;
  static List<Question> questions;
  static StreamController<String> questionController;

  const InteractRoute();

  _InteractRouteState createState() => _InteractRouteState();
}

class _InteractRouteState extends State<InteractRoute> with SingleTickerProviderStateMixin{
  StreamController<int> _votesController;
  Stream<int> _votesStream;
  Stream<String> _questionStream;
  Animation<Offset> _offsetFloat;
  String _questionToAnswer;
  Widget _presentation;

  @override
  void initState() {
    super.initState();

    _questionToAnswer = '';

    _presentation = Presentation(
      file: 'lib/assets/pdf/sample2.pdf',
    );

    _votesController = StreamController<int>();
    _votesStream = _votesController.stream;

    InteractRoute.questionController = StreamController<String>();
    _questionStream = InteractRoute.questionController.stream;

    InteractRoute.questions = List<Question>();

    InteractRoute.questionPositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetFloat = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: InteractRoute.questionPositionController,
        curve: Curves.easeInOut,
      ),
    );

    InteractRoute.questions.add(
      Question(
        text: '¿Qué significa que sea una presentación de ejemplo?',
        author: 'Diego Alay',
        authorId: '',
        voted: true,
        votes: 69,
        index: 0,
        votesController: _votesController,
      )
    );

    InteractRoute.questions.add(
      Question(
        text: '¿Qué día es hoy?',
        author: 'Henry Campos',
        authorId: '',
        mine: true,
        index: 1,
        votesController: _votesController,
      )
    );

    _votesStream.listen((val) {
      if(val != null){
        setState(() {
          
        });
      }
    });

    _questionStream.listen((text) {
      if(text != null){
        setState(() {
          _questionToAnswer = text;
        });
      }
    });
  }

  

  Widget _getListView(double width, double height){
    final List<Question> _actualQuestions = List.from(InteractRoute.questions);
    return ListView.builder(
      // physics: ScrollPhysics(
      //   parent: BouncingScrollPhysics(),
      // ),
      padding: EdgeInsets.only(top: 10, bottom: 10),
      itemCount: _actualQuestions.length + 1,
      itemBuilder: (context, index){
        if(index == 0){
          return Container(
            padding: EdgeInsets.all(12),
            width: width,
            height: height,
            child: _presentation,
          );
        }else{
          return _actualQuestions.elementAt(index - 1);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = (_width/4)*3;
    return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(bottom: 68),
                  child: _getListView(_width, _height),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 68,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _offsetFloat,
              child: Container(
                color: Theme.of(context).accentColor,
                padding: EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: FractionallySizedBox(
                  widthFactor: 1,
                    child: Text(
                    _questionToAnswer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ChatBar(

          ),   
        ],
      ),
    );
  }
}

