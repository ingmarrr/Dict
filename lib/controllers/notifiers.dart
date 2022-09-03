import 'package:flutter/material.dart';

class Controller<T> extends ChangeNotifier {
  final T init;
  final T? next;
  T _state;

  Controller({required this.init, this.next}) : _state = init;

  T get state => _state;

  set state(T val) {
    _state = val;
    notifyListeners();
  }

  void toggle() {
    if (next != null) {
      _state = _state == init ? next! : init;
      notifyListeners();
    }
  }
}

class BoolController extends Controller<bool> {
  final bool init, next;
  BoolController({this.init = false, this.next = true})
      : super(init: init, next: next);
}
