import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_bible/dto/language_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseModel extends ChangeNotifier {
  String _defaultLanguage = '';
  late SharedPreferences _sh;

  String get defaultLanguage => _defaultLanguage;

  set defaultLangauge(String value) {
    _defaultLanguage = value;
    notifyListeners();
  }

  Map<String, LanguageDTO> _languages = {};

  Map<String, LanguageDTO> get languages => _languages;

  set languages(Map<String, LanguageDTO> value) {
    _languages = value;
    notifyListeners();
  }

  setupLanguage(String jsonString) {
    Map<String, LanguageDTO> languages = {};
    Map<String, dynamic> body = jsonDecode(jsonString);

    for (var b in body.entries) {
      languages.putIfAbsent(
        b.key,
        () => LanguageDTO.fromJSON(b.value['name'], b.value['versions']),
      );
    }

    this.languages = languages;
  }

  Map<String, String> _books = {};

  Map<String, String> get books => _books;

  set books(Map<String, String> value) {
    _books = value;
    notifyListeners();
  }

  setBooks(String jsonString) {
    if (jsonString != '') {
      Map<dynamic, dynamic> bookDynamic = jsonDecode(jsonString);
      Map<String, String> books = {};

      for (final b in bookDynamic.entries) {
        books.putIfAbsent(b.key.toString(), () => b.value);
      }

      this.books = books;
    }
  }

  initData() async {
    _sh = await SharedPreferences.getInstance();

    var shDF = _sh.getString('defaultLanguage');

    if (shDF != null) {
      defaultLangauge = shDF;
    }

    String? booksJSON = _sh.getString('books');

    if (booksJSON != null) {
      await setBooks(booksJSON);
    }
  }
}
