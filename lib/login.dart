import 'package:flutter/material.dart';
import 'package:classroom/stateful_textfield.dart';
import 'package:classroom/stateful_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/courses_route.dart';
import 'package:classroom/choice.dart';
import 'package:flutter/cupertino.dart';

class Login extends StatefulWidget {
  const Login();

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FocusNode myFocusNode;
  bool _register;
  TextEditingController _usernameController;
  TextEditingController _passwordController;
  List<Choice> _choices;

  @override
  void initState() {
    super.initState();
    _register = false;
    myFocusNode = FocusNode();
    _usernameController = new TextEditingController();
    _passwordController = new TextEditingController();
  }

  

  void _navigateToCourses(BuildContext context) {
    _choices = const <Choice>[
      const Choice(title: 'Perfil', icon: Icons.directions_car),
    ];

    Navigator.of(context).push(
      CupertinoPageRoute(builder: (BuildContext context) {
        return Scaffold(
          drawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
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
                                  image: AssetImage('lib/assets/images/default.png'),
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
                                      '@',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'henry.campos',
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
                          'Clases',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Update the state of the app
                      // ...
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
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: new Icon(
                  FontAwesomeIcons.search,
                  size: 20,
                ), 
                onPressed: () { 
                  //Navigator.of(context).pop(); 
                },
              ),
 
              /* PopupMenuButton<Choice>(
              onSelected: (choice){},
              itemBuilder: (BuildContext context) {
                return _choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            ), */
            ],
            elevation: 1.0,
            title: Container(
              padding: EdgeInsets.all(3.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Cursos',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Inicio',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: false,
            backgroundColor: Theme.of(context).accentColor,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
          body: CoursesRoute(
          ),
        );
      }),
    );
  }

  Widget _registerForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        StatefulTextfield(
          suffix: '',
          color: Colors.white,
          helper: 'Nombre de usuario.',
          label: 'Usuario',
          type: TextInputType.text,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          controller: _usernameController,
        ),
        //ELEMENT: Campo para la CONTRASEÑA.
        StatefulTextfield(
          suffix: '',
          color: Colors.white,
          helper: 'Contraseña del usuario.',
          label: 'Contraseña',
          type: TextInputType.text,
          isObscure: true,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          controller: _passwordController,
        ),
        StatefulTextfield(
          suffix: '',
          color: Colors.white,
          helper: 'Contraseña del usuario.',
          label: 'Contraseña',
          type: TextInputType.text,
          isObscure: true,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
        ),
        Container(
          margin: EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StatefulButton(
                icon: FontAwesomeIcons.arrowLeft,
                text: 'CANCELAR',
                color: Theme.of(context).primaryColor,
                onTap: (){
                  setState(() {
                    _register = false;
                  });
                },
                type: 'a',
                weight: FontWeight.bold,
              ),
              StatefulButton(
                text: 'ACEPTAR',
                color: Colors.white,
                borderColor: Theme.of(context).primaryColor,
                fillColor: Theme.of(context).primaryColor,
                onTap: (){
                  //TODO: Hay que verificar que el usuario tenga cuenta en la base de datos y verificar el hash.
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loginForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 12.0),
          child: RichText(
            text: TextSpan(
              text: 'Classroom',
              style: TextStyle(
                fontFamily: 'Vampiro One',
                color: Colors.white,
                fontSize: 50.0,
                //fontWeight: FontWeight.bold,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 12.0,
                    color: Color.fromARGB(20, 0, 0, 0),
                  ),
                ],
              ),
            ),
            
          ),
        ),
        StatefulTextfield(
          suffix: '',
          color: Colors.white,
          helper: 'Nombre de usuario.',
          label: 'Usuario',
          type: TextInputType.text,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          controller: _usernameController,
        ),
        //ELEMENT: Campo para la CONTRASEÑA.
        StatefulTextfield(
          suffix: '',
          color: Colors.white,
          helper: 'Contraseña del usuario.',
          label: 'Contraseña',
          type: TextInputType.text,
          isObscure: true,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          controller: _passwordController,
        ),
        Container(
          margin: EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StatefulButton(
                text: 'REGISTRARSE',
                color: Theme.of(context).primaryColor,
                onTap: (){
                  setState(() {
                    _register = true;
                  });
                },
                type: 'a',
                weight: FontWeight.bold,
              ),
              StatefulButton(
                text: 'INICIAR',
                color: Colors.white,
                borderColor: Theme.of(context).primaryColor,
                fillColor: Theme.of(context).primaryColor,
                onTap: (){
                  //TODO: Hay que verificar que el usuario tenga cuenta en la base de datos y verificar el hash.
                  _navigateToCourses(context);
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final loginWidget = FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: GestureDetector(
        onTap: (){
          print('TAAAAP');
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/images/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.all(25.0),
          alignment: Alignment(0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: AnimatedCrossFade(
                  firstChild: _loginForm(),
                  secondChild: _registerForm(),
                  duration: Duration(milliseconds: 0),
                  crossFadeState: _register ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Copyright © Diego Alay & Henry Campos',
                  style: TextStyle(
                    fontFamily: 'Roboto Condensed',
                    color: Colors.white,
                    fontSize: 12.0,
                    //fontWeight: FontWeight.bold,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 12.0,
                        color: Color.fromARGB(20, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: loginWidget,
    );
  }
}