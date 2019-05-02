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

class Question extends StatefulWidget{
  static WidgetPasser answerPasser, answeredPasser;
  final String text, author, authorId, questionId;
  final bool voted, mine, answered, owner;
  final int votes, index, day, month, year, hours, minutes;
  final StreamController<int> votesController;

  Question({
    @required this.text,
    @required this.author,
    @required this.authorId,
    @required this.questionId,
    this.votesController,
    this.mine : false,
    this.voted : false,
    this.answered : false,  
    this.owner : false, 
    this.votes : 0,
    this.index : 0,
    this.day : 27,
    this.month : 3,
    this.year : 1998,
    this.hours : 11,
    this.minutes : 55,
  });

  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  Color _questionColor, _answerColor;
  Widget _header;
  WidgetPasser _answerPasser, _answeredPasser;
  AnimationController _expandAnswersController;
  Animation<double> _expandHeightFloat, _angleFloat;
  List<Answer> _answers;
  String _timeDate;
  AnimationController _boxResizeOpacityController;
  Animation<double> _sizeFloat, _opacityFloat;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    String day = (widget.day < 10)? '0${widget.day}' : '${widget.day}';
    String month = (widget.month < 10)? '0${widget.month}' : '${widget.month}';
    String year = '${widget.year}';
    String hours = (widget.hours < 10)? '0${widget.hours}' : '${widget.hours}';
    String minutes = (widget.minutes < 10)? '0${widget.minutes}' : '${widget.minutes}';

    _timeDate = '$day/$month/$year - $hours:$minutes';

    _answerPasser = WidgetPasser();
    _answeredPasser = WidgetPasser();

    _answers = List<Answer>();
    
    _questionColor = _answerColor = Colors.transparent;
    _header = Container();

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

    if(widget.answered) _boxResizeOpacityController.forward();

    _answers.add(
      Answer(
        author: 'Creador',
        text: 'Significa que únicamente se está utilizando como ejemplo para demostrar su utilización en la aplicación.',
        voted: true,
        owner: true,
      )
    );
    _answers.add(
      Answer(
        author: 'José Pérez',
        text: 'Ha de ser porque es de ejemplo.',
        voted: false,
        owner: false,
      )
    );

    _answerPasser.recieveWidget.listen((newAnswer){
      if(newAnswer!= null){
        Map jsonAnswer = json.decode(newAnswer);
        if(this.mounted){
          setState(() {
            _answers.add(
              Answer(
                author: jsonAnswer['author'],
                text: jsonAnswer['text'],
                owner: jsonAnswer['owner'],
                voted: false,
                votes: 0,
              )
            );
          });
        }
      }
    });

    _answeredPasser.recieveWidget.listen((newAction){
      if(newAction!= null){
        if(this.mounted){
          _boxResizeOpacityController.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    
    _answerPasser.sendWidget.add(null);
  }

  void _construcQuestions(BuildContext context){
    if(widget.mine){
      _questionColor = Theme.of(context).primaryColorLight;
      _answerColor = Theme.of(context).accentColor;
    }else{
      _questionColor = Theme.of(context).cardColor;
      _answerColor = Theme.of(context).accentColor;
      _header = Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 9),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 3,
                    color: Theme.of(context).accentColor,
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
    }
  }

  Widget _getAnsweredTag(){
    return FadeTransition(
      opacity: _opacityFloat,
      child: ScaleTransition(
        scale: _sizeFloat,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 9),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
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

  @override
  Widget build(BuildContext context) {
    _construcQuestions(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(14, 7, 0, 7),
                //padding: EdgeInsets.all(9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                color: _questionColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _header,
                    Container(
                      padding: EdgeInsets.fromLTRB(9, 9, 9, 0),
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          //fontSize: 18,
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
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Tooltip(
                            message: 'Respuestas',
                            child: GestureDetector(
                              onTap: (){
                                Vibration.vibrate(duration: 20);
                                if(_expandAnswersController.status == AnimationStatus.dismissed || _expandAnswersController.reverse == AnimationStatus.dismissed){
                                  _expandAnswersController.forward();
                                }else{
                                  _expandAnswersController.reverse();
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 3),
                                color: _questionColor,
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
                                                color: Theme.of(context).accentColor,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'RESPUESTAS',
                                            style: TextStyle(
                                              color: Theme.of(context).accentColor,
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
                        Expanded(
                          child: Tooltip(
                            message: 'Responder',
                            child: GestureDetector(
                              onTap: (){
                                Vibration.vibrate(duration: 20);
                                if(InteractRoute.questionPositionController.status == AnimationStatus.dismissed || InteractRoute.questionPositionController.status == AnimationStatus.reverse){
                                  InteractRoute.questionController.add(widget.text);
                                  InteractRoute.questionPositionController.forward();
                                  _expandAnswersController.forward();
                                  Question.answerPasser = _answerPasser;
                                  Question.answeredPasser = _answeredPasser;
                                  ChatBar.mode = 1;
                                  FocusScope.of(context).requestFocus(ChatBar.chatBarFocusNode);
                                  ChatBar.labelPasser.sendWidget.add('Escriba una respuesta');
                                }else{
                                  InteractRoute.questionPositionController.reverse();
                                  ChatBar.mode = 0;
                                  ChatBar.labelPasser.sendWidget.add('Escriba una pregunta');
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 3),
                                color: _questionColor,
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
                                              color: Theme.of(context).accentColor,
                                            ),
                                          ),
                                          Text(
                                            'RESPONDER',
                                            style: TextStyle(
                                              color: Theme.of(context).accentColor,
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
              
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 3),
          child: Vote(
            voted: widget.voted,
            votes: widget.votes,
            onVote: (){
              DatabaseManager.addVoteToQuestion(Auth.uid, widget.questionId, "1");
              InteractRoute.questions.replaceRange(widget.index, widget.index + 1, [Question(
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
              DatabaseManager.addVoteToQuestion(Auth.uid, widget.questionId, "-1");
              InteractRoute.questions.replaceRange(widget.index, widget.index + 1, [Question(
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
      ],
    );
  }
}