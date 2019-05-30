import 'package:classroom/courses_route.dart';
import 'package:classroom/interact_route.dart';
import 'package:classroom/lessons_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/stateful_button.dart';
import 'package:classroom/notification_hub.dart';
import 'package:classroom/stateful_textfield.dart';
import 'package:classroom/widget_passer.dart';
import 'package:classroom/auth.dart';
import 'package:classroom/database_manager.dart';
import 'package:classroom/lesson.dart';
import 'package:classroom/chatbar.dart';
import 'dart:math';
import 'package:classroom/choice.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Nav extends StatefulWidget{
  static String addBarTitle;
  static int addBarMode;
  static WidgetPasser coursePasser = WidgetPasser();
  static WidgetPasser lessonPasser = WidgetPasser();
  final Widget body;
  final String title, section, subtitle, idCourse, idLesson;
  final double preferredSize, elevation;
  final bool drawerActive, addBarActive, notificationsActive, owner;
  final Color color, titleColor, actionsColor;
  final String acessCode;

  const Nav({
    @required this.body,
    @required this.title,
    @required this.section,
    this.elevation: 1.0,
    this.color,
    this.titleColor,
    this.actionsColor: Colors.white,
    this.addBarActive: true,
    this.drawerActive: true,
    this.notificationsActive: true,
    this.owner = false,
    this.subtitle: '',
    this.idCourse: 'NA',
    this.idLesson: 'NA',
    this.preferredSize: 60.0,
    this.acessCode,
  });

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> with TickerProviderStateMixin{
  var random = new Random();
  Animation<Offset> _offsetFloat;
  Animation<double> _widthFloat;
  TextEditingController _addBarTextfieldController;
  AnimationController _notificationHubPositionController;
  AnimationController _addButtonController;
  Animation<double> _angleFloat;
  AnimationController _addBarController, _addBarAlertController; 
  String _alertMessage;
  Color _titleColor, _color, _actionsColor;
  FocusNode _focusAddBarNodeLessons, _focusAddBarNodeCourses;
  SharedPreferences prefs;
  bool _resizeScaffold;

  DateTime selectedDate = DateTime.now();
  //WidgetPasser courseBloc = WidgetPasser();

  List<Choice> choices = <Choice>[
    Choice(title: 'Fecha', icon: FontAwesomeIcons.calendar),
    Choice(title: 'Descripción', icon: FontAwesomeIcons.pen),
    Choice(title: 'Eliminar', icon: FontAwesomeIcons.pen),
  ];

  @override
  void initState() {
    super.initState();

    _initSharedPreferences();

    _resizeScaffold = widget.section == 'interact';
  
    Nav.addBarTitle = ''; 
    Nav.addBarMode = 0;

    _alertMessage = '';

    _addBarTextfieldController = TextEditingController();

    _addButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _notificationHubPositionController =AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _angleFloat = Tween<double>(
      begin: 0, 
      end: 0.125,
    ).animate(
      CurvedAnimation(
        parent: _addButtonController,
        curve: Curves.easeInOut,
      ),
    );

    _focusAddBarNodeCourses = FocusNode();
    _focusAddBarNodeLessons = FocusNode();
    
    _addBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    

    _offsetFloat = Tween<Offset>(
      begin: Offset(0.0, -1.1), 
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _addBarController,
        curve: Curves.easeInOut,
      ),
    );

    _addBarAlertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    

    _widthFloat = Tween<double>(
      begin: 0, 
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _addBarAlertController,
        curve: Curves.easeInOut,
      ),
    );
    //_addButtonController.forward();
  }

  int getRandom(){
    return random.nextInt(100000);
  }

  void _initSharedPreferences() async{
    prefs = await SharedPreferences.getInstance();
  }

  Widget _postAlertInAddBar(){
    if(_alertMessage == ''){
      return Container();
    }else{
      return SizeTransition(
        sizeFactor: _widthFloat,
        axis: Axis.vertical,
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 1, 0, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 5),
                child: Icon(
                  FontAwesomeIcons.exclamationCircle,
                  color: Theme.of(context).primaryColor,
                  size: 12,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  _alertMessage,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  FocusNode _getFocusNode(){
    if(widget.section == 'courses') return _focusAddBarNodeCourses;
    else if(widget.section == 'lessons') return _focusAddBarNodeLessons;
    else return _focusAddBarNodeCourses;
  }

  Widget _construcAddBar(double width){
    if(widget.addBarActive){
      return Positioned(
        left: 0,
        top: 0,
        child: SlideTransition(
          position: _offsetFloat,
          child: Container(
            padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
            width: width,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color.fromARGB(50, 0, 0, 0),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StatefulTextfield(
                  controller: _addBarTextfieldController,
                  focusNode: _getFocusNode(),
                  fillColor: Colors.white,
                  suffix: '',
                  color: Theme.of(context).accentColor,
                  helper: null,
                  hint: Nav.addBarTitle,
                  type: TextInputType.text,
                  onSubmitted: (val){
                    String authorId = Auth.uid;
                    String author = Auth.getName();
                    String code = this.getRandom().toString();
                    if(val.trim() != ''){
                      if(Nav.addBarMode == 0){
                        if(widget.section == 'courses'){
                          DatabaseManager.addCourse(authorId,author,val).then((accessCode){
                            Map text = {
                              //TODO: Generar un nuevo código y agregar el curso a la base de datos.
                              'name' : val,
                              'authorId': authorId,
                              'author' : author,
                              'lessons' : 0,
                              'participants' : 1, 
                              'accessCode': accessCode,
                              'owner': true,
                            };
                            String textCourse = json.encode(text);
                            print(textCourse);
                            Nav.coursePasser.sendWidget.add(textCourse);
                          });
                        }else if(widget.section == 'lessons'){
                          var nowDate = DateTime.now();
                          int day = nowDate.day;
                          int month = nowDate.month;
                          int year = nowDate.year;
                          DatabaseManager.addLesson(Auth.uid, val, "", day, month, year, widget.acessCode);
                          // Map text = {
                          //   //TODO: obtener los comentarios de la lección.
                          //   'name' : val,
                          //   'day' : nowDate.day,
                          //   'month' : nowDate.month, 
                          //   'year': nowDate.year,
                          //   'comments': 0,
                          // };
                          // String textLesson = json.encode(text);
                          // Nav.lessonPasser.sendWidget.add(textLesson);
                        }
                         _addButtonController.reverse();
                        _addBarController.reverse().then((val){
                          _addBarTextfieldController.text = '';
                          if(_addBarAlertController.status != AnimationStatus.dismissed){
                            _addBarAlertController.reverse();
                          }
                        });
                      }else if(Nav.addBarMode == 1){
                        DatabaseManager.actionOnFieldFrom("coursesPerUser", Auth.uid, val, "course", "course", "", "i", "get").then((valid){
                          if(valid == ""){
                            DatabaseManager.addCourseByAccessCode(val,Auth.uid).then((dynamic text){
                              if(text == null){  
                                setState(() {
                                // Notify.show(
                                //     context: context,
                                //     text: 'El curso no existe.',
                                //     actionText: 'Ok',
                                //     backgroundColor: Colors.red[200],
                                //     textColor: Colors.black,
                                //     actionColor: Colors.black,
                                //     onPressed: (){
                                      
                                //     }
                                //   );   
                                  print("NO EXISTE");                               
                                });            
                              }else{
                                String textCourse = json.encode(text);
                                print(textCourse);
                                Nav.coursePasser.sendWidget.add(textCourse);
                                _addButtonController.reverse();
                                _addBarController.reverse().then((val){
                                  _addBarTextfieldController.text = '';
                                  if(_addBarAlertController.status != AnimationStatus.dismissed){
                                    _addBarAlertController.reverse();
                                  }
                                });                            
                              }              
                            }); 
                          }else{
                            // Notify.show(
                            //   context: context,
                            //   text: 'El curso ya ha sido agregado.',
                            //   actionText: 'Ok',
                            //   backgroundColor: Colors.red[200],
                            //   textColor: Colors.black,
                            //   actionColor: Colors.black,
                            //   onPressed: (){
                                
                            //   } 
                            // );                           
                            print("DUPLICADO"); 
                          }
                        });                                                                      
                      }else if(Nav.addBarMode == 2){
                        print('DESCRIPCION: $val');
                        print('CURSO: ${widget.idCourse}');
                        print('LECCION: ${widget.idLesson}');
                        //TODO: Guardar la nueva descripcion en firebase
                        DatabaseManager.updateLesson(widget.idLesson, val,"description");
                        _addBarController.reverse().then((val){
                          _addBarTextfieldController.text = '';
                          if(_addBarAlertController.status != AnimationStatus.dismissed){
                            _addBarAlertController.reverse();
                          }
                        }); 
                        ChatBar.chatBarOffsetController.reverse().then((val){
                          InteractRoute.questionOpacityController.reverse();
                        }); 
                      }
                    }else{
                      FocusScope.of(context).requestFocus(_getFocusNode());
                      setState(() {
                        _alertMessage = 'El nombre contiene solo espacios en blanco.'; 
                      });
                      _addBarAlertController.forward();
                    }
                  },
                  // /* onChangedFunction: (val){
                  //   this.setState(() {   
                  //   });
                  // }, */
                ),
                _postAlertInAddBar(),
              ],
            ),
          ),
        ),
      );
    }else{
      return Container();
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate){
      setState(() {
        selectedDate = picked;
      });
      print(picked.day);
      Map text = {
        //TODO: Guardar la fecha en firebase, yo actualizo la vista.
        'day' : picked.day,
        'month': picked.month,
        'year' : picked.year,
      };
      String textDate = json.encode(text);
      print("ANTES");
      DatabaseManager.updateLesson(widget.idLesson, picked.day.toString()+picked.month.toString()+picked.year.toString(),"date");
      print('FECHA: $textDate');
      print('LECCION: ${widget.idCourse}');
      print('LECCION: ${widget.idLesson}');
    }
  }

  List<Widget> _construcActions(){
    List<Widget> actions = List<Widget>();
    if(widget.section == 'courses' || widget.section == 'lessons'){
      if(widget.section == 'courses'){
        actions.add(
          IconButton(
            icon: Icon(
              FontAwesomeIcons.qrcode,
              size: 20,
            ),
            tooltip: 'Unirse por QR',
            onPressed: (){
              CoursesRoute.activateQRPasser.sendWidget.add('QR');
            },
          )
        );
        actions.add(
          IconButton(
            icon: Icon(
              FontAwesomeIcons.key,
              size: 20,
            ),
            tooltip: 'Unirse por código',
            onPressed: (){
              final status = _addBarController.status;

              if(status == AnimationStatus.completed){
                _addBarController.reverse(
                  from: 1
                ).then((val){
                  if(_addBarAlertController.status != AnimationStatus.dismissed){
                    _addBarAlertController.reverse();
                  }
                });
                _addButtonController.reverse();
                FocusScope.of(context).requestFocus(new FocusNode());
              }else if(status == AnimationStatus.dismissed){
                Nav.addBarTitle = "Ingrese el código del curso";
                Nav.addBarMode = 1;

                _addBarController.forward(
                  from: 0
                );
                _addButtonController.forward();
                FocusScope.of(context).requestFocus(_getFocusNode());
                _notificationHubPositionController.reverse();
              }
            },
          )
        );
      }
      if((widget.section == 'lessons' && widget.owner) || widget.section == 'courses'){
        actions.add(
          RotationTransition(
            turns: _angleFloat,
            child: IconButton(
              icon: Icon(
                FontAwesomeIcons.plus,
                size: 20,
              ), 
              tooltip: 'Agregar curso',
              onPressed: () {
                final status = _addBarController.status;

                if(status == AnimationStatus.completed){
                  _addBarController.reverse(
                    from: 1
                  ).then((val){
                    if(_addBarAlertController.status != AnimationStatus.dismissed){
                      _addBarAlertController.reverse();
                    }
                  });
                  _addButtonController.reverse();
                  FocusScope.of(context).requestFocus(new FocusNode());
                }else if(status == AnimationStatus.dismissed){
                  setState(() {
                    if(widget.section == 'courses') Nav.addBarTitle = "Ingrese el nombre del curso";
                    else if(widget.section == 'lessons') Nav.addBarTitle = "Ingrese el nombre de la lección";
                    Nav.addBarMode = 0;
                  });
                  _addBarController.forward(
                    from: 0
                  );
                  _addButtonController.forward();
                  FocusScope.of(context).requestFocus(_getFocusNode());
                  _notificationHubPositionController.reverse();
                }
              },
            ),
          )
        );
      }
    }else if(widget.section == 'interact' && widget.owner){
      actions.add(
        PopupMenuButton<Choice>(
          onSelected: (choice){
            if(choice.title == 'Eliminar'){
              print('ELIMINAR LECCION: ${widget.idLesson}');
              print('DEL CURSO: ${widget.idCourse}');
              DatabaseManager.deleteLesson(widget.idLesson, Auth.uid);
              //TODO: Eliminar la leccion de firebase.
            }else if(choice.title == 'Fecha'){
              _selectDate(context);
            }else if(choice.title == 'Descripción'){
              final status = _addBarController.status;
              if(status == AnimationStatus.completed){
                _addBarController.reverse(
                  from: 1
                ).then((val){
                  if(_addBarAlertController.status != AnimationStatus.dismissed){
                    _addBarAlertController.reverse();
                  }
                });
                ChatBar.chatBarOffsetController.reverse().then((value){
                  InteractRoute.questionOpacityController.reverse();
                });
                FocusScope.of(context).requestFocus(new FocusNode());
              }else if(status == AnimationStatus.dismissed){
                  setState(() {
                    Nav.addBarTitle = "Ingrese la nueva descripción";
                    Nav.addBarMode = 2;
                  });
                  _addBarController.forward(
                    from: 0
                  );
                  ChatBar.chatBarOffsetController.forward();
                  InteractRoute.questionOpacityController.forward();
                  FocusScope.of(context).requestFocus(_getFocusNode());
                }
            }
          },
          itemBuilder: (BuildContext context) {
            return choices.skip(0).map((Choice choice) {
              return PopupMenuItem<Choice>(
                value: choice,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          choice.title,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
        )
      );
    }
    if(false && widget.notificationsActive){
      actions.add(
        Container(
          padding: EdgeInsets.fromLTRB(0, 4, 5, 0),
          child: Stack(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.solidBell,
                  size: 20,
                ),
                tooltip: 'Notificaciones',
                onPressed: (){
                  print("Sigue funcionando");
                  _notificationHubPositionController.forward();
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        )
      );
    }
    if(widget.section == 'lessons' && widget.owner){
      actions.add(
        PopupMenuButton<Choice>(
          onSelected: (choice){
            if(choice.title == 'Eliminar'){
              print('ELIMINAR CURSO: ${widget.idCourse}');
              //TODO: Eliminar el curso de firebase.
              DatabaseManager.deleteCourse(widget.idCourse, Auth.uid);
            }
          },
          itemBuilder: (BuildContext context) {
            return choices.skip(2).map((Choice choice) {
              return PopupMenuItem<Choice>(
                value: choice,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          choice.title,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
        )
      );
    }
    return actions;
  }

  Widget _construcDrawer(){
    if(widget.drawerActive){
      return Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Classroom',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'Vampiro One',
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(Auth.getPhotoUrl()),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(right: 2),
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                Auth.getName(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 2),
                          child: Text(
                            'Ver más',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('lib/assets/images/bg_dark.jpg'),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]))
              ),
              child: ListTile(
                title: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: StatefulButton(
                        type: 'a',
                        icon: FontAwesomeIcons.book,
                        text: '',
                        color: Theme.of(context).accentColor,
                        onTap: (){},
                      ),
                    ),
                    Text(
                      'Cursos',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  if(widget.section == 'lessons'){
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]))
              ),
              child: ListTile(
                title: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: StatefulButton(
                        type: 'a',
                        icon: FontAwesomeIcons.signOutAlt,
                        text: '',
                        color: Theme.of(context).accentColor,
                        onTap: (){},
                      ),
                    ),
                    Text(
                      'Salir',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  //TODO: Cerrar la sesión del usuario.
                  Auth.signOut().then((_)
                  {
                    prefs.setInt('logged', 0);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    if(widget.section == 'lessons') Navigator.of(context).pop();
                  });
                },
              ),
            ),
          ],
        ),
      );
    }else{
      return null;
    }
  }

  Widget _construcTitle(){
    if(widget.titleColor == null){
      _titleColor = Theme.of(context).primaryColor;
    }else{
      _titleColor = widget.titleColor;
    }

    if(widget.subtitle == ''){
      return Text(
        widget.title,
        style: TextStyle(
          color: _titleColor,
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          //fontFamily: 'Vampiro One'
        ),
      );
    }else{
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(
              color: _titleColor,
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              //fontFamily: 'Vampiro One'
            ),
          ),
          Text(
            widget.subtitle,
            style: TextStyle(
              color: Colors.redAccent[100],
              fontSize: 15,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    if(widget.color == null){
      _color = Theme.of(context).accentColor;
    }else{
      _color = widget.color;
    }

    return Container(
      color: Theme.of(context).accentColor,
      padding: EdgeInsets.only(top: widget.preferredSize - 60.0),
      child: WillPopScope(
        onWillPop: () async{
          
          return (widget.section != 'courses');
        },
        child: Scaffold(
              resizeToAvoidBottomPadding: _resizeScaffold,
              drawer: _construcDrawer(),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(widget.preferredSize),
                child: AppBar(
                  actions: _construcActions(),
                  elevation: widget.elevation,
                  title: Container(
                    margin: EdgeInsets.only(top: (widget.preferredSize - 60.0)/2.0 + 2),
                    child: _construcTitle(),
                  ), 
                  centerTitle: false,
                  backgroundColor: _color,
                  iconTheme: IconThemeData(
                    color: widget.actionsColor,
                  ),
                ),
              ),
              body: Stack(
                children: <Widget>[
                  widget.body,
                  _construcAddBar(_width),
                  NotificationHub(
                    notificationHubPositionController: _notificationHubPositionController,
                  ),
                  Positioned(
                    top: -70,
                    left: 0,
                    child: Container(
                      width: _width,
                      height: 20,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
            ),
      ),
    );
  }
}