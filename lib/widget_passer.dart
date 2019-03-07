import 'package:rxdart/rxdart.dart';
import 'dart:async';

class WidgetPasser{
  Sink<String> get sendWidget => _sendWidgetController.sink;
  final _sendWidgetController = StreamController<String>();

  Stream<String> get recieveWidget => _recieveWidgetSubject.stream;
  final _recieveWidgetSubject = BehaviorSubject<String>();

  WidgetPasser(){
    _sendWidgetController.stream.listen(_handle);
  }

  void _handle(String suffix){
    _recieveWidgetSubject.add(suffix);
  }

}