import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';

class PhotosState with ChangeNotifier {
  Directory? _dir;
  List<File> _files = [];
  File? _file;

  File? get file => _file;

  int get count => _files.length;

  int? get currentIndex {
    if (_file == null) return null;
    return _files.indexOf(_file!) + 1;
  }

  String get filename {
    if (_file == null) return "";
    return basename(_file!.path);
  }

  String get title {
    var index = currentIndex;
    if (_file != null) {
      return "$index/$count - $filename";
    } else {
      if (_dir == null) {
        return "Open a folder";
      } else {
        if (_files.isEmpty) {
          return "No photo in folder: ${_dir!.path}";
        } else {
          return "Please select a photo";
        }
      }
    }
  }

  static final photoExts = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'};
  static bool _isPhoto(File file) {
    var ext = extension(file.path).toLowerCase();
    return photoExts.contains(ext);
  }

  static List<File> _listPhotosSync(Directory dir) {
    return dir.listSync().whereType<File>().where((f) => _isPhoto(f)).toList();
  }

  /// Load all photos from a folder path.
  ///
  /// If path is a file, it should load all photos the parent folder of the file.
  ///
  /// Automatically sellect the first file if possible.
  void load(String path) {
    if (FileSystemEntity.isFileSync(path)) {
      _file = File(path);
      _dir = _file!.parent;
      _files = _listPhotosSync(_dir!);
      _file = _files.firstWhere((f) => f.path == _file!.path);
    } else {
      _dir = Directory(path);
      _files = _listPhotosSync(_dir!);
      if (_file != null) {
        _file = _files.firstWhereOrNull((f) => f.path == _file!.path);
      }
      if (_file == null) {
        _file = _files.firstOrNull;
      }
    }
    notifyListeners();
  }

  void next() {
    if (_files.isEmpty) {
      return;
    }

    var f = _file;

    if (f == null) {
      _file = _files[0];
    } else {
      var i = _files.indexOf(f);
      i = i == -1 ? 0 : (i + 1) % _files.length;
      _file = _files[i];
    }

    notifyListeners();
  }

  void prev() {
    if (_files.isEmpty) {
      return;
    }

    var f = _file;

    if (f == null) {
      _file = _files[_files.length - 1];
    } else {
      var i = _files.indexOf(f);
      i = i == -1 ? 0 : (i - 1 + _files.length) % _files.length;
      _file = _files[i];
    }

    notifyListeners();
  }

  void remove() {
    if (_file == null) return;
    var i = _files.indexOf(_file!);
    _files.remove(_file);
    if (i < _files.length) {
      _file = _files[i];
    } else if (_files.isNotEmpty) {
      _file = _files.last;
    } else {
      _file = null;
    }
    notifyListeners();
  }

  @override
  String toString() {
    var s = StringBuffer();
    var dir = this._dir;
    if (dir == null) {
      s.write('<null>');
      return s.toString();
    }

    s.writeln(dir.path);
    s.writeAll(_files.map((e) => e.path), "\n");
    s.writeln();
    s.writeln("current:");
    if (_file != null) s.write(_file!.path);

    return s.toString();
  }
}
