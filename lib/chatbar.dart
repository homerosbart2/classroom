import 'package:flutter/material.dart';
import 'package:classroom/stateful_textfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/widget_passer.dart';
import 'dart:convert';

class ChatBar extends StatefulWidget{
  static WidgetPasser questionPasser = WidgetPasser();
  static WidgetPasser answerPasser = WidgetPasser();
  const ChatBar();

  _ChatBarState createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar>{
  TextEditingController _chatBarTextfieldController;

  @override
  void initState() {
    super.initState();

    _chatBarTextfieldController = TextEditingController();
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
                    controller: _chatBarTextfieldController,
                    color: Theme.of(context).accentColor,
                    fillColor: Colors.white,
                    suffix: '',
                    hint: 'Escriba una pregunta',
                    borderRadius: 30,
                    padding: EdgeInsets.fromLTRB(15, 15, 45, 15),
                    onSubmitted: (val){
                      if(val.trim() != ''){
                        print(val);
                        Map text = {
                          'text': val,
                          'author': 'Henry Campos', 
                        };
                        String textQuestion = json.encode(text);
                        ChatBar.questionPasser.sendWidget.add(textQuestion);
                        _chatBarTextfieldController.text = '';
                      }
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