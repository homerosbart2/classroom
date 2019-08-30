import 'package:classroom/youtube_video.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:classroom/question.dart';
import 'package:classroom/chatbar.dart';
import 'package:classroom/presentation.dart';
import 'package:classroom/widget_passer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'stateful_button.dart';
import 'package:classroom/auth.dart';
import 'dart:convert';
import 'package:classroom/database_manager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InteractRoute extends StatefulWidget{
  
  final String lessonId, presentationPath, authorId, courseId;
  static AnimationController questionPositionController, questionOpacityController;
  static List<Question> questions;
  static StreamController<String> questionController;
  static WidgetPasser updateQuestions = WidgetPasser(); 
  static int index = 0;
  final bool owner, isVideo, fileExists;
  
  InteractRoute({
    @required this.lessonId,
    @required this.authorId,
    @required this.courseId,
    @required this.isVideo,
    this.presentationPath: '',
    this.fileExists: false,
    this.owner: false,
  });

  _InteractRouteState createState() => _InteractRouteState();
}

class _InteractRouteState extends State<InteractRoute> with TickerProviderStateMixin{
  StreamController<int> _votesController;
  Stream<int> _votesStream;
  Stream<String> _questionStream;
  Animation<Offset> _offsetFloat;
  Animation<double> _opacityFloat;
  String _questionToAnswer;
  Widget _presentation, _uploadPresentation;
  WidgetPasser _questionPasser, _updateQuestions, _pathPasser;
  ScrollController _scrollController;
  bool _presentationExist, _presentationLoaded, _lessonDisabled, _courseDisabled;

  Future<String> getFilePath() async {
    String filePath = null;
    try {
      filePath = await FilePicker.getFilePath(type: FileType.PDF);
      if (filePath == '') {
        return null;
      }
      print("File path: " + filePath);

    }catch (e) {
      print("Error picking the file: " + e.toString());
    }
    return filePath;
  }


  @override
  void initState() {
    super.initState();
    _presentationExist = false;
    _presentationLoaded = false;
    _lessonDisabled = false;
    _courseDisabled = false;

    _questionToAnswer = '';

    _scrollController = ScrollController();

    _questionPasser = ChatBar.questionPasser;
    _pathPasser = WidgetPasser();
    _updateQuestions = InteractRoute.updateQuestions;

    InteractRoute.questionOpacityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );

