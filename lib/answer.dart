import 'package:flutter/material.dart';
import 'package:classroom/vote.dart';

class Answer extends StatefulWidget{
  final String author, text;
  final bool voted, mine, owner;
  final int votes;

  const Answer({
    @required this.author,
    @required this.text,
    this.voted: false,
    this.mine: false,
    this.owner: false,
    this.votes: 1,
  });

  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer>{

  @override
  void initState() {
    super.initState();
  }

  Color _getTextColor(BuildContext context){
    if(widget.owner) return Colors.white;
    else return Theme.of(context).accentColor;
  }

  Color _getColor(BuildContext context){
    if(widget.owner) return Theme.of(context).accentColor;
    else return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            child: Vote(
              voted: widget.voted,
              votes: widget.votes,
              showVotes: false,
              small: true,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(48, 6, 12, 6),
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _getColor(context),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 3),
                child: Text(
                  widget.author,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  )
                ),
              ),
              Text(
                widget.text,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: _getTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}