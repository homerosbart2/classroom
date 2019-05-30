// import 'package:flutter/material.dart';
// import 'package:native_pdf_view/native_pdf_view.dart';
// import 'package:photo_view/photo_view.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinch_zoom_image/pinch_zoom_image.dart';

class Presentation extends StatefulWidget{
  final String file;
  final double animationValue;

  const Presentation({
    this.animationValue: 0,
    @required this.file
  });

  _PresentationState createState() => _PresentationState();
}

class _PresentationState extends State<Presentation> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin{
  PDFDocument _document;
  PDFPage _page;
  PDFPageImage _pageImage;
  int _actualPage;
  List<PDFPageImage> _pageImages;
  bool _loading, _firstPageLoaded;
  AnimationController _loadingController;
  Animation<double> _turnsFloat;

  @override
  void initState(){
    super.initState();

    _prepareDocument().then((_){
      _pageImages = List<PDFPageImage>(_document.pagesCount);
      setState((){
      });
    });

    _actualPage = 0;

    _loading = false;
    _firstPageLoaded = false;

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _turnsFloat = Tween<double>(
      begin: widget.animationValue,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.linear,
      ),
    );

    _startLoadingAnimation();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _startLoadingAnimation(){
    _loadingController.forward(from: 0).then((_){
      if(!_firstPageLoaded){
        _startLoadingAnimation();
      }
    });
  }

  Future<void> _prepareDocument() async{
    _document = await PDFDocument.openFile(widget.file);
  }

  @override
  bool get wantKeepAlive => true;

  Future<Widget> _construc(BuildContext context) async{
    _loading = true;
    if(_pageImages[_actualPage] == null){
      _page = await _document.getPage(_actualPage + 1);
      _pageImage = await _page.render(width: _page.width, height: _page.height, backgroundColor: 'white');
      _pageImages[_actualPage] = _pageImage;
      await _page.close().then((_){
        _loading = false;
      });
    }else{
      _pageImage = _pageImages[_actualPage];
      _loading = false;
    }
    _firstPageLoaded = true;
    return Future.delayed(const Duration(milliseconds: 0), () => 
      Container(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.only(bottom: 58),
                child: PinchZoomImage(
                  image: Image(
                    image: MemoryImage(_pageImage.bytes),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      if(!_loading) setState(() {
                       _actualPage = (_actualPage - 1) % _document.pagesCount; 
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.chevronLeft,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '${_actualPage + 1}/${_document.pagesCount}',
                  ),
                  GestureDetector(
                    onTap: (){
                      if(!_loading) setState(() {
                       _actualPage = (_actualPage + 1) % _document.pagesCount; 
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.chevronRight,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
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
                RotationTransition(
                  turns: _turnsFloat,
                  child: Icon(
                    FontAwesomeIcons.circleNotch
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