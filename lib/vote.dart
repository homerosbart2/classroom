import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';

class Vote extends StatefulWidget{
  final bool voted;
  final int votes, index;
  final Function onVote, onUnvote;

  const Vote({
    this.voted : false,
    this.votes : 0,
    this.index : 0,
    this.onVote,
    this.onUnvote,
  });

  _VoteState createState() => _VoteState();
}

class _VoteState extends State<Vote> with SingleTickerProviderStateMixin{
  Color _emptyColor, _solidColor;
  Widget _voteWidget;
  bool _voted;
  AnimationController _scaleController;
  Animation<double> _scaleFloat;
  int _votes;

  @override
  void initState() {
    super.initState();

    _votes = widget.votes;

    _voteWidget = Container();
    _voted = widget.voted;

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleFloat = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _construcVoteWidget(bool solid){
    setState(() {
      _scaleController.reset();
      if(!solid){
        _voteWidget = ScaleTransition(
          scale: _scaleFloat,
          child: IconButton(
            tooltip: 'Votar',
            splashColor: Theme.of(context).cardColor,
            icon: Icon(
              FontAwesomeIcons.star,
              size: 20,
              color: _emptyColor,
            ),
            onPressed: (){
              Vibration.vibrate(duration: 20);
              if(widget.onVote != null){
                widget.onVote();
              }
              _voted = true;
              if(widget.voted){
                _votes = widget.votes;
              }else{
                _votes = widget.votes + 1;
              }
              _construcVoteWidget(true);
            },
          ),
        );
      }else{
        _voteWidget = ScaleTransition(
          scale: _scaleFloat,
          child: IconButton(
            tooltip: 'Eliminar voto',
            splashColor: Theme.of(context).cardColor,
            icon: Icon(
              FontAwesomeIcons.solidStar,
              size: 20,
              color: _solidColor,
            ),
            onPressed: (){
              Vibration.vibrate(duration: 20);
              if(widget.onUnvote != null){
                widget.onUnvote();
              }
              _voted = false;
              if(widget.voted){
                _votes = widget.votes - 1;
              }else{
                _votes = widget.votes;
              }
              _construcVoteWidget(false);
            },
          ),
        );
      }
      _scaleController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      _emptyColor = Theme.of(context).accentColor;
      _solidColor = Theme.of(context).accentColor;
    });

    _construcVoteWidget(_voted);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _voteWidget,
        Container(
          margin: EdgeInsets.only(bottom: 10, right: 14, left: 14),
          child: Text(
            '$_votes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ],
    );
  }
}