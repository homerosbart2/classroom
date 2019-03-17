import 'package:flutter/material.dart';
import 'package:classroom/stateful_textfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatBar extends StatefulWidget{
  const ChatBar();

  _ChatBarState createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).accentColor,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: StatefulTextfield(
                    color: Theme.of(context).accentColor,
                    fillColor: Colors.white,
                    suffix: '',
                    hint: 'Escriba una pregunta',
                    borderRadius: 30,
                    padding: EdgeInsets.fromLTRB(15, 15, 45, 15),
                    onSubmitted: (text){
                      print(text);
                    },
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  margin: EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          FontAwesomeIcons.paperclip,
                          size: 18,
                        ),
                        onPressed: (){},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 60,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.check,
                      size: 18,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: (){},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}