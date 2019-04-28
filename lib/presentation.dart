import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:async';

class Presentation extends StatefulWidget{
  final String file;

  const Presentation({
    @required this.file
  });

  _PresentationState createState() => _PresentationState();
}

class _PresentationState extends State<Presentation> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  Future<Widget> _construc(BuildContext context) async{
    //print(widget.file);
    return Future.delayed(const Duration(milliseconds: 370), () => 
      NativePDFView(
        loader: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 1,
          child: Container(
            //color: Theme.of(context).accentColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'CARGANDO...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ],
            ),
          )
        ),
      // Load from assets
      pdfFile: widget.file,
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
    return FutureBuilder(
      future: _construc(context),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          return snapshot.data;
        }else{
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'CARGANDO...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}