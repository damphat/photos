import 'package:flutter/foundation.dart';

class AppState with ChangeNotifier {
  int _rot = 0;
  bool _fullscreen = false;

  int get rot => _rot;
  bool get fullscreen => _fullscreen;

  void setRot(int newRot) {
    _rot = newRot;
    notifyListeners();
  }

  void setFullscreen(bool newFullscreen) {
    _fullscreen = newFullscreen;
    notifyListeners();
  }
}