    _opacityFloat = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: InteractRoute.questionOpacityController,
        curve: Curves.easeInOut,
      ),
    );

    // _presentation = Presentation(
    //   file: 'lib/assets/pdf/sample.pdf',
    // ); 

    // try {
    //   var result = await InternetAddress.lookup('google.com');
    //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //     print('connected');
    //   }
    // } on SocketException catch (_) {
    //   print('not connected');
    // }

    DatabaseManager.getFieldInDocument("lessons",widget.lessonId,"presentation").then((presentation){
      if(this.mounted){
        if(presentation == true){
          if(this.mounted) setState(() {
            _presentationExist = true;
          });
          DatabaseManager.getFiles("pdf", widget.lessonId).then((path){
            print("ARCHIVO:  $path");
            if(path != 'EXCEPTION'){
              if(this.mounted) setState(() {
                _presentation = Presentation(
                  file: path,
                );
                _presentationLoaded = true;
              });
            }else{
              if(this.mounted) setState(() {
                _presentation = Text(
                  'EXCEPCION :c',
                );
                _presentationLoaded = true;
              });
            }
          });
        }else{
          setState(() {
            _presentationLoaded = true;
          });
        }
      }
    }); 

    // FirebaseDatabase.instance.reference().child("lessons").child(widget.lessonId).onChildRemoved.listen((data) {
    //   if(this.mounted) setState(() {
    //     _lessonDisabled = true;
    //   });
    // });
    
    // FirebaseDatabase.instance.reference().child("courses").child(widget.courseId).onChildRemoved.listen((data) {
    //   if(this.mounted) setState(() {
    //     _courseDisabled = trufe;
    //   });
    // });

    // FirebaseDatabase.instance.reference().child("lessons").child(widget.lessonId).onChildChanged.listen((data) {
    //   var value = (data.snapshot.value);
    //   String key = data.snapshot.key;
    //   print("key: $key");
    //   print("value: $value");
    //   switch(key){
    //     case "presentation":{
    //       if(value == true){
    //         if(this.mounted){
    //           setState(() {
    //             DatabaseManager.getFiles("pdf", widget.lessonId).then((path){
    //             print("ARCHIVO:  $path");
    //               if(this.mounted) setState(() {
    //                 _presentation = Presentation(
    //                   file: path,
    //                   animationValue: _turnsFloat.value,
    //                 );
    //               });
    //             });
    //           });
    //         }
    //       }
    //       break;
    //     }
    //   }
    // });

    if(widget.owner){
      _uploadPresentation = Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 24),
            child: StatefulButton(
              text: 'CARGAR\nPRESENTACIÓN',
              fontSize: 13,
              color: Colors.grey,
              borderColor: Colors.transparent,
              icon: FontAwesomeIcons.arrowAltCircleUp,
              onTap: (){
                getFilePath().then((filePath){
                  setState((){
                    if(filePath != null){
                      DatabaseManager.uploadFiles("pdf", widget.lessonId, filePath).then((path){
                        setState(() {
                          _presentationExist = true; 
                          print('PATH: $path');
                          _presentation = Presentation(
                            file: path,
                          );
                        });
                      });
                    }
                  });
                });
              },
            ),
          ),
          Container(
            child: StatefulButton(
              text: 'CARGAR VIDEO',
              fontSize: 13,
              color: Colors.grey,
              borderColor: Colors.transparent,
              icon: FontAwesomeIcons.youtube,
              onTap: (){
                // getFilePath().then((filePath){
                  setState((){
                    if(true != null){
                      //TODO send URL to this method 
                      DatabaseManager.uploadFiles("url", widget.lessonId, "https://youtu.be/Bydc-zhfdgM").then((path){
                        setState(() {
                          _presentationExist = true; 
                          print('PATH VIDEO: $path');
                          // _presentation = Presentation(
                            // file: path,
                          // );
                        });
                      });
                    }
                  });
                // });
              },
            ),
          ),
        ],
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

    Firestore.instance.collection("lessons").document(widget.lessonId).collection("questions").orderBy("votes", descending: true).snapshots().listen((snapshot) async{
      InteractRoute.index = 0;
      List<DocumentChange> docs = snapshot.documentChanges;
      Question question;
      for(var doc in docs){
        if (doc.type == DocumentChangeType.added){
          await DatabaseManager.getFieldInDocument("lessons/" + widget.lessonId + "/questions/" + doc.document.documentID + "/votes",Auth.uid,"voted").then((voted){
            question = new Question(
              lessonId: widget.lessonId,
              questionId: doc.document.documentID,
              text: doc.document.data['text'],
              author: doc.document.data['author'],
              authorId: doc.document.data['authorId'],
              day: doc.document.data['day'],
              month: doc.document.data['month'],
              year: doc.document.data['year'],
              hours: doc.document.data['hours'],
              minutes: doc.document.data['minutes'],                
              votes: doc.document.data['votes'],
              isVideo: widget.isVideo,
              index: InteractRoute.index++,
            );
            if(question.authorId == Auth.uid) question.mine = true;
            if(voted) question.voted = true;
            // if(question.votes > 0) question.answered = true;
            question.courseAuthorId = widget.authorId;
            if(this.mounted){
              setState(() {
                InteractRoute.questions.add(question);
              });
            }
          });
        }else if (doc.type == DocumentChangeType.modified){
          print("document change");
        }
      }      
    });

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
      if(newQuestion != null){
        Map jsonQuestion = json.decode(newQuestion);
        if(this.mounted){
          setState(() {
            InteractRoute.questions.add(
              Question(
                lessonId: widget.lessonId,
                authorId: jsonQuestion['authorId'],
                questionId: jsonQuestion['questionId'],
                courseAuthorId: jsonQuestion['courseAuthorId'],
                text: jsonQuestion['text'],
                author: jsonQuestion['author'],
                day: jsonQuestion['day'],
                month: jsonQuestion['month'],
                year: jsonQuestion['year'],
                hours: jsonQuestion['hours'],
                minutes: jsonQuestion['minutes'],
                owner: jsonQuestion['owner'],
                mine: jsonQuestion['mine'],
                index: InteractRoute.index++,
                votesController: _votesController,
                isVideo: widget.isVideo,
              )
            );
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(
                milliseconds: 500,
              ),  
              curve: Curves.ease,
            );
          });
        }
      }
    });

    _pathPasser.recieveWidget.listen((path) {
      if (path != null) {
        setState(() {
          _presentation = Presentation(
            file: path,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _questionPasser.sendWidget.add(null);
    _pathPasser.sendWidget.add(null);
    InteractRoute.updateQuestions.sendWidget.add(null);
    InteractRoute.index = 0;
    super.dispose();
  }

  Widget _getPresentation(BuildContext context){
    if(widget.isVideo){
      return YouTubeVideo();
    }if(!_presentationExist && _presentationLoaded){
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
    }else if(!_presentationExist || !_presentationLoaded){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitRing(
              color: Theme.of(context).accentColor,
              size: 30.0,
              lineWidth: 4,
            ),
          ],
        ),
      );
    }else{
      return _presentation;
    }
  }

  Widget _getListView(double width, double height, BuildContext context){
    final List<Question> _actualQuestions = List.from(InteractRoute.questions);
    return ListView.builder(
      reverse: false,
      controller: _scrollController,
      // physics: ScrollPhysics(
      //   parent: BouncingScrollPhysics(),
      // ),
      padding: EdgeInsets.only(top: 0, bottom: 12),
      itemCount: _actualQuestions.length + 1,
      itemBuilder: (context, index){
        if(index == 0){
          if(widget.isVideo){
            return Container(
                  child: _getPresentation(context),
                );
          }else{
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              width: width,
              height: height + 68,
              child: _getPresentation(context),
            );
          }
        }else{
          return _actualQuestions.elementAt(index - 1);
        }
      },
    );
  }

  String _getDisabledText(){
    if(_lessonDisabled) return 'La lección ha sido eliminada.';
    else return 'El curso ha sido eliminado.';
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = (_width/4)*3;
    if(!_lessonDisabled && !_courseDisabled) return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(bottom: 68),
                  child: _getListView(_width, _height, context),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 68,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _opacityFloat,
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
          ),
          ChatBar(
            lessonId: widget.lessonId,
            owner: widget.owner,
          ),   
        ],
      ),
    );
    else return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _getDisabledText(),
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}