import 'package:flutter/material.dart';
import 'package:classroom/vote.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:classroom/interact_route.dart';
import 'dart:async';
import 'package:classroom/answer.dart';
import 'widget_passer.dart';
import 'package:classroom/chatbar.dart';
import 'dart:convert';
import 'package:classroom/database_manager.dart';
import 'package:classroom/auth.dart';
import 'package:firebase_database/firebase_database.dart';


class Question extends StatefulWidget {
  static WidgetPasser answerPasser, answeredPasser;
  static String globalQuestionId;
  final String text, author, authorId, questionId, lessonId;
  String courseAuthorId;
  bool voted, mine, answered, owner;
  int votes, index, day, month, year, hours, minutes;
  StreamController<int> votesController;
  

  Question({
    @required this.text,
    @required this.author,
    @required this.authorId,
    @required this.questionId,
    @required this.lessonId,
    this.courseAuthorId,
    this.votesController,
    this.mine: false,
    this.voted: false,
    this.answered: false,
    this.owner: false,
    this.votes: 0,
    this.index: 0,
    this.day: 27,
    this.month: 3,
    this.year: 1998,
    this.hours: 11,
    this.minutes: 55,
  });

  
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Color _questionColor, _answerColor;
  Widget _header;
  WidgetPasser _answerPasser, _answeredPasser;
  AnimationController _expandAnswersController;
  Animation<double> _expandHeightFloat, _angleFloat;
  List<Answer> _answers;
  String _timeDate;
  AnimationController _boxResizeOpacityController;
  Animation<double> _sizeFloat, _opacityFloat;
  AnimationController _boxResizeOpacityController2, _deleteHeightController, _boxColorController;
  Animation<double> _sizeFloat2, _opacityFloat2, _deleteHeightFloat;
  Animation<Color> _colorFloat, _colorFloatText;
  Animation<Offset> _offsetVoteFloat;
  bool _disabled, _hasAnswers;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _hasAnswers = false;

    String day = (widget.day < 10) ? '0${widget.day}' : '${widget.day}';
    String month = (widget.month < 10) ? '0${widget.month}' : '${widget.month}';
    String year = '${widget.year}';
    String hours = (widget.hours < 10) ? '0${widget.hours}' : '${widget.hours}';
    String minutes =
        (widget.minutes < 10) ? '0${widget.minutes}' : '${widget.minutes}';

    _timeDate = '$day/$month/$year - $hours:$minutes';

    _answerPasser = WidgetPasser();
    _answeredPasser = WidgetPasser();

    _disabled = false;
    _answers = List<Answer>();

    _questionColor = _answerColor = Colors.transparent;
    _header = Container();

