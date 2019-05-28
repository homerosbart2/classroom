import 'package:flutter/material.dart';
import 'dart:async';
import 'package:classroom/question.dart';
import 'package:classroom/chatbar.dart';
import 'package:classroom/presentation.dart';
import 'package:classroom/widget_passer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'stateful_button.dart';
import 'package:vibration/vibration.dart';
import 'dart:convert';

class InteractRoute extends StatefulWidget{
  static AnimationController questionPositionController;
  static List<Question> questions;
  static StreamController<String> questionController;
  static WidgetPasser updateQuestions = WidgetPasser();
  static int index = 0;
  final String presentationPath;
  final bool owner;

  const InteractRoute({
    this.presentationPath: '',
    this.owner: false,
  });

  _InteractRouteState createState() => _InteractRouteState();
}

class _InteractRouteState extends State<InteractRoute> with SingleTickerProviderStateMixin{
  StreamController<int> _votesController;
  Stream<int> _votesStream;
  Stream<String> _questionStream;
  Animation<Offset> _offsetFloat;
  String _questionToAnswer;
  Widget _presentation, _uploadPresentation;
  WidgetPasser _questionPasser, _updateQuestions;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _questionToAnswer = '';

    _scrollController = ScrollController();

    _questionPasser = ChatBar.questionPasser;
    _updateQuestions = InteractRoute.updateQuestions;


    _presentation = Presentation(
      file: 'lib/assets/pdf/sample.pdf',
    );

    if(widget.owner){
      _uploadPresentation = StatefulButton(
        text: 'CARGAR PRESENTACIÓN',
        fontSize: 13,
        color: Colors.grey,
        borderColor: Colors.transparent,
        icon: FontAwesomeIcons.arrowAltCircleUp,
        onTap: (){
          Vibration.vibrate(duration: 20);
          //TODO: Hay que subir el archivo a FireBase y guardarlo en nuestra organizacion de archivos locales.
        },
      );
    }else{
      _uploadPresentation = Text(
        'No hay presentación cargada.',
        style: TextStyle(
          color: Colors.grey,
        ),
      ); 
    }

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

    InteractRoute.questions.add(
      Question(
        text: '¿Qué significa que sea una presentación de ejemplo?',
        author: 'Diego Alay',
        voted: true,
        votes: 69,
        index: InteractRoute.index++,
        votesController: _votesController,
        answered: true,
        owner: widget.owner,
      )
    );

    InteractRoute.questions.add(
      Question(
        text: '¿Qué día es hoy?',
        author: 'Henry Campos',
        mine: true,
        index: InteractRoute.index++,
        votesController: _votesController,
        owner: widget.owner,
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

    InteractRoute.updateQuestions.recieveWidget.listen((code){
      if(code != null){
        if(this.mounted){
          setState(() {
            
          });
        }
      }
    });

    _questionPasser.recieveWidget.listen((newQuestion){
      print('SE AGREGO ALGO NUEVO');
      if(newQuestion != null){
        Map jsonQuestion = json.decode(newQuestion);
        if(this.mounted){
          setState(() {
            InteractRoute.questions.add(
              Question(
                text: jsonQuestion['text'],
                author: jsonQuestion['author'],
                day: jsonQuestion['day'],
                month: jsonQuestion['month'],
                year: jsonQuestion['year'],
                hours: jsonQuestion['hours'],
                minutes: jsonQuestion['minutes'],
                owner: jsonQuestion['owner'],
                mine: true,
                index: InteractRoute.index++,
                votesController: _votesController,
              )
            );
          });
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(
              milliseconds: 500,
            ),  
            curve: Curves.ease,
          );
        }
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
    _questionPasser.sendWidget.add(null);
    InteractRoute.updateQuestions.sendWidget.add(null);
    InteractRoute.index = 0;
  }

  Widget _getPresentation(){
    if(false && widget.presentationPath == ''){
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(3),
          // border: Border.all(
          //   color: Colors.grey,
          //   width: 1,
          // ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _uploadPresentation,
              ],
            ),
          ],
        ),
      );
    }else{
      return _presentation;
    }
  }

  Widget _getListView(double width, double height){
    final List<Question> _actualQuestions = List.from(InteractRoute.questions);
    return ListView.builder(
      reverse: false,
      controller: _scrollController,
      // physics: ScrollPhysics(
      //   parent: BouncingScrollPhysics(),
      // ),
      padding: EdgeInsets.only(top: 12, bottom: 12),
      itemCount: _actualQuestions.length + 1,
      itemBuilder: (context, index){
        if(index == 0){
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            width: width,
            height: height + 68,
            child: _getPresentation(),
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
            owner: widget.owner,
          ),   
        ],
      ),
    );
  }
}

