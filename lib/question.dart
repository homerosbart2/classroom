import 'package:flutter/material.dart';
import 'package:classroom/vote.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:classroom/interact_route.dart';
import 'dart:async';
import 'package:classroom/answer.dart';

class Question extends StatefulWidget{
  final String text, author;
  final bool voted, mine, answered;
  final int votes, index;
  final StreamController<int> votesController;

  const Question({
    @required this.text,
    @required this.author,
    @required this.votesController,
    this.mine : false,
    this.voted : false,
    this.answered : false,  
    this.votes : 0,
    this.index : 0,
  });

  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  Color _questionColor, _answerColor;
  Widget _header;
  AnimationController _expandAnswersController;
  Animation<double> _expandHeightFloat, _angleFloat;
  List<Answer> _answers;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

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
    if(widget.answered){
      return Container(
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
      );
    }else{
      return Container();
    }
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
                            '17/03/2019  -  20:51',
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
                                }else{
                                  InteractRoute.questionPositionController.reverse();
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
              print(widget.index);
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