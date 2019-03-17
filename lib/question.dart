import 'package:flutter/material.dart';
import 'package:classroom/vote.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:classroom/interact_route.dart';
import 'dart:async';

class Question extends StatefulWidget{
  final String text, author;
  final bool voted, mine;
  final int votes, index;
  final StreamController<int> votesController;

  const Question({
    @required this.text,
    @required this.author,
    @required this.votesController,
    this.mine : false,
    this.voted : false,
    this.votes : 0,
    this.index : 0,
  });

  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question>{
  Color _questionColor, _answerColor;
  Widget _header;

  @override
  void initState() {
    super.initState();
    
    _questionColor = _answerColor = Colors.transparent;
    _header = Container();
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
                  Icon(
                    FontAwesomeIcons.solidCircle,
                    color: Theme.of(context).primaryColor,
                    size: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
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
                margin: EdgeInsets.fromLTRB(14, 7, 0, 56),
                //padding: EdgeInsets.all(9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  ),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '17/03/2019  -  20:51',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                left: 14,
                right: 0,
                child: Tooltip(
                  message: 'Responder',
                  child: GestureDetector(
                    onTap: (){
                      Vibration.vibrate(duration: 20);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _answerColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                            child: Icon(
                              FontAwesomeIcons.solidCommentAlt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          /* Text(
                            'RESPONDER',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ), */
                        ],
                      ),
                    ),
                  ),
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
              widget.votesController.add(1);
            },
            onUnvote: (){
              InteractRoute.questions.replaceRange(widget.index, widget.index + 1, [Question(
                author: widget.author,
                text: widget.text,
                voted: false,
                votes: widget.votes - 1,
                index: widget.index,
                mine: widget.mine,
                votesController: widget.votesController,
              )]);
              widget.votesController.add(1);
            },
          ),
        ),
      ],
    );
  }
}