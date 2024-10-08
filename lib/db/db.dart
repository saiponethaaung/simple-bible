import 'package:sqflite/sqflite.dart';

class DB {
  late Database db;

  init() async {
    db = await openDatabase('bible.db');
  }
}
