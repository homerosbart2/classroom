import 'package:flutter/material.dart';
import 'package:classroom/stateful_textfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/widget_passer.dart';
import 'package:classroom/question.dart';
import 'package:classroom/interact_route.dart';
import 'dart:convert';
import 'package:classroom/database_manager.dart';
import 'package:classroom/auth.dart';

class ChatBar extends StatefulWidget{
  static WidgetPasser questionPasser = WidgetPasser(), answerPasser = WidgetPasser(), labelPasser = WidgetPasser();
  final bool owner;
  final String lessonId;
  
  static FocusNode chatBarFocusNode = FocusNode();
  static int mode;
  const ChatBar({
    @required this.lessonId,
    this.owner: false,
  });

  _ChatBarState createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar>{
  TextEditingController _chatBarTextfieldController;
  String _chatBarLabel;

  @override
  void initState() {
    super.initState();
    ChatBar.mode = 0;

    _chatBarLabel = 'Escribe una pregunta';

    _chatBarTextfieldController = TextEditingController();

    ChatBar.labelPasser.recieveWidget.listen((label){
      if(label != null && this.mounted){
        setState(() {
          _chatBarLabel = label;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    ChatBar.labelPasser.sendWidget.add(null);

    ChatBar.mode = 0;
  }

  void _onSubmittedFunction(String val){
    if(val.trim() != ''){
      //print(val);
      var nowDate = DateTime.now();
      int day = nowDate.day;
      int month = nowDate.month;
      int year = nowDate.year;
      int hours = nowDate.hour;
      int minutes = nowDate.minute;
      String authorId = Auth.uid;
      String author = Auth.getName();
      if(ChatBar.mode == 0){
        DatabaseManager.addQuestions(author, authorId, widget.lessonId, val, day, month, year, hours, minutes).then((id){
          Map text = {
            'text': val,
            'author': author,
            'authorId': authorId,
            'owner': widget.owner,
            'day': day,
            'month': month,
            'year': year,
            'hours': hours,
            'minutes': minutes,
            'questionId': id,
          };
          String textQuestion = json.encode(text);
          ChatBar.questionPasser.sendWidget.add(textQuestion);          
        });
      }else{
        String questionId = Question.globalQuestionId;
        DatabaseManager.addAnswers(questionId, author, authorId, widget.lessonId, val, day, month, year, hours, minutes).then((id){
          Map text = {
            'text': val,
            'author': author,
            'questionId': questionId,
            'authorId': authorId,
            'owner': widget.owner,
            'day': day,
            'month': month,
            'year': year,
            'hours': hours,
            'minutes': minutes,
            'answerId': id,
          };
          String textAnswer = json.encode(text);
          Question.answerPasser.sendWidget.add(textAnswer);
          if(widget.owner) Question.answeredPasser.sendWidget.add('1');
          InteractRoute.questionPositionController.reverse();
          ChatBar.labelPasser.sendWidget.add('Escriba una pregunta');
          ChatBar.mode = 0;          
        });        
      }
        _chatBarTextfieldController.text = '';
    }
    ChatBar.chatBarFocusNode.unfocus();
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
                    focusNode: ChatBar.chatBarFocusNode,
                    controller: _chatBarTextfieldController,
                    color: Theme.of(context).accentColor,
                    fillColor: Colors.white,
                    suffix: '',
                    hint: _chatBarLabel,
                    borderRadius: 30,
                    padding: EdgeInsets.fromLTRB(15, 15, 45, 15),
                    onSubmitted: (val){
                      _onSubmittedFunction(val);
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
                    onPressed: (){
                      _onSubmittedFunction(_chatBarTextfieldController.text);
                    },
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