    _boxColorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetVoteFloat = Tween<Offset>(
      end: Offset(1.1, 0.0), 
      begin: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _boxColorController,
        curve: Curves.easeInOut,
      ),
    );

     _deleteHeightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _deleteHeightFloat = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _deleteHeightController,
        curve: Curves.easeInOut,
      ),
    );

    _expandAnswersController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _expandHeightFloat = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _expandAnswersController,
        curve: Curves.easeInOut,
      ),
    );

    _angleFloat = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(
      CurvedAnimation(
        parent: _expandAnswersController,
        curve: Curves.easeInOut,
      ),
    );

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

    _boxResizeOpacityController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _sizeFloat2 = Tween<double>(
      begin: 0.75,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _boxResizeOpacityController2,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((state){
      if(state == AnimationStatus.dismissed){
        print('Se eliminó la pregunta: ${widget.index}');
      }
    });

    _opacityFloat2 = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _boxResizeOpacityController2,
        curve: Curves.easeInOut,
      ),
    );

    _boxResizeOpacityController2.forward();
    if (widget.answered) _boxResizeOpacityController.forward();

    if (_answers.isEmpty) {
      DatabaseManager.getAnswersPerQuestion(Auth.uid, widget.questionId).then((List<String> ls){
        if(this.mounted) setState(() {
          List<String> _answersListString = List<String>();
          _answersListString = ls;
          DatabaseManager.getAnswersPerQuestionByList(_answersListString, widget.questionId).then((List<Answer> la){
            if(this.mounted) setState(() {
              if(la.isNotEmpty) {
                if(this.mounted) setState(() {
                  _hasAnswers = true;
                });
              }
              for (var answer in la) {
                DatabaseManager.getVotesToUserPerAnswer(Auth.uid, answer.answerId).then((voted) {
                  if(answer.authorId == Auth.uid) answer.mine = true;
                  if(answer.authorId == widget.courseAuthorId){
                    setState(() {
                      _boxResizeOpacityController.forward();                  
                    });
                    answer.owner = true;
                  }
                  if (voted) answer.voted = true;
                  setState(() {
                    _answers.add(answer);
                  });
                });
              }
            });
          });
        });
      });
    }

    FirebaseDatabase.instance.reference().child("questions").child(widget.questionId).onChildRemoved.listen((data) {
      _deleteQuestion();
    });

    // _answers.add(
    //   Answer(
    //     author: 'Creador',
    //     text: 'Significa que únicamente se está utilizando como ejemplo para demostrar su utilización en la aplicación.',
    //     voted: true,
    //     owner: true,
    //   )
    // );
    // _answers.add(
    //   Answer(
    //     author: 'José Pérez',
    //     text: 'Ha de ser porque es de ejemplo.',
    //     voted: false,
    //     owner: false,
    //   )
    // );

    _answerPasser.recieveWidget.listen((newAnswer) {
      if (newAnswer != null) {
        Map jsonAnswer = json.decode(newAnswer);
        if (this.mounted) {
          setState(() {
            _answers.add(Answer(
              author: jsonAnswer['author'],
              authorId: jsonAnswer['authorId'],
              answerId: jsonAnswer['answerId'],
              questionId: jsonAnswer['questionId'],
              text: jsonAnswer['text'],
              owner: jsonAnswer['owner'],
              voted: false,
              votes: 0,
            ));
          });
        }
      }
    });

    _answeredPasser.recieveWidget.listen((newAction) {
      if (newAction != null) {
        if (this.mounted) {
          _boxResizeOpacityController.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _boxResizeOpacityController2.dispose();
    _deleteHeightController.dispose();
    //_boxColorController.dispose();
    _boxResizeOpacityController.dispose();
    _expandAnswersController.dispose();
    _answerPasser.sendWidget.add(null);
    super.dispose();
  }

  //TODO: Método para eliminar pregunta.
  void _deleteQuestion(){
    _boxColorController.forward();
    if(this.mounted) setState(() {
      _disabled = true;
    });
  }

  void _construcQuestions(BuildContext context) {
    if (widget.mine) {
      _questionColor = Theme.of(context).primaryColorLight;
      _answerColor = Theme.of(context).accentColor;
    } else {
      _questionColor = Theme.of(context).cardColor;
      _answerColor = Theme.of(context).accentColor;
    }
  }

  Widget _getAnsweredTag() {
    return FadeTransition(
      opacity: _opacityFloat,
      child: ScaleTransition(
        scale: _sizeFloat,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 9),
          decoration: BoxDecoration(
            color: _colorFloatText.value,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Respondida',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getDeleteButton(BuildContext context){
    if(widget.mine || widget.owner){
      return SizeTransition(
        axis: Axis.vertical,
        sizeFactor: _deleteHeightFloat,
        child: Container(
          padding: EdgeInsets.symmetric(vertical:6, horizontal: 9),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Tooltip(
                  message: 'Eliminar pregunta',
                  child: GestureDetector(
                    onTap: (){
                      if(!_disabled){
                        //print(widget.index);
                        //_boxResizeOpacityController2.reverse();
                        DatabaseManager.deleteQuestion(widget.questionId, widget.lessonId, Auth.uid);
                        print("id: ${widget.questionId}");
                        _deleteHeightController.reverse();
                        _boxColorController.forward();
                        _expandAnswersController.reverse();
                        _disabled = true;
                        //TODO: Eliminar pregunta de la base de datos.
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Theme.of(context).accentColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'ELIMINAR',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }else{
      return Container();
    }
  }

  Widget _getHeader(){
    if(!widget.mine){
      return  Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 9),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 3,
                    color: _colorFloatText.value,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.author,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _colorFloatText.value,
                    ),
                  ),
                  /* Icon(
                    FontAwesomeIcons.solidCircle,
                    color: Theme.of(context).primaryColor,
                    size: 8,
                  ), */
                ],
              ),
            ),
          ),
        ],
      );
    }else{
      return Container();
    }
  }

  Widget _getAnswersButton(){
    if(_hasAnswers) return Tooltip(
      message: 'Respuestas',
      child: GestureDetector(
        onTap: (){
          if(!_disabled){
            Vibration.vibrate(duration: 20);
            if(_expandAnswersController.status == AnimationStatus.dismissed || _expandAnswersController.reverse == AnimationStatus.dismissed){
              _expandAnswersController.forward();
            }else{
              _expandAnswersController.reverse();
            }
          }
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 6, 0, 12),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 6),
                      child: RotationTransition(
                        turns: _angleFloat,
                        child: Icon(
                          FontAwesomeIcons.angleDown,
                          size: 12,
                          color: _colorFloatText.value,
                        ),
                      ),
                    ),
                    Text(
                      'RESPUESTAS',
                      style: TextStyle(
                        color: _colorFloatText.value,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    else return Container();
  }

  @override
  Widget build(BuildContext context) {
    _construcQuestions(context);

    _colorFloatText = ColorTween(
      begin: Theme.of(context).accentColor,
      end: Colors.grey,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeIn,
        parent: _boxColorController,
      ),
    );

    if(widget.mine){
      _colorFloat = ColorTween(
        begin: Theme.of(context).primaryColorLight,
        end: Colors.grey[200]
      ).animate(
        CurvedAnimation(
          curve: Curves.easeIn,
          parent: _boxColorController,
        ),
      );
    }else{
       _colorFloat = ColorTween(
        begin: Theme.of(context).cardColor,
        end: Colors.grey[200]
      ).animate(
        CurvedAnimation(
          curve: Curves.easeIn,
          parent: _boxColorController,
        ),
      );
    }

    return FadeTransition(
      opacity: _opacityFloat2,
      child: ScaleTransition(
        scale: _sizeFloat2,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _colorFloat,
                    builder: (context, child) => Container(
                      margin: EdgeInsets.fromLTRB(14, 7, 0, 7),
                      //padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: _colorFloat.value,
                      ),
                      child: GestureDetector(
                        onLongPress: (){
                          if(!_disabled){
                            Vibration.vibrate(duration: 20);
                            _deleteHeightController.forward();
                            print('Sale boton de eliminar');
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _getHeader(),
                            Container(
                              padding: EdgeInsets.fromLTRB(9, 9, 9, 0),
                              child: Text(
                                widget.text,
                                style: TextStyle(
                                  color: _colorFloatText.value,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical:6, horizontal: 9),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  _getAnsweredTag(),
                                  Text(
                                    _timeDate,
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            _getDeleteButton(context),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _getAnswersButton(),
                                ),
                                Expanded(
                                  child: Tooltip(
                                    message: 'Responder',
                                    child: GestureDetector(
                                      onTap: (){
                                        if(!_disabled){
                                          Vibration.vibrate(duration: 20);
                                          if(InteractRoute.questionPositionController.status == AnimationStatus.dismissed || InteractRoute.questionPositionController.status == AnimationStatus.reverse){
                                            InteractRoute.questionController.add(widget.text);
                                            InteractRoute.questionPositionController.forward();
                                            _expandAnswersController.forward();
                                            Question.answerPasser = _answerPasser;
                                            Question.globalQuestionId = widget.questionId;
                                            Question.answeredPasser = _answeredPasser;
                                            ChatBar.mode = 1;
                                            FocusScope.of(context).requestFocus(ChatBar.chatBarFocusNode);
                                            ChatBar.labelPasser.sendWidget.add('Escriba una respuesta');
                                          }else{
                                            InteractRoute.questionPositionController.reverse();
                                            ChatBar.mode = 0;
                                            ChatBar.labelPasser.sendWidget.add('Escriba una pregunta');
                                          }
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 3),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.fromLTRB(0, 6, 0, 12),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(right: 6),
                                                    child: Icon(
                                                      FontAwesomeIcons.solidCommentAlt,
                                                      size: 12,
                                                      color: _colorFloatText.value,
                                                    ),
                                                  ),
                                                  Text(
                                                    'RESPONDER',
                                                    style: TextStyle(
                                                      color: _colorFloatText.value,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizeTransition(
                              axis: Axis.vertical,
                              sizeFactor: _expandHeightFloat,
                              child: Container(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _answers,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SlideTransition(
              position: _offsetVoteFloat,
              child: Container(
                margin: EdgeInsets.only(right: 3),
                child: Vote(
                  voted: widget.voted,
                  votes: widget.votes,
                  onVote: (){
                    DatabaseManager.addVoteToQuestion(widget.lessonId, Auth.uid, widget.questionId, "1");
                    InteractRoute.questions.replaceRange(widget.index, widget.index + 1, [Question(
                      lessonId: widget.lessonId,
                      questionId: widget.questionId,
                      authorId: widget.authorId,
                      author: widget.author,
                      text: widget.text,
                      voted: true,
                      votes: widget.votes + 1,
                      index: widget.index,
                      mine: widget.mine,
                      votesController: widget.votesController,
                    )]);
                    //widget.votesController.add(1);
                  },
                  onUnvote: (){
                    DatabaseManager.addVoteToQuestion(widget.lessonId, Auth.uid, widget.questionId, "-1");
                    InteractRoute.questions.replaceRange(widget.index, widget.index + 1, [Question(
                      lessonId: widget.lessonId,
                      authorId: widget.authorId,
                      questionId: widget.questionId,
                      author: widget.author,
                      text: widget.text,
                      voted: false,
                      votes: widget.votes - 1,
                      index: widget.index,
                      mine: widget.mine,
                      votesController: widget.votesController,
                    )]);
                    //widget.votesController.add(1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}