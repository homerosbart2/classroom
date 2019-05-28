import 'package:flutter/material.dart';
import 'package:classroom/stateful_textfield.dart';
import 'package:classroom/stateful_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/courses_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:classroom/nav.dart';
import 'package:classroom/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login();

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin{
  FocusNode myFocusNode;
  bool _register, _logging, _actuallyLogged;
  int _logged;
  TextEditingController _usernameController, _passwordController, _nameController;
  AnimationController _slideController;
  Animation<Offset> _registerOffsetFloat, _loginOffsetFloat;
  SharedPreferences prefs;


  @override
  void initState() {
    super.initState();
    _register = false;
    _actuallyLogged = false;
    myFocusNode = FocusNode();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    _logging = false;

    _initSharedPreferences();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _registerOffsetFloat = Tween<Offset>(
      begin: Offset(2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      )
    );

    _loginOffsetFloat = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-2, 0),
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      )
    );
  }

  void _initSharedPreferences() async{
    prefs = await SharedPreferences.getInstance();
    _logged = prefs.getInt('logged');
    if(!_actuallyLogged && prefs.getInt('logged') == 1){
      print("INICIADO");
      validateAndSubmit(prefs.getString('email'), prefs.getString('password'), '');
    }
    String userEmail = prefs.getString('email');
    if(userEmail != null){
      print('USERNAME: $userEmail');
      _usernameController.text = userEmail;
      _passwordController.text = prefs.getString('password');
    }
  }

  void _navigateToCourses(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (BuildContext context) {
        return Nav(
          section: 'courses',
          title: 'CURSOS',
          body: CoursesRoute(),
        );
      }),
    );
  }

  void validateAndSubmit(String email, String password, String name) async {
    email = email.toString().trim().toLowerCase();
    password = password.toString().trim();
    //TODO: validar email valido y password no empty
    try{ 
      if(_register == true){
        String user = await Auth.createUserWithEmailAndPassword(email,password,name);
        if(user == null){
          print("USER IS NOT CREATE"); //TODO: message that user could not register correctly.\
          _logging = false;
        }else{
          prefs.setInt('logged', 1);
          prefs.setString('email', email);
          prefs.setString('password', password);
          _navigateToCourses(context);
          _logging = false;
          _actuallyLogged = true;
        }    
      }else{
        String user = await Auth.signInWithEmailAndPassword(email, password);
        print("Login: $user");
        Auth.currentUser().then((userId){
          if(userId == null){
            print("USER IS NOT LOGIN"); //TODO: message that user is not login correctly.\
            _logging = false;
          }else{
            prefs.setInt('logged', 1);
            prefs.setString('email', email);
            prefs.setString('password', password);
            _navigateToCourses(context);
            _logging = false;
            _actuallyLogged = true;
          } 
        });
      }
    }catch(e){
      print("Error in sign in: $e");
    }
  } 

  Widget _registerForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        StatefulTextfield(
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
          helper: 'correo electrónico.',
          label: 'Email',
          type: TextInputType.text,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          controller: _usernameController,
        ),
        StatefulTextfield(
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
          helper: 'Nombre de usuario.',
          label: 'Usuario',
          type: TextInputType.text,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          controller: _nameController,
        ),
        //ELEMENT: Campo para la CONTRASEÑA.
        StatefulTextfield(
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
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
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
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
                  _slideController.reverse();
                  _register = false;
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
                  if(!_logging){
                    _logging = true;
                    validateAndSubmit(_usernameController.text, _passwordController.text, _nameController.text);
                  //TODO: Hay que verificar que el usuario tenga cuenta en la base de datos y verificar el hash.
                  }
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
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
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
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
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
                  _slideController.forward();
                  _register = true;
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
                  if(!_logging){
                    _logging = true;
                     validateAndSubmit(_usernameController.text, _passwordController.text,"");
                  }
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
                child: Stack(
                  children: <Widget>[
                    SlideTransition(
                      position: _loginOffsetFloat,
                      child: _loginForm()
                    ),
                    SlideTransition(
                      position: _registerOffsetFloat,
                      child: _registerForm()
                    ),
                  ],
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