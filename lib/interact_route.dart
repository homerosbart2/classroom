import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:async';
import 'package:classroom/stateful_textfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InteractRoute extends StatefulWidget{
  const InteractRoute();

  _InteractRouteState createState() => _InteractRouteState();
}

class _InteractRouteState extends State<InteractRoute>{
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = (_width/4)*3;
    return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(12),
            width: _width,
            height: _height,
            child: FutureBuilder(
              future: _construc(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.hasData){
                  return snapshot.data;
                }else{
                  return Container();
                }
              },
            ),
          ),
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: _height),
                  //color: Color.fromARGB(10, 255, 0, 0),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Theme.of(context).accentColor,
                          padding: EdgeInsets.fromLTRB(12, 3, 12, 3),
                          child: Stack(
                            children: <Widget>[
                              StatefulTextfield(
                                color: Theme.of(context).accentColor,
                                fillColor: Colors.white,
                                suffix: '',
                                hint: 'Escriba una pregunta',
                                borderRadius: 30,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.check,
                                        size: 20,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}