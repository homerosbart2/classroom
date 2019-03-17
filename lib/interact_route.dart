import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:async';
import 'package:classroom/stateful_textfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/lesson.dart';
import 'package:classroom/question.dart';

class InteractRoute extends StatefulWidget{
  const InteractRoute();
  static List<Question> questions;

  _InteractRouteState createState() => _InteractRouteState();
}

class _InteractRouteState extends State<InteractRoute>{
  Widget _presentation;
  StreamController<int> _votesController;
  Stream<int> _votesStream;

  @override
  void initState() {
    super.initState();

    _votesController = StreamController<int>();
    _votesStream = _votesController.stream;

    InteractRoute.questions = List<Question>();

    InteractRoute.questions.add(
      Question(
        text: '¿Qué significa que sea una presentación de ejemplo?',
        author: 'Diego Alay',
        voted: true,
        votes: 69,
        index: 0,
        votesController: _votesController,
      )
    );

    InteractRoute.questions.add(
      Question(
        text: '¿Qué día es hoy?',
        author: 'Henry Campos',
        mine: true,
        index: 1,
        votesController: _votesController,
      )
    );

    InteractRoute.questions.add(
      Question(
        text: '¿Qué significa que sea una presentación de ejemplo?',
        author: 'Diego Alay',
        voted: true,
        votes: 69,
        index: 2,
        votesController: _votesController,
      )
    );

    InteractRoute.questions.add(
      Question(
        text: '¿Qué día es hoy?',
        author: 'Henry Campos',
        mine: true,
        index: 3,
        votesController: _votesController,
      )
    );

    InteractRoute.questions.add(
      Question(
        text: '¿Qué significa que sea una presentación de ejemplo?',
        author: 'Diego Alay',
        voted: true,
        votes: 69,
        index: 4,
        votesController: _votesController,
      )
    );

    InteractRoute.questions.add(
      Question(
        text: '¿Qué día es hoy?',
        author: 'Henry Campos',
        mine: true,
        index: 5,
        votesController: _votesController,
      )
    );

    _construc().then((trick){
      setState(() {
        _presentation = trick;
      });
    });

    _votesStream.listen((val) {
      if(val != null){
        setState(() {
          
        });
      }
    });
  }

  Future<NativePDFView> _construc() async{
    return Future.delayed(const Duration(milliseconds: 370), () => 
      NativePDFView(
        loader: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 1,
          child: Container(
            color: Theme.of(context).accentColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'CARGANDO...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ),
      // Load from assets
      pdfFile: 'lib/assets/pdf/sample2.pdf',
      isAsset: true,
      // or load from file system
      // pdfFile: 'path/to/file',
      // isAsset: false,
      pageBuilder: (imageFile) => PhotoView(
        imageProvider: FileImage(imageFile),
        basePosition: Alignment(0, 0),
        backgroundDecoration: BoxDecoration(
          color: Colors.transparent,
        ),
      ),
    ),
    
    );
  }

  Widget _getListView(double width, double height){
    final List<Question> _actualQuestions = List.from(InteractRoute.questions);
    return ListView.builder(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      itemCount: _actualQuestions.length + 1,
      itemBuilder: (context, index){
        if(index == 0){
          return Container(
            padding: EdgeInsets.all(12),
            width: width,
            height: height,
            child: _presentation,
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
          ),    
        ],
      ),
    );
  }
}

