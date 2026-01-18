import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_bible/db/db.dart';
import 'package:simple_bible/dto/book_dto.dart';
import 'package:simple_bible/dto/language_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_bible/dto/version_dto.dart';

class BaseModel extends ChangeNotifier {
  String _defaultLanguage = '';
  String _defaultVersion = '';
  double _fontScale = 1.0;
  late SharedPreferences _sh;
  VersionDTO? _version;
  List<BookDTO> _books = [];

  String get defaultLanguage => _defaultLanguage;

  set defaultLangauge(String value) {
    _defaultLanguage = value;
    notifyListeners();
  }

  String get defaultVersion => _defaultVersion;

  set defaultVersion(String value) {
    _defaultVersion = value;
    notifyListeners();
  }

  Map<String, LanguageDTO> _languages = {};

  Map<String, LanguageDTO> get languages => _languages;

  set languages(Map<String, LanguageDTO> value) {
    _languages = value;
    notifyListeners();
  }

  setupLanguage(dynamic languages) {
    for (var language in languages) {
      _languages.putIfAbsent(
        language['code'],
        () => LanguageDTO.fromDatabase(language),
      );
    }

    this.languages = languages;
  }

  List<BookDTO> get books => _books;

  set books(List<BookDTO> value) {
    _books = value;
    notifyListeners();
  }

  VersionDTO? get version => _version;

  set version(VersionDTO? value) {
    _version = value;
    notifyListeners();
  }

  double get fontScale => _fontScale;

  set fontScale(double value) {
    _fontScale = value;
    _sh.setDouble('fontScale', value);
    notifyListeners();
  }

  initData() async {
    _sh = await SharedPreferences.getInstance();

    var shDF = _sh.getString('defaultLanguage');

    if (shDF != null) {
      defaultLangauge = shDF;
    }

    var shDV = _sh.getString('defaultVersion');

    if (shDV != null) {
      defaultVersion = shDV;
    }

    double? scale = _sh.getDouble('fontScale');

    if (scale != null) {
      fontScale = scale;
    }
  }

  loadDataFromDB() async {
    print("Loading data from database...");
    final db = DB().db;

    final loadVersion = await db.query(
      'versions',
      where: 'id = ?',
      whereArgs: [int.parse(defaultVersion)],
    );
    print("loadVersion");
    print(loadVersion);
    version = VersionDTO.fromDatabase(loadVersion[0]);

    final loadBooks = await db.query(
      'books',
      where: 'versionId = ?',
      whereArgs: [int.parse(defaultVersion)],
      orderBy: '`order` ASC',
    );

    List<BookDTO> bookList = [];
    for (final book in loadBooks) {
      bookList.add(BookDTO.fromDatabase(book));
    }
    books = bookList;
    print("Loading data from database done...");
  }
}
