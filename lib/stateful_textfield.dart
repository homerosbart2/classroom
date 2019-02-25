import 'package:flutter/material.dart';
import 'package:classroom/textfield_bloc.dart';

class StatefulTextfield extends StatefulWidget {
  final String suffix;
  final Color color;
  final String helper;
  final String label;
  final TextInputType type;
  final TextfieldBloc channel;
  final Function onChangedFunction;
  final bool isObscure;
  final TextEditingController controller;

  const StatefulTextfield({
    @required this.suffix,
    @required this.color,
    @required this.helper,
    @required this.label,
    this.controller,
    this.type,
    this.channel,
    this.onChangedFunction,
    this.isObscure,
  });

  @override
  _StatefulTextfieldState createState() => _StatefulTextfieldState();
}

class _StatefulTextfieldState extends State<StatefulTextfield> {
  String _actualSuffixSelected;
  bool _obscured;

  @override
  void initState() {
    super.initState();
    this._actualSuffixSelected = widget.suffix;
    if(widget.isObscure != null){
      this._obscured = widget.isObscure;
    }else{
      this._obscured = false;
    }
  }

  Widget baseTextfield(String suffix){
    return Container(
      margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
      child: TextField(
          onChanged: (String value){
            if(widget.onChangedFunction != null){
              widget.onChangedFunction(value);
            }
          },
          controller: widget.controller,
          obscureText: this._obscured,
          //textAlign: TextAlign.center,
          keyboardType: widget.type,
          decoration: InputDecoration(
            //fillColor: Colors.white,
            //filled: true,
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: widget.color,
            ),
            labelText: widget.label,
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            //hintText: 'Insert an input.',
            helperText: widget.helper,
            helperStyle: TextStyle(
              color: Colors.white,
            ),
            labelStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.color,
                width: 3.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            hasFloatingPlaceholder: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                style: BorderStyle.solid,
              ),
            ),
          ),
          style: TextStyle(
            fontFamily: 'Roboto Condensed',
            fontSize: 24.0,
            //color: Color.fromARGB(255, 0, 11, 43),
            color: Colors.redAccent[100],
            fontWeight: FontWeight.w700,
          ),
          cursorColor: Colors.redAccent[100],
        ),
    );
  }

  Widget build(BuildContext context) {
    if(widget.channel == null){
      return baseTextfield(this._actualSuffixSelected);
    }else{
      return StreamBuilder(
        stream: widget.channel.updateSuffixOut,
        initialData: _actualSuffixSelected,
        builder: (context, snapshot) => baseTextfield(snapshot.data),
      );
    }
  }
}
