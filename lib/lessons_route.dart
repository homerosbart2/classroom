import 'package:flutter/material.dart';
import 'dart:async';
import 'package:classroom/question.dart';
import 'package:classroom/presentation.dart';
import 'package:classroom/chatbar.dart';
import 'package:classroom/widget_passer.dart';
import 'package:classroom/auth.dart';
import 'dart:convert';
import 'package:classroom/database_manager.dart';

class InteractRoute extends StatefulWidget{
  final String lessonId;
  static AnimationController questionPositionController;
  static List<Question> questions;
  static StreamController<String> questionController;
  static int index = 0;

  const InteractRoute({
    @required this.lessonId,
  });

  _InteractRouteState createState() => _InteractRouteState();
}

class _InteractRouteState extends State<InteractRoute> with SingleTickerProviderStateMixin{
  StreamController<int> _votesController;
  Stream<int> _votesStream;
  Stream<String> _questionStream;
  Animation<Offset> _offsetFloat;
  String _questionToAnswer;
  Widget _presentation;
  WidgetPasser _questionPasser;

  @override
  void initState() {
    super.initState();

    _questionToAnswer = '';

    _questionPasser = ChatBar.questionPasser;

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

    DatabaseManager.getQuestionsPerLesson(widget.lessonId).then(
        (List<String> ls) => setState(() {
          List<String> __questionsListString = List<String>();
          __questionsListString = ls;
          DatabaseManager.getQuestionsPerLessonByList(__questionsListString).then(
            (List<Question> lc) => setState(() {
              for(var question in lc){
                if(question.authorId == Auth.uid) question.mine = true;
                question.votesController = _votesController;
                question.voted = true;
                question.answered = true;
                question.index = InteractRoute.index++;
                InteractRoute.questions.add(question);
              }
            })
          );         
        })
    );

    
    InteractRoute.questions.add(
      Question(
        text: '¿Qué significa que sea una presentación de ejemplo?',
        author: 'Diego Alay',
        authorId: "123123",
        questionId: "12313123",
        voted: true,
        votes: 69,
        index: InteractRoute.index++,
        votesController: _votesController,
        answered: true,
      )
    );

    InteractRoute.questions.add(
      Question(
        authorId: "123123",
        questionId: "12313123",
        text: '¿Qué día es hoy?',
        author: 'Henry Campos',
        mine: true,
        index: InteractRoute.index++,
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

    _questionPasser.recieveWidget.listen((newQuestion){
      if(newQuestion != null){
        Map jsonCourse = json.decode(newQuestion);
        if(this.mounted){
          setState(() {
            String questionText = jsonCourse['text'];
            DatabaseManager.addQuestions(Auth.getName(), Auth.uid, widget.lessonId, questionText).then((id){
              print("id: $id");
              if(id != null){
                InteractRoute.questions.add(
                  Question(
                    questionId: id,
                    authorId: Auth.uid,
                    text: questionText,
                    author: Auth.getName(),
                    mine: true,
                    index: InteractRoute.index++,
                    votesController: _votesController,
                  )
                );
              }
            });
          });
        }
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
    _questionPasser.sendWidget.add(null);
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
