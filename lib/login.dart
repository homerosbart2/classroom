import 'package:flutter/material.dart';
import 'package:classroom/stateful_textfield.dart';
import 'package:classroom/stateful_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _register = false;
    myFocusNode = FocusNode();
    _usernameController = new TextEditingController();
    _passwordController = new TextEditingController();
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